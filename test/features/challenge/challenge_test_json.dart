/// One dataset problem with every field filled, shaped like `assets/problems.json`.
Map<String, dynamic> fullProblemJson() => {
  'problem_id': 7,
  'number': 7,
  'name': 'Reverse Linked List',
  'source': 'LeetCode',
  'source_problem_number': 206,
  'difficulty': 'easy',
  'category': 'Linked Lists',
  'tags': ['Linked List', 'Recursion'],
  'patterns': ['Two Pointers'],
  'description': 'Reverse a singly linked list.',
  'constraints': ['0 <= n <= 5000'],
  'function_signature': {'generic': 'reverseList(head)', 'dart': 'ListNode? reverseList(ListNode? head)'},
  'default_code': {
    'dart': 'ListNode? reverseList(ListNode? head) {\n}',
    'python': 'def reverse_list(head):\n',
  },
  'custom_objects': {
    'dart': [
      {
        'code': 'class ListNode { int val; ListNode? next; ListNode(this.val, [this.next]); }',
        'shape': 'linked_list',
      },
      'class Helper {}',
    ],
  },
  'examples': [
    {'input': 'head = [1,2,3]', 'output': '[3,2,1]', 'explanation': 'Each link flips.'},
  ],
  'edge_cases': ['An empty list'],
  'test_cases': [
    {'input': '[1,2,3]', 'expected_output': '[3,2,1]'},
  ],
  'hidden_test_cases': [
    {'input': '[]', 'expected_output': '[]'},
  ],
  'hints': ['Keep the previous node.'],
  'solution_approach': {
    'key_observation': 'Each node only needs its next pointer flipped.',
    'algorithm': 'Walk once, flipping as you go.',
    'why_it_works': 'Every link is visited exactly once.',
    'implementation_notes': 'Save next before flipping.',
  },
  'expected_time_complexity': 'O(n)',
  'expected_space_complexity': 'O(1)',
  'what_you_learn': 'Pointer juggling',
  'key_pattern': 'In-place reversal',
  'prerequisites': ['Linked lists'],
  'follow_up_concepts': ['Reverse in groups of k'],
  'common_mistakes': ['Losing the rest of the list'],
  'similar_questions': [
    {'problem_id': 8, 'name': 'Reverse Linked List II', 'reason': 'Same idea on a range.'},
  ],
  'comparison': 'unordered',
};
