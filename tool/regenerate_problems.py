#!/usr/bin/env python3
"""Regenerates assets/problems.json consistent metadata.

- Writes `default_code.dart` for every problem: the function always wrapped in
  `class Solution` (LeetCode style). Class-based problems (MinStack, MyQueue,
  LRUCache, Codec) keep their own class name as LeetCode does.
  When a custom object type is used (ListNode/TreeNode/Node) a `/** ... */`
  "Definition" doc comment is prepended.
- Writes `custom_objects.dart` as `[{"code": ..., "shape": ...}]`.
- Reorders problems by `source_problem_number`, renumbers `problem_id` in
  order, and adds `number` = `problem_id` right after it.

Run: `python3 tool/regenerate_problems.py assets/problems.json`
"""

import json
import re
import sys

CUSTOM_DEFS = {
    "ListNode": {
        "comment": "Definition for singly-linked list.",
        "code": "class ListNode {\n"
        "  int val;\n"
        "  ListNode? next;\n"
        "  ListNode([this.val = 0, this.next]);\n"
        "}",
        "shape": "linked_list",
    },
    "TreeNode": {
        "comment": "Definition for a binary tree node.",
        "code": "class TreeNode {\n"
        "  int val;\n"
        "  TreeNode? left;\n"
        "  TreeNode? right;\n"
        "  TreeNode([this.val = 0, this.left, this.right]);\n"
        "}",
        "shape": "binary_tree",
    },
    "Node": {
        "comment": "Definition for a Node.",
        "code": "class Node {\n"
        "  int val;\n"
        "  List<Node> neighbors;\n"
        "  Node(this.val, [this.neighbors]);\n"
        "}",
        "shape": "plain_fields",
    },
}


def definition_comment(types):
    """Builds the LeetCode-style `/** ... */` comment for the given types."""
    lines = ["/**"]
    for i, t in enumerate(types):
        if i > 0:
            lines.append(" *")
        lines.append(" * " + CUSTOM_DEFS[t]["comment"])
        for line in CUSTOM_DEFS[t]["code"].splitlines():
            lines.append(" * " + line)
    lines.append(" */")
    return "\n".join(lines)


def default_code(problem):
    sig = problem["function_signature"]["dart"].strip()
    used = [
        t
        for t in ("ListNode", "TreeNode", "Node")
        if re.search(r"\b" + t + r"\b", sig)
    ]
    header = definition_comment(used) + "\n" if used else ""
    if sig.startswith("class "):
        # Class-based problem (MinStack, MyQueue, LRUCache, Codec): keep the
        # class name as-is (LeetCode convention), expand method stubs.
        m = re.match(r"^class\s+(\w+)\s*\{(.*)\}$", sig, re.S)
        assert m, f"Unsupported class signature: {sig}"
        members = [mm.strip() for mm in m.group(2).split(";") if mm.strip()]
        body = "\n".join(f"  {member} {{\n\n\n  }}" for member in members)
        return f"{header}class {m.group(1)} {{\n{body}\n}}"
    return f"{header}class Solution {{\n  {sig} {{\n\n\n  }}\n}}"


def custom_objects(problem):
    sig = problem["function_signature"]["dart"]
    used = [
        t
        for t in ("ListNode", "TreeNode", "Node")
        if re.search(r"\b" + t + r"\b", sig)
    ]
    entries = [
        {"code": CUSTOM_DEFS[t]["code"], "shape": CUSTOM_DEFS[t]["shape"]}
        for t in used
    ]
    return {"dart": entries}


def main(path):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    problems = sorted(
        data["problems"], key=lambda p: (p.get("source", ""), p["source_problem_number"])
    )

    for index, problem in enumerate(problems):
        problem["problem_id"] = index + 1
        # Rebuild key order: problem_id, number, then the rest.
        ordered = {"problem_id": problem["problem_id"], "number": problem["problem_id"]}
        for k, v in problem.items():
            if k not in ordered:
                ordered[k] = v
        problems[index] = ordered
        problems[index]["default_code"] = {"dart": default_code(problem)}
        problems[index]["custom_objects"] = custom_objects(problem)

    data["problems"] = problems
    data["dataset"]["total_problems"] = len(problems)

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"Wrote {len(problems)} problems to {path}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "assets/problems.json")
