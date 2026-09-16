// Verified Python and JavaScript solutions for every gradable problem outside
// the pilot set. Each one is run against the stored test cases by
// `language_coverage_test.dart`; a problem only gets starter code in
// `assets/problems.json` once its entry here passes.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage;

/// problem id -> language -> a correct solution.
const coverageSolutions = <int, Map<EditorLanguage, String>>{
  // Longest Substring Without Repeating Characters — sliding window.
  3: <EditorLanguage, String>{
    EditorLanguage.python: '''
def lengthOfLongestSubstring(s):
    last = {}
    best = 0
    start = 0
    for i in range(len(s)):
        c = s[i]
        if c in last and last[c] >= start:
            start = last[c] + 1
        last[c] = i
        if i - start + 1 > best:
            best = i - start + 1
    return best
''',
    EditorLanguage.javascript: '''
function lengthOfLongestSubstring(s) {
  const last = new Map()
  let best = 0
  let start = 0
  for (let i = 0; i < s.length; i++) {
    const c = s[i]
    if (last.has(c) && last.get(c) >= start) start = last.get(c) + 1
    last.set(c, i)
    if (i - start + 1 > best) best = i - start + 1
  }
  return best
}
''',
  },

  // Median of Two Sorted Arrays — merge and pick the middle.
  4: <EditorLanguage, String>{
    EditorLanguage.python: '''
def findMedianSortedArrays(nums1, nums2):
    merged = sorted(nums1 + nums2)
    n = len(merged)
    if n % 2 == 1:
        return merged[n // 2] / 1
    return (merged[n // 2 - 1] + merged[n // 2]) / 2
''',
    EditorLanguage.javascript: '''
function findMedianSortedArrays(nums1, nums2) {
  const merged = [...nums1, ...nums2].sort((a, b) => a - b)
  const n = merged.length
  const mid = Math.floor(n / 2)
  if (n % 2 === 1) return merged[mid]
  return (merged[mid - 1] + merged[mid]) / 2
}
''',
  },

  // Container With Most Water — two pointers.
  5: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxArea(height):
    left = 0
    right = len(height) - 1
    best = 0
    while left < right:
        h = min(height[left], height[right])
        best = max(best, h * (right - left))
        if height[left] < height[right]:
            left += 1
        else:
            right -= 1
    return best
''',
    EditorLanguage.javascript: '''
function maxArea(height) {
  let left = 0
  let right = height.length - 1
  let best = 0
  while (left < right) {
    const h = Math.min(height[left], height[right])
    best = Math.max(best, h * (right - left))
    if (height[left] < height[right]) left++
    else right--
  }
  return best
}
''',
  },

  // 3Sum — sort, then a two-pointer sweep per anchor.
  6: <EditorLanguage, String>{
    EditorLanguage.python: '''
def threeSum(nums):
    nums = sorted(nums)
    out = []
    n = len(nums)
    for i in range(n - 2):
        if i > 0 and nums[i] == nums[i - 1]:
            continue
        left = i + 1
        right = n - 1
        while left < right:
            total = nums[i] + nums[left] + nums[right]
            if total < 0:
                left += 1
            elif total > 0:
                right -= 1
            else:
                out.append([nums[i], nums[left], nums[right]])
                left += 1
                while left < right and nums[left] == nums[left - 1]:
                    left += 1
                right -= 1
    return out
''',
    EditorLanguage.javascript: '''
function threeSum(nums) {
  const a = [...nums].sort((x, y) => x - y)
  const out = []
  for (let i = 0; i < a.length - 2; i++) {
    if (i > 0 && a[i] === a[i - 1]) continue
    let left = i + 1
    let right = a.length - 1
    while (left < right) {
      const total = a[i] + a[left] + a[right]
      if (total < 0) left++
      else if (total > 0) right--
      else {
        out.push([a[i], a[left], a[right]])
        left++
        while (left < right && a[left] === a[left - 1]) left++
        right--
      }
    }
  }
  return out
}
''',
  },

  // Letter Combinations of a Phone Number — iterative expansion.
  7: <EditorLanguage, String>{
    EditorLanguage.python: '''
def letterCombinations(digits):
    if len(digits) == 0:
        return []
    pad = {
        "2": "abc", "3": "def", "4": "ghi", "5": "jkl",
        "6": "mno", "7": "pqrs", "8": "tuv", "9": "wxyz",
    }
    out = [""]
    for d in digits:
        nxt = []
        for prefix in out:
            for c in pad[d]:
                nxt.append(prefix + c)
        out = nxt
    return out
''',
    EditorLanguage.javascript: '''
function letterCombinations(digits) {
  if (digits.length === 0) return []
  const pad = {
    "2": "abc", "3": "def", "4": "ghi", "5": "jkl",
    "6": "mno", "7": "pqrs", "8": "tuv", "9": "wxyz",
  }
  let out = [""]
  for (const d of digits) {
    const next = []
    for (const prefix of out) {
      for (const c of pad[d]) next.push(prefix + c)
    }
    out = next
  }
  return out
}
''',
  },

  // Generate Parentheses — backtracking over open/close counts.
  11: <EditorLanguage, String>{
    EditorLanguage.python: '''
def generateParenthesis(n):
    out = []

    def build(current, open_count, close_count):
        if len(current) == n * 2:
            out.append(current)
            return
        if open_count < n:
            build(current + "(", open_count + 1, close_count)
        if close_count < open_count:
            build(current + ")", open_count, close_count + 1)

    build("", 0, 0)
    return out
''',
    EditorLanguage.javascript: '''
function generateParenthesis(n) {
  const out = []
  function build(current, openCount, closeCount) {
    if (current.length === n * 2) {
      out.push(current)
      return
    }
    if (openCount < n) build(current + "(", openCount + 1, closeCount)
    if (closeCount < openCount) build(current + ")", openCount, closeCount + 1)
  }
  build("", 0, 0)
  return out
}
''',
  },

  // Search in Rotated Sorted Array — binary search on the sorted half.
  13: <EditorLanguage, String>{
    EditorLanguage.python: '''
def search(nums, target):
    low = 0
    high = len(nums) - 1
    while low <= high:
        mid = (low + high) // 2
        if nums[mid] == target:
            return mid
        if nums[low] <= nums[mid]:
            if nums[low] <= target and target < nums[mid]:
                high = mid - 1
            else:
                low = mid + 1
        else:
            if nums[mid] < target and target <= nums[high]:
                low = mid + 1
            else:
                high = mid - 1
    return -1
''',
    EditorLanguage.javascript: '''
function search(nums, target) {
  let low = 0
  let high = nums.length - 1
  while (low <= high) {
    const mid = Math.floor((low + high) / 2)
    if (nums[mid] === target) return mid
    if (nums[low] <= nums[mid]) {
      if (nums[low] <= target && target < nums[mid]) high = mid - 1
      else low = mid + 1
    } else {
      if (nums[mid] < target && target <= nums[high]) low = mid + 1
      else high = mid - 1
    }
  }
  return -1
}
''',
  },

  // Combination Sum — backtracking with reuse allowed.
  14: <EditorLanguage, String>{
    EditorLanguage.python: '''
def combinationSum(candidates, target):
    out = []

    def build(start, remaining, chosen):
        if remaining == 0:
            out.append(list(chosen))
            return
        for i in range(start, len(candidates)):
            if candidates[i] <= remaining:
                chosen.append(candidates[i])
                build(i, remaining - candidates[i], chosen)
                chosen.pop()

    build(0, target, [])
    return out
''',
    EditorLanguage.javascript: '''
function combinationSum(candidates, target) {
  const out = []
  function build(start, remaining, chosen) {
    if (remaining === 0) {
      out.push([...chosen])
      return
    }
    for (let i = start; i < candidates.length; i++) {
      if (candidates[i] <= remaining) {
        chosen.push(candidates[i])
        build(i, remaining - candidates[i], chosen)
        chosen.pop()
      }
    }
  }
  build(0, target, [])
  return out
}
''',
  },

  // Trapping Rain Water — two pointers carrying the running maxima.
  15: <EditorLanguage, String>{
    EditorLanguage.python: '''
def trap(height):
    left = 0
    right = len(height) - 1
    left_max = 0
    right_max = 0
    total = 0
    while left < right:
        if height[left] < height[right]:
            left_max = max(left_max, height[left])
            total += left_max - height[left]
            left += 1
        else:
            right_max = max(right_max, height[right])
            total += right_max - height[right]
            right -= 1
    return total
''',
    EditorLanguage.javascript: '''
function trap(height) {
  let left = 0
  let right = height.length - 1
  let leftMax = 0
  let rightMax = 0
  let total = 0
  while (left < right) {
    if (height[left] < height[right]) {
      leftMax = Math.max(leftMax, height[left])
      total += leftMax - height[left]
      left++
    } else {
      rightMax = Math.max(rightMax, height[right])
      total += rightMax - height[right]
      right--
    }
  }
  return total
}
''',
  },

  // Permutations — backtracking with a used flag per index.
  16: <EditorLanguage, String>{
    EditorLanguage.python: '''
def permute(nums):
    out = []
    used = [False] * len(nums)

    def build(chosen):
        if len(chosen) == len(nums):
            out.append(list(chosen))
            return
        for i in range(len(nums)):
            if not used[i]:
                used[i] = True
                chosen.append(nums[i])
                build(chosen)
                chosen.pop()
                used[i] = False

    build([])
    return out
''',
    EditorLanguage.javascript: '''
function permute(nums) {
  const out = []
  const used = new Array(nums.length).fill(false)
  function build(chosen) {
    if (chosen.length === nums.length) {
      out.push([...chosen])
      return
    }
    for (let i = 0; i < nums.length; i++) {
      if (!used[i]) {
        used[i] = true
        chosen.push(nums[i])
        build(chosen)
        chosen.pop()
        used[i] = false
      }
    }
  }
  build([])
  return out
}
''',
  },

  // N-Queens — column and diagonal sets, rendered back to strings.
  18: <EditorLanguage, String>{
    EditorLanguage.python: '''
def solveNQueens(n):
    out = []
    cols = []
    positions = []

    def safe(row, col):
        for r in range(len(positions)):
            c = positions[r]
            if c == col or r - c == row - col or r + c == row + col:
                return False
        return True

    def build(row):
        if row == n:
            board = []
            for c in positions:
                line = ""
                for i in range(n):
                    line += "Q" if i == c else "."
                board.append(line)
            out.append(board)
            return
        for col in range(n):
            if safe(row, col):
                positions.append(col)
                build(row + 1)
                positions.pop()

    build(0)
    return out
''',
    EditorLanguage.javascript: '''
function solveNQueens(n) {
  const out = []
  const positions = []
  function safe(row, col) {
    for (let r = 0; r < positions.length; r++) {
      const c = positions[r]
      if (c === col || r - c === row - col || r + c === row + col) return false
    }
    return true
  }
  function build(row) {
    if (row === n) {
      const board = []
      for (const c of positions) {
        let line = ""
        for (let i = 0; i < n; i++) line += i === c ? "Q" : "."
        board.push(line)
      }
      out.push(board)
      return
    }
    for (let col = 0; col < n; col++) {
      if (safe(row, col)) {
        positions.push(col)
        build(row + 1)
        positions.pop()
      }
    }
  }
  build(0)
  return out
}
''',
  },

  // Jump Game — greedy furthest reach.
  20: <EditorLanguage, String>{
    EditorLanguage.python: '''
def canJump(nums):
    reach = 0
    for i in range(len(nums)):
        if i > reach:
            return False
        reach = max(reach, i + nums[i])
    return True
''',
    EditorLanguage.javascript: '''
function canJump(nums) {
  let reach = 0
  for (let i = 0; i < nums.length; i++) {
    if (i > reach) return false
    reach = Math.max(reach, i + nums[i])
  }
  return true
}
''',
  },

  // Insert Interval — copy before, merge the overlap, copy after.
  22: <EditorLanguage, String>{
    EditorLanguage.python: '''
def insert(intervals, newInterval):
    out = []
    start = newInterval[0]
    end = newInterval[1]
    i = 0
    n = len(intervals)
    while i < n and intervals[i][1] < start:
        out.append(intervals[i])
        i += 1
    while i < n and intervals[i][0] <= end:
        start = min(start, intervals[i][0])
        end = max(end, intervals[i][1])
        i += 1
    out.append([start, end])
    while i < n:
        out.append(intervals[i])
        i += 1
    return out
''',
    EditorLanguage.javascript: '''
function insert(intervals, newInterval) {
  const out = []
  let start = newInterval[0]
  let end = newInterval[1]
  let i = 0
  while (i < intervals.length && intervals[i][1] < start) {
    out.push(intervals[i])
    i++
  }
  while (i < intervals.length && intervals[i][0] <= end) {
    start = Math.min(start, intervals[i][0])
    end = Math.max(end, intervals[i][1])
    i++
  }
  out.push([start, end])
  while (i < intervals.length) {
    out.push(intervals[i])
    i++
  }
  return out
}
''',
  },

  // Unique Paths — one rolling row of the grid DP.
  23: <EditorLanguage, String>{
    EditorLanguage.python: '''
def uniquePaths(m, n):
    row = [1] * n
    for _ in range(m - 1):
        for j in range(1, n):
            row[j] += row[j - 1]
    return row[n - 1]
''',
    EditorLanguage.javascript: '''
function uniquePaths(m, n) {
  const row = new Array(n).fill(1)
  for (let i = 1; i < m; i++) {
    for (let j = 1; j < n; j++) row[j] += row[j - 1]
  }
  return row[n - 1]
}
''',
  },

  // Edit Distance — classic two-dimensional DP.
  25: <EditorLanguage, String>{
    EditorLanguage.python: '''
def minDistance(word1, word2):
    n = len(word2)
    previous = list(range(n + 1))
    for i in range(1, len(word1) + 1):
        current = [i] + [0] * n
        for j in range(1, n + 1):
            if word1[i - 1] == word2[j - 1]:
                current[j] = previous[j - 1]
            else:
                current[j] = 1 + min(previous[j - 1], previous[j], current[j - 1])
        previous = current
    return previous[n]
''',
    EditorLanguage.javascript: '''
function minDistance(word1, word2) {
  const n = word2.length
  let previous = []
  for (let j = 0; j <= n; j++) previous.push(j)
  for (let i = 1; i <= word1.length; i++) {
    const current = new Array(n + 1).fill(0)
    current[0] = i
    for (let j = 1; j <= n; j++) {
      if (word1[i - 1] === word2[j - 1]) current[j] = previous[j - 1]
      else current[j] = 1 + Math.min(previous[j - 1], previous[j], current[j - 1])
    }
    previous = current
  }
  return previous[n]
}
''',
  },

  // Search a 2D Matrix — binary search over the flattened grid.
  26: <EditorLanguage, String>{
    EditorLanguage.python: '''
def searchMatrix(matrix, target):
    if len(matrix) == 0 or len(matrix[0]) == 0:
        return False
    cols = len(matrix[0])
    low = 0
    high = len(matrix) * cols - 1
    while low <= high:
        mid = (low + high) // 2
        value = matrix[mid // cols][mid % cols]
        if value == target:
            return True
        if value < target:
            low = mid + 1
        else:
            high = mid - 1
    return False
''',
    EditorLanguage.javascript: '''
function searchMatrix(matrix, target) {
  if (matrix.length === 0 || matrix[0].length === 0) return false
  const cols = matrix[0].length
  let low = 0
  let high = matrix.length * cols - 1
  while (low <= high) {
    const mid = Math.floor((low + high) / 2)
    const value = matrix[Math.floor(mid / cols)][mid % cols]
    if (value === target) return true
    if (value < target) low = mid + 1
    else high = mid - 1
  }
  return false
}
''',
  },

  // Sort Colors — Dutch national flag, in place.
  27: <EditorLanguage, String>{
    EditorLanguage.python: '''
def sortColors(nums):
    low = 0
    mid = 0
    high = len(nums) - 1
    while mid <= high:
        if nums[mid] == 0:
            nums[low], nums[mid] = nums[mid], nums[low]
            low += 1
            mid += 1
        elif nums[mid] == 2:
            nums[high], nums[mid] = nums[mid], nums[high]
            high -= 1
        else:
            mid += 1
''',
    EditorLanguage.javascript: '''
function sortColors(nums) {
  let low = 0
  let mid = 0
  let high = nums.length - 1
  while (mid <= high) {
    if (nums[mid] === 0) {
      const t = nums[low]
      nums[low] = nums[mid]
      nums[mid] = t
      low++
      mid++
    } else if (nums[mid] === 2) {
      const t = nums[high]
      nums[high] = nums[mid]
      nums[mid] = t
      high--
    } else {
      mid++
    }
  }
}
''',
  },

  // Minimum Window Substring — sliding window with a need/have count.
  28: <EditorLanguage, String>{
    EditorLanguage.python: '''
def minWindow(s, t):
    if len(t) == 0 or len(s) < len(t):
        return ""
    need = {}
    for c in t:
        need[c] = need.get(c, 0) + 1
    missing = len(t)
    best_start = 0
    best_len = -1
    left = 0
    for right in range(len(s)):
        c = s[right]
        if c in need:
            if need[c] > 0:
                missing -= 1
            need[c] -= 1
        while missing == 0:
            if best_len == -1 or right - left + 1 < best_len:
                best_len = right - left + 1
                best_start = left
            lc = s[left]
            if lc in need:
                need[lc] += 1
                if need[lc] > 0:
                    missing += 1
            left += 1
    if best_len == -1:
        return ""
    return s[best_start:best_start + best_len]
''',
    EditorLanguage.javascript: '''
function minWindow(s, t) {
  if (t.length === 0 || s.length < t.length) return ""
  const need = new Map()
  for (const c of t) need.set(c, (need.get(c) ?? 0) + 1)
  let missing = t.length
  let bestStart = 0
  let bestLen = -1
  let left = 0
  for (let right = 0; right < s.length; right++) {
    const c = s[right]
    if (need.has(c)) {
      if (need.get(c) > 0) missing--
      need.set(c, need.get(c) - 1)
    }
    while (missing === 0) {
      if (bestLen === -1 || right - left + 1 < bestLen) {
        bestLen = right - left + 1
        bestStart = left
      }
      const lc = s[left]
      if (need.has(lc)) {
        need.set(lc, need.get(lc) + 1)
        if (need.get(lc) > 0) missing++
      }
      left++
    }
  }
  if (bestLen === -1) return ""
  return s.substring(bestStart, bestStart + bestLen)
}
''',
  },

  // Subsets — grow the answer one element at a time.
  29: <EditorLanguage, String>{
    EditorLanguage.python: '''
def subsets(nums):
    out = [[]]
    for n in nums:
        for i in range(len(out)):
            out.append(out[i] + [n])
    return out
''',
    EditorLanguage.javascript: '''
function subsets(nums) {
  let out = [[]]
  for (const n of nums) {
    const grown = []
    for (const s of out) grown.push([...s, n])
    out = [...out, ...grown]
  }
  return out
}
''',
  },

  // Word Search — depth-first search with the board marked in place.
  30: <EditorLanguage, String>{
    EditorLanguage.python: '''
def exist(board, word):
    rows = len(board)
    cols = len(board[0])

    def walk(r, c, i):
        if i == len(word):
            return True
        if r < 0 or c < 0 or r >= rows or c >= cols:
            return False
        if board[r][c] != word[i]:
            return False
        keep = board[r][c]
        board[r][c] = "#"
        found = walk(r + 1, c, i + 1) or walk(r - 1, c, i + 1) or walk(r, c + 1, i + 1) or walk(r, c - 1, i + 1)
        board[r][c] = keep
        return found

    for r in range(rows):
        for c in range(cols):
            if walk(r, c, 0):
                return True
    return False
''',
    EditorLanguage.javascript: '''
function exist(board, word) {
  const rows = board.length
  const cols = board[0].length
  function walk(r, c, i) {
    if (i === word.length) return true
    if (r < 0 || c < 0 || r >= rows || c >= cols) return false
    if (board[r][c] !== word[i]) return false
    const keep = board[r][c]
    board[r][c] = "#"
    const found = walk(r + 1, c, i + 1) || walk(r - 1, c, i + 1) ||
        walk(r, c + 1, i + 1) || walk(r, c - 1, i + 1)
    board[r][c] = keep
    return found
  }
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (walk(r, c, 0)) return true
    }
  }
  return false
}
''',
  },

  // Largest Rectangle in Histogram — monotonic increasing stack.
  31: <EditorLanguage, String>{
    EditorLanguage.python: '''
def largestRectangleArea(heights):
    bars = heights + [0]
    stack = []
    best = 0
    for i in range(len(bars)):
        while len(stack) > 0 and bars[stack[len(stack) - 1]] > bars[i]:
            top = stack.pop()
            if len(stack) == 0:
                width = i
            else:
                width = i - stack[len(stack) - 1] - 1
            best = max(best, bars[top] * width)
        stack.append(i)
    return best
''',
    EditorLanguage.javascript: '''
function largestRectangleArea(heights) {
  const bars = [...heights, 0]
  const stack = []
  let best = 0
  for (let i = 0; i < bars.length; i++) {
    while (stack.length > 0 && bars[stack[stack.length - 1]] > bars[i]) {
      const top = stack.pop()
      const width = stack.length === 0 ? i : i - stack[stack.length - 1] - 1
      best = Math.max(best, bars[top] * width)
    }
    stack.push(i)
  }
  return best
}
''',
  },

  // Merge Sorted Array — fill nums1 from the back, in place.
  32: <EditorLanguage, String>{
    EditorLanguage.python: '''
def merge(nums1, m, nums2, n):
    i = m - 1
    j = n - 1
    k = m + n - 1
    while j >= 0:
        if i >= 0 and nums1[i] > nums2[j]:
            nums1[k] = nums1[i]
            i -= 1
        else:
            nums1[k] = nums2[j]
            j -= 1
        k -= 1
''',
    EditorLanguage.javascript: '''
function merge(nums1, m, nums2, n) {
  let i = m - 1
  let j = n - 1
  let k = m + n - 1
  while (j >= 0) {
    if (i >= 0 && nums1[i] > nums2[j]) {
      nums1[k] = nums1[i]
      i--
    } else {
      nums1[k] = nums2[j]
      j--
    }
    k--
  }
}
''',
  },

  // Decode Ways — one-dimensional DP over the two previous counts.
  33: <EditorLanguage, String>{
    EditorLanguage.python: '''
def numDecodings(s):
    if len(s) == 0 or s[0] == "0":
        return 0
    two_back = 1
    one_back = 1
    for i in range(1, len(s)):
        current = 0
        if s[i] != "0":
            current += one_back
        pair = int(s[i - 1:i + 1])
        if pair >= 10 and pair <= 26:
            current += two_back
        two_back = one_back
        one_back = current
    return one_back
''',
    EditorLanguage.javascript: '''
function numDecodings(s) {
  if (s.length === 0 || s[0] === "0") return 0
  let twoBack = 1
  let oneBack = 1
  for (let i = 1; i < s.length; i++) {
    let current = 0
    if (s[i] !== "0") current += oneBack
    const pair = parseInt(s.substring(i - 1, i + 1))
    if (pair >= 10 && pair <= 26) current += twoBack
    twoBack = oneBack
    oneBack = current
  }
  return oneBack
}
''',
  },

  // Word Ladder — breadth-first search over one-letter edits.
  47: <EditorLanguage, String>{
    EditorLanguage.python: '''
def ladderLength(beginWord, endWord, wordList):
    words = set(wordList)
    if endWord not in words:
        return 0
    letters = "abcdefghijklmnopqrstuvwxyz"
    frontier = [beginWord]
    seen = set([beginWord])
    steps = 1
    while len(frontier) > 0:
        nxt = []
        for word in frontier:
            if word == endWord:
                return steps
            for i in range(len(word)):
                for c in letters:
                    candidate = word[:i] + c + word[i + 1:]
                    if candidate in words and candidate not in seen:
                        seen.add(candidate)
                        nxt.append(candidate)
        frontier = nxt
        steps += 1
    return 0
''',
    EditorLanguage.javascript: '''
function ladderLength(beginWord, endWord, wordList) {
  const words = new Set(wordList)
  if (!words.has(endWord)) return 0
  const letters = "abcdefghijklmnopqrstuvwxyz"
  let frontier = [beginWord]
  const seen = new Set([beginWord])
  let steps = 1
  while (frontier.length > 0) {
    const next = []
    for (const word of frontier) {
      if (word === endWord) return steps
      for (let i = 0; i < word.length; i++) {
        for (const c of letters) {
          const candidate = word.substring(0, i) + c + word.substring(i + 1)
          if (words.has(candidate) && !seen.has(candidate)) {
            seen.add(candidate)
            next.push(candidate)
          }
        }
      }
    }
    frontier = next
    steps++
  }
  return 0
}
''',
  },

  // Longest Consecutive Sequence — only start counting from a run's head.
  48: <EditorLanguage, String>{
    EditorLanguage.python: '''
def longestConsecutive(nums):
    values = set(nums)
    best = 0
    for n in values:
        if n - 1 not in values:
            length = 1
            current = n
            while current + 1 in values:
                current += 1
                length += 1
            best = max(best, length)
    return best
''',
    EditorLanguage.javascript: '''
function longestConsecutive(nums) {
  const values = new Set(nums)
  let best = 0
  for (const n of values) {
    if (!values.has(n - 1)) {
      let length = 1
      let current = n
      while (values.has(current + 1)) {
        current++
        length++
      }
      best = Math.max(best, length)
    }
  }
  return best
}
''',
  },

  // Palindrome Partitioning — backtracking with a palindrome check.
  49: <EditorLanguage, String>{
    EditorLanguage.python: '''
def partition(s):
    out = []

    def is_palindrome(left, right):
        while left < right:
            if s[left] != s[right]:
                return False
            left += 1
            right -= 1
        return True

    def build(start, chosen):
        if start == len(s):
            out.append(list(chosen))
            return
        for end in range(start, len(s)):
            if is_palindrome(start, end):
                chosen.append(s[start:end + 1])
                build(end + 1, chosen)
                chosen.pop()

    build(0, [])
    return out
''',
    EditorLanguage.javascript: '''
function partition(s) {
  const out = []
  function isPalindrome(left, right) {
    while (left < right) {
      if (s[left] !== s[right]) return false
      left++
      right--
    }
    return true
  }
  function build(start, chosen) {
    if (start === s.length) {
      out.push([...chosen])
      return
    }
    for (let end = start; end < s.length; end++) {
      if (isPalindrome(start, end)) {
        chosen.push(s.substring(start, end + 1))
        build(end + 1, chosen)
        chosen.pop()
      }
    }
  }
  build(0, [])
  return out
}
''',
  },

  // Gas Station — a single greedy sweep.
  51: <EditorLanguage, String>{
    EditorLanguage.python: '''
def canCompleteCircuit(gas, cost):
    total = 0
    tank = 0
    start = 0
    for i in range(len(gas)):
        diff = gas[i] - cost[i]
        total += diff
        tank += diff
        if tank < 0:
            start = i + 1
            tank = 0
    if total < 0:
        return -1
    return start
''',
    EditorLanguage.javascript: '''
function canCompleteCircuit(gas, cost) {
  let total = 0
  let tank = 0
  let start = 0
  for (let i = 0; i < gas.length; i++) {
    const diff = gas[i] - cost[i]
    total += diff
    tank += diff
    if (tank < 0) {
      start = i + 1
      tank = 0
    }
  }
  return total < 0 ? -1 : start
}
''',
  },

  // Single Number — counting, since the engine has no bitwise operators.
  52: <EditorLanguage, String>{
    EditorLanguage.python: '''
def singleNumber(nums):
    counts = {}
    for n in nums:
        counts[n] = counts.get(n, 0) + 1
    for n in counts:
        if counts[n] == 1:
            return n
    return -1
''',
    EditorLanguage.javascript: '''
function singleNumber(nums) {
  const counts = new Map()
  for (const n of nums) counts.set(n, (counts.get(n) ?? 0) + 1)
  for (const n of counts.keys()) {
    if (counts.get(n) === 1) return n
  }
  return -1
}
''',
  },

  // Word Break — reachability DP over prefix lengths.
  53: <EditorLanguage, String>{
    EditorLanguage.python: '''
def wordBreak(s, wordDict):
    words = set(wordDict)
    reachable = [False] * (len(s) + 1)
    reachable[0] = True
    for end in range(1, len(s) + 1):
        for start in range(end):
            if reachable[start] and s[start:end] in words:
                reachable[end] = True
                break
    return reachable[len(s)]
''',
    EditorLanguage.javascript: '''
function wordBreak(s, wordDict) {
  const words = new Set(wordDict)
  const reachable = new Array(s.length + 1).fill(false)
  reachable[0] = true
  for (let end = 1; end <= s.length; end++) {
    for (let start = 0; start < end; start++) {
      if (reachable[start] && words.has(s.substring(start, end))) {
        reachable[end] = true
        break
      }
    }
  }
  return reachable[s.length]
}
''',
  },

  // Linked List Cycle — the list is given as next-index pointers.
  54: <EditorLanguage, String>{
    EditorLanguage.python: '''
def hasCycle(next):
    seen = set()
    current = 0
    while current != -1 and current < len(next):
        if current in seen:
            return True
        seen.add(current)
        current = next[current]
    return False
''',
    EditorLanguage.javascript: '''
function hasCycle(next) {
  const seen = new Set()
  let current = 0
  while (current !== -1 && current < next.length) {
    if (seen.has(current)) return true
    seen.add(current)
    current = next[current]
  }
  return false
}
''',
  },

  // Evaluate Reverse Polish Notation — a stack, with division truncating
  // toward zero rather than flooring.
  57: <EditorLanguage, String>{
    EditorLanguage.python: '''
def evalRPN(tokens):
    stack = []
    for token in tokens:
        if token == "+" or token == "-" or token == "*" or token == "/":
            right = stack.pop()
            left = stack.pop()
            if token == "+":
                stack.append(left + right)
            elif token == "-":
                stack.append(left - right)
            elif token == "*":
                stack.append(left * right)
            else:
                stack.append(int(left / right))
        else:
            stack.append(int(token))
    return stack.pop()
''',
    EditorLanguage.javascript: '''
function evalRPN(tokens) {
  const stack = []
  for (const token of tokens) {
    if (token === "+" || token === "-" || token === "*" || token === "/") {
      const right = stack.pop()
      const left = stack.pop()
      if (token === "+") stack.push(left + right)
      else if (token === "-") stack.push(left - right)
      else if (token === "*") stack.push(left * right)
      else stack.push(Math.trunc(left / right))
    } else {
      stack.push(parseInt(token))
    }
  }
  return stack.pop()
}
''',
  },

  // Maximum Product Subarray — carry both the best and the worst product.
  58: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxProduct(nums):
    best = nums[0]
    high = nums[0]
    low = nums[0]
    for i in range(1, len(nums)):
        n = nums[i]
        candidates = [n, high * n, low * n]
        high = max(candidates)
        low = min(candidates)
        best = max(best, high)
    return best
''',
    EditorLanguage.javascript: '''
function maxProduct(nums) {
  let best = nums[0]
  let high = nums[0]
  let low = nums[0]
  for (let i = 1; i < nums.length; i++) {
    const n = nums[i]
    const a = high * n
    const b = low * n
    high = Math.max(n, Math.max(a, b))
    low = Math.min(n, Math.min(a, b))
    best = Math.max(best, high)
  }
  return best
}
''',
  },

  // Find Minimum in Rotated Sorted Array — binary search for the pivot.
  59: <EditorLanguage, String>{
    EditorLanguage.python: '''
def findMin(nums):
    low = 0
    high = len(nums) - 1
    while low < high:
        mid = (low + high) // 2
        if nums[mid] > nums[high]:
            low = mid + 1
        else:
            high = mid
    return nums[low]
''',
    EditorLanguage.javascript: '''
function findMin(nums) {
  let low = 0
  let high = nums.length - 1
  while (low < high) {
    const mid = Math.floor((low + high) / 2)
    if (nums[mid] > nums[high]) low = mid + 1
    else high = mid
  }
  return nums[low]
}
''',
  },

  // Majority Element — Boyer-Moore voting.
  61: <EditorLanguage, String>{
    EditorLanguage.python: '''
def majorityElement(nums):
    candidate = nums[0]
    count = 0
    for n in nums:
        if count == 0:
            candidate = n
            count = 1
        elif n == candidate:
            count += 1
        else:
            count -= 1
    return candidate
''',
    EditorLanguage.javascript: '''
function majorityElement(nums) {
  let candidate = nums[0]
  let count = 0
  for (const n of nums) {
    if (count === 0) {
      candidate = n
      count = 1
    } else if (n === candidate) {
      count++
    } else {
      count--
    }
  }
  return candidate
}
''',
  },

  // Number of 1 Bits — by division, since the engine has no bitwise operators.
  62: <EditorLanguage, String>{
    EditorLanguage.python: '''
def hammingWeight(n):
    count = 0
    while n > 0:
        count += n % 2
        n = n // 2
    return count
''',
    EditorLanguage.javascript: '''
function hammingWeight(n) {
  let count = 0
  let rest = n
  while (rest > 0) {
    count += rest % 2
    rest = Math.floor(rest / 2)
  }
  return count
}
''',
  },

  // House Robber — rolling two-state DP.
  63: <EditorLanguage, String>{
    EditorLanguage.python: '''
def rob(nums):
    skip = 0
    take = 0
    for n in nums:
        new_take = skip + n
        skip = max(skip, take)
        take = new_take
    return max(skip, take)
''',
    EditorLanguage.javascript: '''
function rob(nums) {
  let skip = 0
  let take = 0
  for (const n of nums) {
    const newTake = skip + n
    skip = Math.max(skip, take)
    take = newTake
  }
  return Math.max(skip, take)
}
''',
  },

  // Number of Islands — flood fill, marking visited land on the grid.
  65: <EditorLanguage, String>{
    EditorLanguage.python: '''
def numIslands(grid):
    rows = len(grid)
    if rows == 0:
        return 0
    cols = len(grid[0])

    def sink(r, c):
        if r < 0 or c < 0 or r >= rows or c >= cols:
            return
        if grid[r][c] != "1":
            return
        grid[r][c] = "0"
        sink(r + 1, c)
        sink(r - 1, c)
        sink(r, c + 1)
        sink(r, c - 1)

    count = 0
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == "1":
                count += 1
                sink(r, c)
    return count
''',
    EditorLanguage.javascript: '''
function numIslands(grid) {
  const rows = grid.length
  if (rows === 0) return 0
  const cols = grid[0].length
  function sink(r, c) {
    if (r < 0 || c < 0 || r >= rows || c >= cols) return
    if (grid[r][c] !== "1") return
    grid[r][c] = "0"
    sink(r + 1, c)
    sink(r - 1, c)
    sink(r, c + 1)
    sink(r, c - 1)
  }
  let count = 0
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (grid[r][c] === "1") {
        count++
        sink(r, c)
      }
    }
  }
  return count
}
''',
  },

  // Course Schedule — Kahn's algorithm; a cycle leaves courses unfinished.
  66: <EditorLanguage, String>{
    EditorLanguage.python: '''
def canFinish(numCourses, prerequisites):
    after = {}
    indegree = [0] * numCourses
    for pair in prerequisites:
        course = pair[0]
        needs = pair[1]
        if needs not in after:
            after[needs] = []
        after[needs].append(course)
        indegree[course] += 1
    queue = []
    for c in range(numCourses):
        if indegree[c] == 0:
            queue.append(c)
    done = 0
    head = 0
    while head < len(queue):
        course = queue[head]
        head += 1
        done += 1
        for nxt in after.get(course, []):
            indegree[nxt] -= 1
            if indegree[nxt] == 0:
                queue.append(nxt)
    return done == numCourses
''',
    EditorLanguage.javascript: '''
function canFinish(numCourses, prerequisites) {
  const after = new Map()
  const indegree = new Array(numCourses).fill(0)
  for (const pair of prerequisites) {
    const course = pair[0]
    const needs = pair[1]
    if (!after.has(needs)) after.set(needs, [])
    after.get(needs).push(course)
    indegree[course]++
  }
  const queue = []
  for (let c = 0; c < numCourses; c++) {
    if (indegree[c] === 0) queue.push(c)
  }
  let done = 0
  let head = 0
  while (head < queue.length) {
    const course = queue[head]
    head++
    done++
    for (const next of after.get(course) ?? []) {
      indegree[next]--
      if (indegree[next] === 0) queue.push(next)
    }
  }
  return done === numCourses
}
''',
  },

  // Minimum Size Subarray Sum — shrinking window.
  67: <EditorLanguage, String>{
    EditorLanguage.python: '''
def minSubArrayLen(target, nums):
    best = -1
    total = 0
    left = 0
    for right in range(len(nums)):
        total += nums[right]
        while total >= target:
            length = right - left + 1
            if best == -1 or length < best:
                best = length
            total -= nums[left]
            left += 1
    if best == -1:
        return 0
    return best
''',
    EditorLanguage.javascript: '''
function minSubArrayLen(target, nums) {
  let best = -1
  let total = 0
  let left = 0
  for (let right = 0; right < nums.length; right++) {
    total += nums[right]
    while (total >= target) {
      const length = right - left + 1
      if (best === -1 || length < best) best = length
      total -= nums[left]
      left++
    }
  }
  return best === -1 ? 0 : best
}
''',
  },

  // Course Schedule II — the same sweep, keeping the order it finished in.
  68: <EditorLanguage, String>{
    EditorLanguage.python: '''
def findOrder(numCourses, prerequisites):
    after = {}
    indegree = [0] * numCourses
    for pair in prerequisites:
        course = pair[0]
        needs = pair[1]
        if needs not in after:
            after[needs] = []
        after[needs].append(course)
        indegree[course] += 1
    order = []
    for c in range(numCourses):
        if indegree[c] == 0:
            order.append(c)
    head = 0
    while head < len(order):
        course = order[head]
        head += 1
        for nxt in after.get(course, []):
            indegree[nxt] -= 1
            if indegree[nxt] == 0:
                order.append(nxt)
    if len(order) != numCourses:
        return []
    return order
''',
    EditorLanguage.javascript: '''
function findOrder(numCourses, prerequisites) {
  const after = new Map()
  const indegree = new Array(numCourses).fill(0)
  for (const pair of prerequisites) {
    const course = pair[0]
    const needs = pair[1]
    if (!after.has(needs)) after.set(needs, [])
    after.get(needs).push(course)
    indegree[course]++
  }
  const order = []
  for (let c = 0; c < numCourses; c++) {
    if (indegree[c] === 0) order.push(c)
  }
  let head = 0
  while (head < order.length) {
    const course = order[head]
    head++
    for (const next of after.get(course) ?? []) {
      indegree[next]--
      if (indegree[next] === 0) order.push(next)
    }
  }
  return order.length === numCourses ? order : []
}
''',
  },

  // House Robber II — the street is a circle, so run the line twice.
  69: <EditorLanguage, String>{
    EditorLanguage.python: '''
def rob(nums):
    if len(nums) == 1:
        return nums[0]

    def line(values):
        skip = 0
        take = 0
        for n in values:
            new_take = skip + n
            skip = max(skip, take)
            take = new_take
        return max(skip, take)

    return max(line(nums[1:]), line(nums[:len(nums) - 1]))
''',
    EditorLanguage.javascript: '''
function rob(nums) {
  if (nums.length === 1) return nums[0]
  function line(values) {
    let skip = 0
    let take = 0
    for (const n of values) {
      const newTake = skip + n
      skip = Math.max(skip, take)
      take = newTake
    }
    return Math.max(skip, take)
  }
  return Math.max(line(nums.slice(1)), line(nums.slice(0, nums.length - 1)))
}
''',
  },

  // Kth Largest Element in an Array — sort and index.
  70: <EditorLanguage, String>{
    EditorLanguage.python: '''
def findKthLargest(nums, k):
    ordered = sorted(nums)
    return ordered[len(ordered) - k]
''',
    EditorLanguage.javascript: '''
function findKthLargest(nums, k) {
  const ordered = [...nums].sort((a, b) => a - b)
  return ordered[ordered.length - k]
}
''',
  },

  // Sliding Window Maximum — a monotonic deque of indices.
  77: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxSlidingWindow(nums, k):
    out = []
    window = []
    for i in range(len(nums)):
        while len(window) > 0 and window[0] <= i - k:
            window.pop(0)
        while len(window) > 0 and nums[window[len(window) - 1]] <= nums[i]:
            window.pop()
        window.append(i)
        if i >= k - 1:
            out.append(nums[window[0]])
    return out
''',
    EditorLanguage.javascript: '''
function maxSlidingWindow(nums, k) {
  const out = []
  const window = []
  for (let i = 0; i < nums.length; i++) {
    while (window.length > 0 && window[0] <= i - k) window.shift()
    while (window.length > 0 && nums[window[window.length - 1]] <= nums[i]) window.pop()
    window.push(i)
    if (i >= k - 1) out.push(nums[window[0]])
  }
  return out
}
''',
  },

  // Missing Number — compare against the full sum.
  79: <EditorLanguage, String>{
    EditorLanguage.python: '''
def missingNumber(nums):
    n = len(nums)
    return n * (n + 1) // 2 - sum(nums)
''',
    EditorLanguage.javascript: '''
function missingNumber(nums) {
  const n = nums.length
  let total = 0
  for (const x of nums) total += x
  return (n * (n + 1)) / 2 - total
}
''',
  },

  // First Bad Version — binary search for the first true.
  80: <EditorLanguage, String>{
    EditorLanguage.python: '''
def firstBadVersion(versions):
    low = 0
    high = len(versions) - 1
    while low < high:
        mid = (low + high) // 2
        if versions[mid]:
            high = mid
        else:
            low = mid + 1
    return low + 1
''',
    EditorLanguage.javascript: '''
function firstBadVersion(versions) {
  let low = 0
  let high = versions.length - 1
  while (low < high) {
    const mid = Math.floor((low + high) / 2)
    if (versions[mid]) high = mid
    else low = mid + 1
  }
  return low + 1
}
''',
  },

  // Longest Increasing Subsequence — quadratic DP, one best length per index.
  83: <EditorLanguage, String>{
    EditorLanguage.python: '''
def lengthOfLIS(nums):
    if len(nums) == 0:
        return 0
    best = [1] * len(nums)
    for i in range(len(nums)):
        for j in range(i):
            if nums[j] < nums[i] and best[j] + 1 > best[i]:
                best[i] = best[j] + 1
    return max(best)
''',
    EditorLanguage.javascript: '''
function lengthOfLIS(nums) {
  if (nums.length === 0) return 0
  const best = new Array(nums.length).fill(1)
  let answer = 1
  for (let i = 0; i < nums.length; i++) {
    for (let j = 0; j < i; j++) {
      if (nums[j] < nums[i] && best[j] + 1 > best[i]) best[i] = best[j] + 1
    }
    answer = Math.max(answer, best[i])
  }
  return answer
}
''',
  },

  // Coin Change — unbounded knapsack over amounts.
  84: <EditorLanguage, String>{
    EditorLanguage.python: '''
def coinChange(coins, amount):
    unreachable = amount + 1
    fewest = [unreachable] * (amount + 1)
    fewest[0] = 0
    for value in range(1, amount + 1):
        for coin in coins:
            if coin <= value and fewest[value - coin] + 1 < fewest[value]:
                fewest[value] = fewest[value - coin] + 1
    if fewest[amount] == unreachable:
        return -1
    return fewest[amount]
''',
    EditorLanguage.javascript: '''
function coinChange(coins, amount) {
  const unreachable = amount + 1
  const fewest = new Array(amount + 1).fill(unreachable)
  fewest[0] = 0
  for (let value = 1; value <= amount; value++) {
    for (const coin of coins) {
      if (coin <= value && fewest[value - coin] + 1 < fewest[value]) {
        fewest[value] = fewest[value - coin] + 1
      }
    }
  }
  return fewest[amount] === unreachable ? -1 : fewest[amount]
}
''',
  },

  // Reverse String — two pointers, in place.
  85: <EditorLanguage, String>{
    EditorLanguage.python: '''
def reverseString(s):
    left = 0
    right = len(s) - 1
    while left < right:
        s[left], s[right] = s[right], s[left]
        left += 1
        right -= 1
''',
    EditorLanguage.javascript: '''
function reverseString(s) {
  let left = 0
  let right = s.length - 1
  while (left < right) {
    const keep = s[left]
    s[left] = s[right]
    s[right] = keep
    left++
    right--
  }
}
''',
  },

  // Top K Frequent Elements — count, then sort the distinct values by count.
  86: <EditorLanguage, String>{
    EditorLanguage.python: '''
def topKFrequent(nums, k):
    counts = {}
    for n in nums:
        counts[n] = counts.get(n, 0) + 1
    distinct = list(counts.keys())
    distinct.sort(key=lambda value: -counts[value])
    return distinct[:k]
''',
    EditorLanguage.javascript: '''
function topKFrequent(nums, k) {
  const counts = new Map()
  for (const n of nums) counts.set(n, (counts.get(n) ?? 0) + 1)
  const distinct = [...counts.keys()]
  distinct.sort((a, b) => counts.get(b) - counts.get(a))
  return distinct.slice(0, k)
}
''',
  },

  // Partition Equal Subset Sum — subset-sum over reachable halves.
  87: <EditorLanguage, String>{
    EditorLanguage.python: '''
def canPartition(nums):
    total = sum(nums)
    if total % 2 != 0:
        return False
    half = total // 2
    reachable = [False] * (half + 1)
    reachable[0] = True
    for n in nums:
        for value in range(half, n - 1, -1):
            if reachable[value - n]:
                reachable[value] = True
    return reachable[half]
''',
    EditorLanguage.javascript: '''
function canPartition(nums) {
  let total = 0
  for (const n of nums) total += n
  if (total % 2 !== 0) return false
  const half = total / 2
  const reachable = new Array(half + 1).fill(false)
  reachable[0] = true
  for (const n of nums) {
    for (let value = half; value >= n; value--) {
      if (reachable[value - n]) reachable[value] = true
    }
  }
  return reachable[half]
}
''',
  },

  // Pacific Atlantic Water Flow — flood inward from each ocean's edge.
  88: <EditorLanguage, String>{
    EditorLanguage.python: '''
def pacificAtlantic(heights):
    rows = len(heights)
    cols = len(heights[0])

    def flood(starts):
        seen = set()
        stack = list(starts)
        while len(stack) > 0:
            cell = stack.pop()
            r = cell[0]
            c = cell[1]
            if (r, c) in seen:
                continue
            seen.add((r, c))
            steps = [(r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1)]
            for step in steps:
                nr = step[0]
                nc = step[1]
                if nr >= 0 and nc >= 0 and nr < rows and nc < cols:
                    if heights[nr][nc] >= heights[r][c] and (nr, nc) not in seen:
                        stack.append((nr, nc))
        return seen

    pacific_starts = []
    atlantic_starts = []
    for r in range(rows):
        pacific_starts.append((r, 0))
        atlantic_starts.append((r, cols - 1))
    for c in range(cols):
        pacific_starts.append((0, c))
        atlantic_starts.append((rows - 1, c))

    pacific = flood(pacific_starts)
    atlantic = flood(atlantic_starts)
    out = []
    for r in range(rows):
        for c in range(cols):
            if (r, c) in pacific and (r, c) in atlantic:
                out.append([r, c])
    return out
''',
    EditorLanguage.javascript: '''
function pacificAtlantic(heights) {
  const rows = heights.length
  const cols = heights[0].length
  function flood(starts) {
    const seen = new Set()
    const stack = [...starts]
    while (stack.length > 0) {
      const cell = stack.pop()
      const r = cell[0]
      const c = cell[1]
      const key = r * cols + c
      if (seen.has(key)) continue
      seen.add(key)
      const steps = [[r + 1, c], [r - 1, c], [r, c + 1], [r, c - 1]]
      for (const step of steps) {
        const nr = step[0]
        const nc = step[1]
        if (nr >= 0 && nc >= 0 && nr < rows && nc < cols) {
          if (heights[nr][nc] >= heights[r][c] && !seen.has(nr * cols + nc)) {
            stack.push([nr, nc])
          }
        }
      }
    }
    return seen
  }
  const pacificStarts = []
  const atlanticStarts = []
  for (let r = 0; r < rows; r++) {
    pacificStarts.push([r, 0])
    atlanticStarts.push([r, cols - 1])
  }
  for (let c = 0; c < cols; c++) {
    pacificStarts.push([0, c])
    atlanticStarts.push([rows - 1, c])
  }
  const pacific = flood(pacificStarts)
  const atlantic = flood(atlanticStarts)
  const out = []
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const key = r * cols + c
      if (pacific.has(key) && atlantic.has(key)) out.push([r, c])
    }
  }
  return out
}
''',
  },

  // Longest Repeating Character Replacement — window valid while the
  // replacements needed stay within k.
  89: <EditorLanguage, String>{
    EditorLanguage.python: '''
def characterReplacement(s, k):
    counts = {}
    left = 0
    most = 0
    best = 0
    for right in range(len(s)):
        c = s[right]
        counts[c] = counts.get(c, 0) + 1
        most = max(most, counts[c])
        while right - left + 1 - most > k:
            counts[s[left]] -= 1
            left += 1
            most = 0
            for key in counts:
                most = max(most, counts[key])
        best = max(best, right - left + 1)
    return best
''',
    EditorLanguage.javascript: '''
function characterReplacement(s, k) {
  const counts = new Map()
  let left = 0
  let most = 0
  let best = 0
  for (let right = 0; right < s.length; right++) {
    const c = s[right]
    counts.set(c, (counts.get(c) ?? 0) + 1)
    most = Math.max(most, counts.get(c))
    while (right - left + 1 - most > k) {
      counts.set(s[left], counts.get(s[left]) - 1)
      left++
      most = 0
      for (const value of counts.values()) most = Math.max(most, value)
    }
    best = Math.max(best, right - left + 1)
  }
  return best
}
''',
  },

  // Number of Provinces — count connected components of the adjacency matrix.
  91: <EditorLanguage, String>{
    EditorLanguage.python: '''
def findCircleNum(isConnected):
    n = len(isConnected)
    seen = [False] * n
    count = 0
    for start in range(n):
        if seen[start]:
            continue
        count += 1
        stack = [start]
        while len(stack) > 0:
            city = stack.pop()
            if seen[city]:
                continue
            seen[city] = True
            for other in range(n):
                if isConnected[city][other] == 1 and not seen[other]:
                    stack.append(other)
    return count
''',
    EditorLanguage.javascript: '''
function findCircleNum(isConnected) {
  const n = isConnected.length
  const seen = new Array(n).fill(false)
  let count = 0
  for (let start = 0; start < n; start++) {
    if (seen[start]) continue
    count++
    const stack = [start]
    while (stack.length > 0) {
      const city = stack.pop()
      if (seen[city]) continue
      seen[city] = true
      for (let other = 0; other < n; other++) {
        if (isConnected[city][other] === 1 && !seen[other]) stack.push(other)
      }
    }
  }
  return count
}
''',
  },

  // Permutation in String — a fixed-width window of letter counts.
  92: <EditorLanguage, String>{
    EditorLanguage.python: '''
def checkInclusion(s1, s2):
    if len(s1) > len(s2):
        return False

    def counted(text):
        counts = {}
        for c in text:
            counts[c] = counts.get(c, 0) + 1
        return counts

    need = counted(s1)
    window = counted(s2[:len(s1)])
    if window == need:
        return True
    for i in range(len(s1), len(s2)):
        c = s2[i]
        window[c] = window.get(c, 0) + 1
        gone = s2[i - len(s1)]
        window[gone] -= 1
        if window[gone] == 0:
            window.pop(gone)
        if window == need:
            return True
    return False
''',
    EditorLanguage.javascript: '''
function checkInclusion(s1, s2) {
  if (s1.length > s2.length) return false
  function counted(text) {
    const counts = new Map()
    for (const c of text) counts.set(c, (counts.get(c) ?? 0) + 1)
    return counts
  }
  function same(a, b) {
    if (a.size !== b.size) return false
    for (const key of a.keys()) {
      if (a.get(key) !== b.get(key)) return false
    }
    return true
  }
  const need = counted(s1)
  const window = counted(s2.substring(0, s1.length))
  if (same(window, need)) return true
  for (let i = s1.length; i < s2.length; i++) {
    const c = s2[i]
    window.set(c, (window.get(c) ?? 0) + 1)
    const gone = s2[i - s1.length]
    window.set(gone, window.get(gone) - 1)
    if (window.get(gone) === 0) window.delete(gone)
    if (same(window, need)) return true
  }
  return false
}
''',
  },

  // Task Scheduler — the busiest task sets the frame, unless there are more
  // tasks than the frame holds.
  93: <EditorLanguage, String>{
    EditorLanguage.python: '''
def leastInterval(tasks, n):
    counts = {}
    for t in tasks:
        counts[t] = counts.get(t, 0) + 1
    busiest = 0
    for key in counts:
        busiest = max(busiest, counts[key])
    ties = 0
    for key in counts:
        if counts[key] == busiest:
            ties += 1
    frame = (busiest - 1) * (n + 1) + ties
    return max(frame, len(tasks))
''',
    EditorLanguage.javascript: '''
function leastInterval(tasks, n) {
  const counts = new Map()
  for (const t of tasks) counts.set(t, (counts.get(t) ?? 0) + 1)
  let busiest = 0
  for (const value of counts.values()) busiest = Math.max(busiest, value)
  let ties = 0
  for (const value of counts.values()) {
    if (value === busiest) ties++
  }
  const frame = (busiest - 1) * (n + 1) + ties
  return Math.max(frame, tasks.length)
}
''',
  },

  // Redundant Connection — union-find; the first edge that closes a loop wins.
  94: <EditorLanguage, String>{
    EditorLanguage.python: '''
def findRedundantConnection(edges):
    parent = list(range(len(edges) + 1))

    def root(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for edge in edges:
        a = root(edge[0])
        b = root(edge[1])
        if a == b:
            return edge
        parent[a] = b
    return []
''',
    EditorLanguage.javascript: '''
function findRedundantConnection(edges) {
  const parent = []
  for (let i = 0; i <= edges.length; i++) parent.push(i)
  function root(x) {
    let current = x
    while (parent[current] !== current) {
      parent[current] = parent[parent[current]]
      current = parent[current]
    }
    return current
  }
  for (const edge of edges) {
    const a = root(edge[0])
    const b = root(edge[1])
    if (a === b) return edge
    parent[a] = b
  }
  return []
}
''',
  },

  // Binary Search — the plain version.
  95: <EditorLanguage, String>{
    EditorLanguage.python: '''
def search(nums, target):
    low = 0
    high = len(nums) - 1
    while low <= high:
        mid = (low + high) // 2
        if nums[mid] == target:
            return mid
        if nums[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1
''',
    EditorLanguage.javascript: '''
function search(nums, target) {
  let low = 0
  let high = nums.length - 1
  while (low <= high) {
    const mid = Math.floor((low + high) / 2)
    if (nums[mid] === target) return mid
    if (nums[mid] < target) low = mid + 1
    else high = mid - 1
  }
  return -1
}
''',
  },

  // Daily Temperatures — a stack of days still waiting for a warmer one.
  96: <EditorLanguage, String>{
    EditorLanguage.python: '''
def dailyTemperatures(temperatures):
    out = [0] * len(temperatures)
    waiting = []
    for i in range(len(temperatures)):
        while len(waiting) > 0 and temperatures[waiting[len(waiting) - 1]] < temperatures[i]:
            day = waiting.pop()
            out[day] = i - day
        waiting.append(i)
    return out
''',
    EditorLanguage.javascript: '''
function dailyTemperatures(temperatures) {
  const out = new Array(temperatures.length).fill(0)
  const waiting = []
  for (let i = 0; i < temperatures.length; i++) {
    while (waiting.length > 0 && temperatures[waiting[waiting.length - 1]] < temperatures[i]) {
      const day = waiting.pop()
      out[day] = i - day
    }
    waiting.push(i)
  }
  return out
}
''',
  },

  // Network Delay Time — Bellman-Ford relaxation, no heap needed.
  97: <EditorLanguage, String>{
    EditorLanguage.python: '''
def networkDelayTime(times, n, k):
    unreachable = -1
    best = [None] * (n + 1)
    best[k] = 0
    for _ in range(n - 1):
        for edge in times:
            source = edge[0]
            target = edge[1]
            weight = edge[2]
            if best[source] is None:
                continue
            candidate = best[source] + weight
            if best[target] is None or candidate < best[target]:
                best[target] = candidate
    slowest = 0
    for node in range(1, n + 1):
        if best[node] is None:
            return unreachable
        slowest = max(slowest, best[node])
    return slowest
''',
    EditorLanguage.javascript: '''
function networkDelayTime(times, n, k) {
  const best = new Array(n + 1).fill(null)
  best[k] = 0
  for (let round = 1; round < n; round++) {
    for (const edge of times) {
      const source = edge[0]
      const target = edge[1]
      const weight = edge[2]
      if (best[source] === null) continue
      const candidate = best[source] + weight
      if (best[target] === null || candidate < best[target]) best[target] = candidate
    }
  }
  let slowest = 0
  for (let node = 1; node <= n; node++) {
    if (best[node] === null) return -1
    slowest = Math.max(slowest, best[node])
  }
  return slowest
}
''',
  },

  // Koko Eating Bananas — binary search on the answer.
  98: <EditorLanguage, String>{
    EditorLanguage.python: '''
def minEatingSpeed(piles, h):
    low = 1
    high = max(piles)
    while low < high:
        speed = (low + high) // 2
        hours = 0
        for pile in piles:
            hours += (pile + speed - 1) // speed
        if hours <= h:
            high = speed
        else:
            low = speed + 1
    return low
''',
    EditorLanguage.javascript: '''
function minEatingSpeed(piles, h) {
  let low = 1
  let high = 0
  for (const pile of piles) high = Math.max(high, pile)
  while (low < high) {
    const speed = Math.floor((low + high) / 2)
    let hours = 0
    for (const pile of piles) hours += Math.ceil(pile / speed)
    if (hours <= h) high = speed
    else low = speed + 1
  }
  return low
}
''',
  },

  // Rotting Oranges — breadth-first search, one minute per layer.
  99: <EditorLanguage, String>{
    EditorLanguage.python: '''
def orangesRotting(grid):
    rows = len(grid)
    cols = len(grid[0])
    frontier = []
    fresh = 0
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == 2:
                frontier.append([r, c])
            elif grid[r][c] == 1:
                fresh += 1
    minutes = 0
    while len(frontier) > 0 and fresh > 0:
        nxt = []
        for cell in frontier:
            r = cell[0]
            c = cell[1]
            steps = [[r + 1, c], [r - 1, c], [r, c + 1], [r, c - 1]]
            for step in steps:
                nr = step[0]
                nc = step[1]
                if nr >= 0 and nc >= 0 and nr < rows and nc < cols and grid[nr][nc] == 1:
                    grid[nr][nc] = 2
                    fresh -= 1
                    nxt.append([nr, nc])
        frontier = nxt
        minutes += 1
    if fresh > 0:
        return -1
    return minutes
''',
    EditorLanguage.javascript: '''
function orangesRotting(grid) {
  const rows = grid.length
  const cols = grid[0].length
  let frontier = []
  let fresh = 0
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (grid[r][c] === 2) frontier.push([r, c])
      else if (grid[r][c] === 1) fresh++
    }
  }
  let minutes = 0
  while (frontier.length > 0 && fresh > 0) {
    const next = []
    for (const cell of frontier) {
      const r = cell[0]
      const c = cell[1]
      const steps = [[r + 1, c], [r - 1, c], [r, c + 1], [r, c - 1]]
      for (const step of steps) {
        const nr = step[0]
        const nc = step[1]
        if (nr >= 0 && nc >= 0 && nr < rows && nc < cols && grid[nr][nc] === 1) {
          grid[nr][nc] = 2
          fresh--
          next.push([nr, nc])
        }
      }
    }
    frontier = next
    minutes++
  }
  return fresh > 0 ? -1 : minutes
}
''',
  },

  // Longest Common Subsequence — two-dimensional DP on one rolling row.
  100: <EditorLanguage, String>{
    EditorLanguage.python: '''
def longestCommonSubsequence(text1, text2):
    previous = [0] * (len(text2) + 1)
    for i in range(1, len(text1) + 1):
        current = [0] * (len(text2) + 1)
        for j in range(1, len(text2) + 1):
            if text1[i - 1] == text2[j - 1]:
                current[j] = previous[j - 1] + 1
            else:
                current[j] = max(previous[j], current[j - 1])
        previous = current
    return previous[len(text2)]
''',
    EditorLanguage.javascript: '''
function longestCommonSubsequence(text1, text2) {
  let previous = new Array(text2.length + 1).fill(0)
  for (let i = 1; i <= text1.length; i++) {
    const current = new Array(text2.length + 1).fill(0)
    for (let j = 1; j <= text2.length; j++) {
      if (text1[i - 1] === text2[j - 1]) current[j] = previous[j - 1] + 1
      else current[j] = Math.max(previous[j], current[j - 1])
    }
    previous = current
  }
  return previous[text2.length]
}
''',
  },

  // --- Linked lists ---------------------------------------------------

  // Add Two Numbers — digit-by-digit with a carry.
  2: <EditorLanguage, String>{
    EditorLanguage.python: '''
def addTwoNumbers(l1, l2):
    head = ListNode(0)
    tail = head
    carry = 0
    while l1 is not None or l2 is not None or carry > 0:
        total = carry
        if l1 is not None:
            total += l1.val
            l1 = l1.next
        if l2 is not None:
            total += l2.val
            l2 = l2.next
        carry = total // 10
        tail.next = ListNode(total % 10)
        tail = tail.next
    return head.next
''',
    EditorLanguage.javascript: '''
function addTwoNumbers(l1, l2) {
  const head = new ListNode(0)
  let tail = head
  let carry = 0
  while (l1 !== null || l2 !== null || carry > 0) {
    let total = carry
    if (l1 !== null) {
      total += l1.val
      l1 = l1.next
    }
    if (l2 !== null) {
      total += l2.val
      l2 = l2.next
    }
    carry = Math.floor(total / 10)
    tail.next = new ListNode(total % 10)
    tail = tail.next
  }
  return head.next
}
''',
  },

  // Remove Nth Node From End of List — two pointers n apart.
  8: <EditorLanguage, String>{
    EditorLanguage.python: '''
def removeNthFromEnd(head, n):
    guard = ListNode(0)
    guard.next = head
    ahead = guard
    behind = guard
    for _ in range(n):
        ahead = ahead.next
    while ahead.next is not None:
        ahead = ahead.next
        behind = behind.next
    behind.next = behind.next.next
    return guard.next
''',
    EditorLanguage.javascript: '''
function removeNthFromEnd(head, n) {
  const guard = new ListNode(0)
  guard.next = head
  let ahead = guard
  let behind = guard
  for (let i = 0; i < n; i++) ahead = ahead.next
  while (ahead.next !== null) {
    ahead = ahead.next
    behind = behind.next
  }
  behind.next = behind.next.next
  return guard.next
}
''',
  },

  // Merge Two Sorted Lists — splice the smaller head each time.
  10: <EditorLanguage, String>{
    EditorLanguage.python: '''
def mergeTwoLists(list1, list2):
    head = ListNode(0)
    tail = head
    while list1 is not None and list2 is not None:
        if list1.val <= list2.val:
            tail.next = list1
            list1 = list1.next
        else:
            tail.next = list2
            list2 = list2.next
        tail = tail.next
    if list1 is not None:
        tail.next = list1
    else:
        tail.next = list2
    return head.next
''',
    EditorLanguage.javascript: '''
function mergeTwoLists(list1, list2) {
  const head = new ListNode(0)
  let tail = head
  while (list1 !== null && list2 !== null) {
    if (list1.val <= list2.val) {
      tail.next = list1
      list1 = list1.next
    } else {
      tail.next = list2
      list2 = list2.next
    }
    tail = tail.next
  }
  tail.next = list1 !== null ? list1 : list2
  return head.next
}
''',
  },

  // Merge k Sorted Lists — merge them in one at a time.
  12: <EditorLanguage, String>{
    EditorLanguage.python: '''
def mergeKLists(lists):
    def merge(a, b):
        head = ListNode(0)
        tail = head
        while a is not None and b is not None:
            if a.val <= b.val:
                tail.next = a
                a = a.next
            else:
                tail.next = b
                b = b.next
            tail = tail.next
        if a is not None:
            tail.next = a
        else:
            tail.next = b
        return head.next

    merged = None
    for one in lists:
        merged = merge(merged, one)
    return merged
''',
    EditorLanguage.javascript: '''
function mergeKLists(lists) {
  function merge(a, b) {
    const head = new ListNode(0)
    let tail = head
    while (a !== null && b !== null) {
      if (a.val <= b.val) {
        tail.next = a
        a = a.next
      } else {
        tail.next = b
        b = b.next
      }
      tail = tail.next
    }
    tail.next = a !== null ? a : b
    return head.next
  }
  let merged = null
  for (const one of lists) merged = merge(merged, one)
  return merged
}
''',
  },

  // Reorder List — split, reverse the back half, then weave. In place.
  55: <EditorLanguage, String>{
    EditorLanguage.python: '''
def reorderList(head):
    if head is None or head.next is None:
        return
    slow = head
    fast = head
    while fast.next is not None and fast.next.next is not None:
        slow = slow.next
        fast = fast.next.next
    back = slow.next
    slow.next = None
    previous = None
    while back is not None:
        after = back.next
        back.next = previous
        previous = back
        back = after
    front = head
    back = previous
    while back is not None:
        after_front = front.next
        after_back = back.next
        front.next = back
        back.next = after_front
        front = after_front
        back = after_back
''',
    EditorLanguage.javascript: '''
function reorderList(head) {
  if (head === null || head.next === null) return
  let slow = head
  let fast = head
  while (fast.next !== null && fast.next.next !== null) {
    slow = slow.next
    fast = fast.next.next
  }
  let back = slow.next
  slow.next = null
  let previous = null
  while (back !== null) {
    const after = back.next
    back.next = previous
    previous = back
    back = after
  }
  let front = head
  back = previous
  while (back !== null) {
    const afterFront = front.next
    const afterBack = back.next
    front.next = back
    back.next = afterFront
    front = afterFront
    back = afterBack
  }
}
''',
  },

  // --- Binary trees ---------------------------------------------------

  // Validate Binary Search Tree — carry the allowed range down, since a
  // node-vs-children check alone misses a violation further down.
  34: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isValidBST(root):
    def check(node, low, high):
        if node is None:
            return True
        if low is not None and node.val <= low:
            return False
        if high is not None and node.val >= high:
            return False
        return check(node.left, low, node.val) and check(node.right, node.val, high)

    return check(root, None, None)
''',
    EditorLanguage.javascript: '''
function isValidBST(root) {
  function check(node, low, high) {
    if (node === null) return true
    if (low !== null && node.val <= low) return false
    if (high !== null && node.val >= high) return false
    return check(node.left, low, node.val) && check(node.right, node.val, high)
  }
  return check(root, null, null)
}
''',
  },

  // Same Tree — walk both at once.
  35: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isSameTree(p, q):
    if p is None and q is None:
        return True
    if p is None or q is None:
        return False
    if p.val != q.val:
        return False
    return isSameTree(p.left, q.left) and isSameTree(p.right, q.right)
''',
    EditorLanguage.javascript: '''
function isSameTree(p, q) {
  if (p === null && q === null) return true
  if (p === null || q === null) return false
  if (p.val !== q.val) return false
  return isSameTree(p.left, q.left) && isSameTree(p.right, q.right)
}
''',
  },

  // Symmetric Tree — compare the tree against its own mirror.
  36: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isSymmetric(root):
    def mirror(a, b):
        if a is None and b is None:
            return True
        if a is None or b is None:
            return False
        if a.val != b.val:
            return False
        return mirror(a.left, b.right) and mirror(a.right, b.left)

    if root is None:
        return True
    return mirror(root.left, root.right)
''',
    EditorLanguage.javascript: '''
function isSymmetric(root) {
  function mirror(a, b) {
    if (a === null && b === null) return true
    if (a === null || b === null) return false
    if (a.val !== b.val) return false
    return mirror(a.left, b.right) && mirror(a.right, b.left)
  }
  if (root === null) return true
  return mirror(root.left, root.right)
}
''',
  },

  // Binary Tree Level Order Traversal — one frontier per level.
  37: <EditorLanguage, String>{
    EditorLanguage.python: '''
def levelOrder(root):
    if root is None:
        return []
    out = []
    frontier = [root]
    while len(frontier) > 0:
        values = []
        nxt = []
        for node in frontier:
            values.append(node.val)
            if node.left is not None:
                nxt.append(node.left)
            if node.right is not None:
                nxt.append(node.right)
        out.append(values)
        frontier = nxt
    return out
''',
    EditorLanguage.javascript: '''
function levelOrder(root) {
  if (root === null) return []
  const out = []
  let frontier = [root]
  while (frontier.length > 0) {
    const values = []
    const next = []
    for (const node of frontier) {
      values.push(node.val)
      if (node.left !== null) next.push(node.left)
      if (node.right !== null) next.push(node.right)
    }
    out.push(values)
    frontier = next
  }
  return out
}
''',
  },

  // Binary Tree Zigzag Level Order Traversal — the same sweep, reversing
  // every other level.
  38: <EditorLanguage, String>{
    EditorLanguage.python: '''
def zigzagLevelOrder(root):
    if root is None:
        return []
    out = []
    frontier = [root]
    leftToRight = True
    while len(frontier) > 0:
        values = []
        nxt = []
        for node in frontier:
            values.append(node.val)
            if node.left is not None:
                nxt.append(node.left)
            if node.right is not None:
                nxt.append(node.right)
        if not leftToRight:
            values = values[::-1]
        out.append(values)
        frontier = nxt
        leftToRight = not leftToRight
    return out
''',
    EditorLanguage.javascript: '''
function zigzagLevelOrder(root) {
  if (root === null) return []
  const out = []
  let frontier = [root]
  let leftToRight = true
  while (frontier.length > 0) {
    const values = []
    const next = []
    for (const node of frontier) {
      values.push(node.val)
      if (node.left !== null) next.push(node.left)
      if (node.right !== null) next.push(node.right)
    }
    out.push(leftToRight ? values : values.reverse())
    frontier = next
    leftToRight = !leftToRight
  }
  return out
}
''',
  },

  // Maximum Depth of Binary Tree.
  39: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxDepth(root):
    if root is None:
        return 0
    return 1 + max(maxDepth(root.left), maxDepth(root.right))
''',
    EditorLanguage.javascript: '''
function maxDepth(root) {
  if (root === null) return 0
  return 1 + Math.max(maxDepth(root.left), maxDepth(root.right))
}
''',
  },

  // Construct Binary Tree from Preorder and Inorder Traversal — the first
  // preorder value is the root, and inorder says how the rest splits.
  40: <EditorLanguage, String>{
    EditorLanguage.python: '''
def buildTree(preorder, inorder):
    if len(preorder) == 0:
        return None
    rootValue = preorder[0]
    cut = inorder.index(rootValue)
    node = TreeNode(rootValue)
    node.left = buildTree(preorder[1:cut + 1], inorder[:cut])
    node.right = buildTree(preorder[cut + 1:], inorder[cut + 1:])
    return node
''',
    EditorLanguage.javascript: '''
function buildTree(preorder, inorder) {
  if (preorder.length === 0) return null
  const rootValue = preorder[0]
  const cut = inorder.indexOf(rootValue)
  const node = new TreeNode(rootValue)
  node.left = buildTree(preorder.slice(1, cut + 1), inorder.slice(0, cut))
  node.right = buildTree(preorder.slice(cut + 1), inorder.slice(cut + 1))
  return node
}
''',
  },

  // Convert Sorted Array to Binary Search Tree — the lower middle is the
  // root, which is the shape the stored answers were generated from.
  41: <EditorLanguage, String>{
    EditorLanguage.python: '''
def sortedArrayToBST(nums):
    if len(nums) == 0:
        return None
    mid = (len(nums) - 1) // 2
    node = TreeNode(nums[mid])
    node.left = sortedArrayToBST(nums[:mid])
    node.right = sortedArrayToBST(nums[mid + 1:])
    return node
''',
    EditorLanguage.javascript: '''
function sortedArrayToBST(nums) {
  if (nums.length === 0) return null
  const mid = Math.floor((nums.length - 1) / 2)
  const node = new TreeNode(nums[mid])
  node.left = sortedArrayToBST(nums.slice(0, mid))
  node.right = sortedArrayToBST(nums.slice(mid + 1))
  return node
}
''',
  },

  // Balanced Binary Tree — depth and balance in one pass, -1 meaning
  // "already unbalanced below here".
  42: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isBalanced(root):
    def depth(node):
        if node is None:
            return 0
        left = depth(node.left)
        if left == -1:
            return -1
        right = depth(node.right)
        if right == -1:
            return -1
        if abs(left - right) > 1:
            return -1
        return 1 + max(left, right)

    return depth(root) != -1
''',
    EditorLanguage.javascript: '''
function isBalanced(root) {
  function depth(node) {
    if (node === null) return 0
    const left = depth(node.left)
    if (left === -1) return -1
    const right = depth(node.right)
    if (right === -1) return -1
    if (Math.abs(left - right) > 1) return -1
    return 1 + Math.max(left, right)
  }
  return depth(root) !== -1
}
''',
  },

  // Path Sum — root to *leaf*, so an empty child doesn't count as a path.
  43: <EditorLanguage, String>{
    EditorLanguage.python: '''
def hasPathSum(root, targetSum):
    if root is None:
        return False
    if root.left is None and root.right is None:
        return root.val == targetSum
    rest = targetSum - root.val
    return hasPathSum(root.left, rest) or hasPathSum(root.right, rest)
''',
    EditorLanguage.javascript: '''
function hasPathSum(root, targetSum) {
  if (root === null) return false
  if (root.left === null && root.right === null) return root.val === targetSum
  const rest = targetSum - root.val
  return hasPathSum(root.left, rest) || hasPathSum(root.right, rest)
}
''',
  },

  // Binary Tree Maximum Path Sum — each node reports the best downward arm,
  // while the best bend through it is recorded on the side.
  45: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxPathSum(root):
    best = [root.val]

    def arm(node):
        if node is None:
            return 0
        left = max(arm(node.left), 0)
        right = max(arm(node.right), 0)
        if node.val + left + right > best[0]:
            best[0] = node.val + left + right
        return node.val + max(left, right)

    arm(root)
    return best[0]
''',
    EditorLanguage.javascript: '''
function maxPathSum(root) {
  let best = root.val
  function arm(node) {
    if (node === null) return 0
    const left = Math.max(arm(node.left), 0)
    const right = Math.max(arm(node.right), 0)
    if (node.val + left + right > best) best = node.val + left + right
    return node.val + Math.max(left, right)
  }
  arm(root)
  return best
}
''',
  },

  // Binary Tree Right Side View — the last node of every level.
  64: <EditorLanguage, String>{
    EditorLanguage.python: '''
def rightSideView(root):
    if root is None:
        return []
    out = []
    frontier = [root]
    while len(frontier) > 0:
        out.append(frontier[len(frontier) - 1].val)
        nxt = []
        for node in frontier:
            if node.left is not None:
                nxt.append(node.left)
            if node.right is not None:
                nxt.append(node.right)
        frontier = nxt
    return out
''',
    EditorLanguage.javascript: '''
function rightSideView(root) {
  if (root === null) return []
  const out = []
  let frontier = [root]
  while (frontier.length > 0) {
    out.push(frontier[frontier.length - 1].val)
    const next = []
    for (const node of frontier) {
      if (node.left !== null) next.push(node.left)
      if (node.right !== null) next.push(node.right)
    }
    frontier = next
  }
  return out
}
''',
  },

  // Invert Binary Tree — swap the children, all the way down.
  72: <EditorLanguage, String>{
    EditorLanguage.python: '''
def invertTree(root):
    if root is None:
        return None
    root.left, root.right = invertTree(root.right), invertTree(root.left)
    return root
''',
    EditorLanguage.javascript: '''
function invertTree(root) {
  if (root === null) return null
  const left = invertTree(root.left)
  root.left = invertTree(root.right)
  root.right = left
  return root
}
''',
  },

  // Kth Smallest Element in a BST — in-order visits a BST in sorted order.
  73: <EditorLanguage, String>{
    EditorLanguage.python: '''
def kthSmallest(root, k):
    values = []

    def walk(node):
        if node is None:
            return
        walk(node.left)
        values.append(node.val)
        walk(node.right)

    walk(root)
    return values[k - 1]
''',
    EditorLanguage.javascript: '''
function kthSmallest(root, k) {
  const values = []
  function walk(node) {
    if (node === null) return
    walk(node.left)
    values.push(node.val)
    walk(node.right)
  }
  walk(root)
  return values[k - 1]
}
''',
  },

  // Lowest Common Ancestor of a BST — the dataset names the two nodes by
  // their values, so the walk compares against those directly.
  75: <EditorLanguage, String>{
    EditorLanguage.python: '''
def lowestCommonAncestor(root, p, q):
    node = root
    while node is not None:
        if p < node.val and q < node.val:
            node = node.left
        elif p > node.val and q > node.val:
            node = node.right
        else:
            return node
    return None
''',
    EditorLanguage.javascript: '''
function lowestCommonAncestor(root, p, q) {
  let node = root
  while (node !== null) {
    if (p < node.val && q < node.val) node = node.left
    else if (p > node.val && q > node.val) node = node.right
    else return node
  }
  return null
}
''',
  },

  // Diameter of Binary Tree — the widest bend, counted in edges.
  90: <EditorLanguage, String>{
    EditorLanguage.python: '''
def diameterOfBinaryTree(root):
    best = [0]

    def depth(node):
        if node is None:
            return 0
        left = depth(node.left)
        right = depth(node.right)
        if left + right > best[0]:
            best[0] = left + right
        return 1 + max(left, right)

    depth(root)
    return best[0]
''',
    EditorLanguage.javascript: '''
function diameterOfBinaryTree(root) {
  let best = 0
  function depth(node) {
    if (node === null) return 0
    const left = depth(node.left)
    const right = depth(node.right)
    if (left + right > best) best = left + right
    return 1 + Math.max(left, right)
  }
  depth(root)
  return best
}
''',
  },
};
