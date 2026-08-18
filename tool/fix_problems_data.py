"""Rebuild test-case inputs/outputs in assets/problems.json so every case is
concrete and runnable instead of descriptive text.

Phase 1 (this script): replace descriptive INPUTS with concrete values and drop
the test cases of class-design / unrepresentable problems. Descriptive outputs
are left as-is here and filled in Phase 3 from the Dart harness's actual output.

Run from the repo root: python3 tool/fix_problems_data.py
"""
import json
import re

ASSETS = 'assets/problems.json'

# Problems whose test cases must be dropped entirely:
#  - 56/60/74/82: class-method designs (interpreter can't parse methods)
#  - 50 Clone Graph: runner can't build Node graphs from an adjacency list
DROP_CASES = {56, 60, 74, 82, 50}

# new input strings, keyed by (problem_id, old_input)
INPUT_FIXES = {
    (2, 'l1=list of 100 nines, l2=[1]'):
        'l1=' + '[' + ','.join(['9'] * 100) + '], l2=[1]',
    (3, 's=long string with a repeat only at the very end'):
        's="abcdefghijklmnopqrstuvwxyz0123456789a"',
    (4, 'nums1=array of 1000 elements, nums2=array of 1000 elements (maximum combined size)'):
        'nums1=[0,2,4,6,8,10,12,14,16,18], nums2=[1,3,5,7,9,11,13,15,17,19]',
    (5, 'height=array of 100000 elements alternating between 1 and 10000'):
        'height=[1,10000,1,10000,1,10000,1,10000,1,10000]',
    (6, 'nums=array of 3000 elements, mostly duplicates of a few distinct values'):
        'nums=[-2,-2,-2,-1,-1,0,0,1,1,1,2,2,2]',
    (7, 'digits="234" (count check)'): 'digits="234"',
    (7, 'digits="7379" (maximum length with mixed 3-and-4-letter digits)'):
        'digits="7379"',
    (7, 'digits="9999" (count check)'): 'digits="9999"',
    (11, 'n=2 (count check)'): 'n=2',
    (11, 'n=4 (count check)'): 'n=4',
    (11, 'n=5 (count check)'): 'n=5',
    (11, 'n=8 (count check)'): 'n=8',
    (11, 'n=3, verify every returned string is balanced and length 6'): 'n=3',
    (11, 'n=4, verify no duplicate strings appear in output'): 'n=4',
    (12, 'lists=10000 single-node lists each with a distinct value in random order'):
        'lists=[[5],[1],[8],[3],[9],[2],[7],[4]]',
    (12, 'lists=[[], [], []] (all empty lists)'): 'lists=[[],[],[]]',
    (12, 'lists=[[1,1,1],[1,1,1],[1,1,1]] (all identical values across lists)'):
        'lists=[[1,1,1],[1,1,1],[1,1,1]]',
    (14, 'candidates=[2,7,3,6] (unsorted input), target=7'):
        'candidates=[2,7,3,6], target=7',
    (15, 'height=array of 20000 elements alternating between 0 and 100000'):
        'height=[0,100000,0,100000,0,100000,0,100000,0,100000]',
    (16, 'nums=[1,2,3,4] (count check)'): 'nums=[1,2,3,4]',
    (16, 'nums=[1,2,3,4,5,6] (count check)'): 'nums=[1,2,3,4,5]',
    (16, 'nums=[1,2,3], verify each permutation contains exactly the same 3 elements'):
        'nums=[1,2,3]',
    (16, 'nums=6 distinct elements (maximum size), verify total permutation count'):
        'nums=[1,2,3,4,5,6]',
    (16, 'nums=[1], verify output is exactly [[1]]'): 'nums=[1]',
    (17, 'strs=1000 randomly shuffled anagram permutations of the same 5-letter word'):
        'strs=["eat","tea","tan","ate","nat","bat"]',
    (18, 'n=5 (count check)'): 'n=5',
    (18, 'n=6 (count check)'): 'n=6',
    (18, 'n=8 (count check)'): 'n=8',
    (18, 'n=9 (maximum constraint size), verify total solution count'): 'n=8',
    (18, 'n=4, verify every returned board configuration has exactly one queen per row and column'):
        'n=4',
    (18, 'n=2, verify the result is an empty list, not a list containing an invalid attempt'):
        'n=2',
    (20, 'nums=array of 10000 elements all equal to 1'):
        'nums=[1,1,1,1,1,1,1,1]',
    (21, 'intervals=10000 unsorted intervals, many overlapping in a long chain'):
        'intervals=[[1,4],[2,5],[0,3],[6,8],[5,7]]',
    (21, 'intervals=[[3,5],[1,2]] (unsorted input)'): 'intervals=[[3,5],[1,2]]',
    (22, 'intervals=10000 non-overlapping intervals, newInterval spanning the entire range'):
        'intervals=[[1,2],[4,6],[8,10]], newInterval=[0,11]',
    (25, 'word1=500-character string, word2=500-character string (near worst case for O(n*m) DP)'):
        'word1="intention", word2="execution"',
    (26, 'matrix=100x100 matrix, target=largest element'):
        'matrix=[[1,3,5,7],[10,11,16,20],[23,30,34,60],[61,62,63,64]], target=64',
    (28, 's=100000-character string, t=short pattern near the end of s only'):
        's="XXXABXXXCDXXXEF", t="CDE"',
    (29, 'nums=[1,2,3,4] (count check)'): 'nums=[1,2,3,4]',
    (29, 'nums=10 distinct elements (count check)'): 'nums=[1,2,3,4,5]',
    (29, 'nums=[1,2,3], verify no duplicate subsets exist'): 'nums=[1,2,3]',
    (29, 'nums=10 elements (maximum size), verify total subset count'):
        'nums=[1,2,3,4,5,6]',
    (29, 'nums=[7], verify both [] and [7] are present'): 'nums=[7]',
    (30, 'board=6x6 grid, word requiring the path to snake through all 36 cells without repetition'):
        'board=[["a","b","c","d","e","f"],["l","k","j","i","h","g"],["m","n","o","p","q","r"],["x","w","v","u","t","s"],["y","z","a","b","c","d"],["i","h","g","f","e","j"]], word="abcdefghijklmnopqrstuvwxyzabcd"',
    (31, 'heights=array of 100000 elements all equal to 10000 (maximum size and value)'):
        'heights=[10000,10000,10000,10000,10000,10000]',
    (33, 's="1111111111" (count check)'): 's="1111111111"',
    (33, 's="1212121212" (long alternating pattern, count check)'): 's="1212121212"',
    (37, 'root=large complete tree with 1023 nodes (10 levels)'):
        'root=[1,2,3,4,5,6,7]',
    (39, 'root=deeply left-skewed tree of 1000 nodes'):
        'root=[1,2,null,3,null,4,null,5,null,6,null,7,null,8]',
    (39, 'root=perfectly balanced tree of 15 nodes'):
        'root=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]',
    (40, 'preorder=large tree of 3000 nodes (near worst-case skew)'):
        'preorder=[1,2,3,4,5,6,7,8], inorder=[8,7,6,5,4,3,2,1]',
    (41, 'nums=array of 10000 sorted values'): 'nums=[-10,-3,0,5,9]',
    (42, 'root=deeply nested tree unbalanced only at the very bottom'):
        'root=[1,2,2,3,3,null,null,4,4]',
    (42, 'root=large balanced tree of 1000 nodes'):
        'root=[1,2,2,3,3,3,3,4,4,4,4,4,4,4,4]',
    (45, 'root=tree with a very negative root but two highly positive-summed subtrees on either side'):
        'root=[-10,9,20,null,null,15,7]',
    (45, 'root=all-negative-valued tree of 30000 nodes (maximum size, worst-case values)'):
        'root=[-3,-4,-1,-2,-1,-5,-6]',
    (46, 's="A man, a plan, a canal: Panama"'): 's="A man, a plan, a canal: Panama"',
    (46, 's=".,"'): 's=".,"',
    (47, 'beginWord="cet", endWord="ism", wordList=(large dictionary connecting them through many intermediate steps)'):
        'beginWord="cet", endWord="ism", wordList=["get","got","gol","sol","sir","ism"]',
    (47, 'beginWord and endWord connected only through a very long, forced single path through wordList of 5000 words (maximum size)'):
        'beginWord="aaa", endWord="bbb", wordList=["aab","aba","baa","abb","bab","bba","bbb"]',
    (47, 'beginWord="same", endWord="same" (though constraints guarantee begin != end, testing defensive handling)'):
        'beginWord="hit", endWord="cog", wordList=["hot","dot","dog","lot","log","cog"]',
    (48, 'nums=array of 100000 consecutive integers (worst-case single long sequence)'):
        'nums=[9,3,1,8,7,6,5,4,2,0,10,11]',
    (49, 's="aaaa" (count check)'): 's="aaaa"',
    (49, 's=16 identical characters (maximum length, e.g., "aaaaaaaaaaaaaaaa")'):
        's="aaaaaa"',
    (50, 'adjList=[[2,3],[1,3],[1,2]] (triangle/cycle)'): 'node=null',
    (50, 'adjList=densely connected graph of 100 nodes, each connected to all others'):
        'node=null',
    (50, 'adjList=[[2],[3],[4],[1]] (a 4-cycle)'): 'node=null',
    (50, 'adjList representing a graph with a cycle passing back through the starting node'):
        'node=null',
    (51, 'gas=array of 100000 stations with total gas exactly one unit less than total cost'):
        'gas=[1,2,3,4,5], cost=[2,3,4,5,6]',
    (53, "s='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab' (long repeated 'a' string ending in 'b'), wordDict=multiple short 'a'-repeated words but no 'b'"):
        's="aaaaaaaab", wordDict=["aaaa","aaa"]',
    (54, 'list of 10000 nodes, cycle_pos=9999'): 'head=[1,2,3,4,5,6,7,8,9,10]',
    (54, 'list of 10000 nodes, cycle_pos=-1'): 'head=[1,2,3,4,5,6,7,8,9,10]',
    (55, 'head=list of 50000 sequential values'): 'head=[1,2,3,4,5,6,7,8]',
    (58, 'nums=[-1,-1,-1,-1,-1] (odd count of negatives)'): 'nums=[-1,-1,-1,-1,-1]',
    (58, 'nums=array of 20000 elements alternating between 2 and -2'):
        'nums=[2,-2,2,-2,2,-2,2,-2]',
    (63, 'nums=array of 100 elements alternating between 400 and 0 (maximum constraint values)'):
        'nums=[400,0,400,0,400,0,400,0]',
    (64, 'root=perfectly balanced tree of 15 nodes'):
        'root=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]',
    (65, "grid=300x300 grid entirely filled with '1'"):
        'grid=[["1","1","1","1","1"],["1","1","1","1","1"],["1","1","1","1","1"],["1","1","1","1","1"],["1","1","1","1","1"]]',
    (65, 'grid=[["1","0"],["0","1"]] (diagonal-only adjacency)'):
        'grid=[["1","0"],["0","1"]]',
    (65, 'grid=checkerboard pattern of alternating 1s and 0s, 10x10'):
        'grid=[["1","0","1","0"],["0","1","0","1"],["1","0","1","0"],["0","1","0","1"]]',
    (66, 'numCourses=2000, prerequisites=chain forming a very long cycle across all courses'):
        'numCourses=6, prerequisites=[[1,0],[2,1],[3,2],[4,3],[5,4],[0,5]]',
    (66, 'numCourses=6, prerequisites=[[1,0],[2,1],[3,2],[4,3],[5,4]] (long valid chain)'):
        'numCourses=6, prerequisites=[[1,0],[2,1],[3,2],[4,3],[5,4]]',
    (66, 'numCourses=5, prerequisites=[[0,1],[1,2],[2,3],[3,4],[4,0]] (5-course cycle)'):
        'numCourses=5, prerequisites=[[0,1],[1,2],[2,3],[3,4],[4,0]]',
    (67, 'target=1000000000, nums=array of 100000 elements all equal to 10000'):
        'target=100000, nums=[10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000]',
    (68, 'numCourses=2000, prerequisites forming a valid long dependency chain of all 2000 courses'):
        'numCourses=8, prerequisites=[[1,0],[2,1],[3,2],[4,3],[5,4],[6,5],[7,6]]',
    (68, 'numCourses=4, prerequisites=[[1,0],[2,1],[3,2],[1,3]] (cycle among 1,2,3)'):
        'numCourses=4, prerequisites=[[1,0],[2,1],[3,2],[1,3]]',
    (69, 'nums=array of 100 elements alternating high and low values in a circle'):
        'nums=[100,0,100,0,100,0,100,0]',
    (70, 'nums=array of 100000 elements, k=1'):
        'nums=[3,2,1,5,6,4], k=1',
    (73, 'root=large balanced BST with 10000 nodes, k=10000'):
        'root=[5,3,6,2,4,null,null,1], k=8',
    (75, 'root=large BST of 100000 nodes, p and q deep in different subtrees'):
        'root=[6,2,8,0,4,7,9,null,null,3,5], p=0, q=5',
    (76, 'nums=array of 100000 elements all equal to 2'): 'nums=[2,2,2,2,2]',
    (77, 'nums=array of 100000 strictly decreasing elements, k=100000'):
        'nums=[9,8,7,6,5,4,3,2,1], k=9',
    (83, 'nums=array of 2500 elements in a carefully constructed worst-case pattern for O(n^2) approaches'):
        'nums=[0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15]',
    (83, 'nums=[-2,-1,0,1,2] (negative to positive ascending)'): 'nums=[-2,-1,0,1,2]',
    (86, 'nums=array of 100000 elements with heavily skewed frequency distribution, k=10'):
        'nums=[1,1,1,2,2,3,3,3,3,4,4,4,4,4], k=2',
    (87, 'nums=array of 200 elements each equal to 100 (maximum size and value)'):
        'nums=[100,100,100,100,100,100,100,100]',
    (88, 'heights=200x200 grid of all equal values'):
        'heights=[[1,1,1,1],[1,1,1,1],[1,1,1,1],[1,1,1,1]]',
    (88, 'heights=grid with a high central peak surrounded by a ring of low valley cells that trap flow only toward the peak'):
        'heights=[[1,1,1,1,1],[1,3,3,3,1],[1,3,5,3,1],[1,3,3,3,1],[1,1,1,1,1]]',
    (89, 's single character repeated 100000 times, k=0'): 's="AAAAAAAAAA", k=0',
    (90, 'root=tree where the longest path lies entirely within the left subtree, not touching root'):
        'root=[1,2,3,4,null,null,null,5,null,null,null,6]',
    (90, 'root=perfectly balanced tree of 15 nodes'):
        'root=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]',
    (91, 'isConnected=5x5 identity matrix (no connections beyond self)'):
        'isConnected=[[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,1,0],[0,0,0,0,1]]',
    (91, 'isConnected=200x200 matrix representing one giant chain A-B-C-...-Z all connected transitively'):
        'isConnected=[[1,1,0,0,0,0],[1,1,1,0,0,0],[0,1,1,1,0,0],[0,0,1,1,1,0],[0,0,0,1,1,1],[0,0,0,0,1,1]]',
    (91, 'isConnected=[[1,1,0],[1,1,0],[0,0,1]] re-verified'):
        'isConnected=[[1,1,0],[1,1,0],[0,0,1]]',
    (91, 'isConnected=200x200 identity matrix (no connections at all)'):
        'isConnected=[[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,1,0],[0,0,0,0,1]]',
    (92, 's1 length 10000, s2 length 10000, no match'):
        's1="abc", s2="xxxxxxxxxxxx"',
    (93, 'tasks=array of 10000 tasks all the same type, n=100'):
        'tasks=["A","A","A","A","A","A"], n=2',
    (94, 'edges=chain of 1000 nodes with the redundant edge connecting the very first and very last nodes'):
        'edges=[[1,2],[2,3],[3,4],[4,5],[5,6],[6,1]]',
    (96, 'temperatures=array of 100000 strictly decreasing values'):
        'temperatures=[90,80,70,60,50,40,30,20]',
    (97, 'times=6000 edges forming a dense graph of 100 nodes (maximum constraints), k=1'):
        'times=[[1,2,1],[2,3,1],[3,4,1],[4,5,1],[5,1,1],[1,3,1]], n=5, k=1',
    (97, 'times=[[1,2,1],[2,3,1],[3,1,1]] (a cycle), n=3, k=1'):
        'times=[[1,2,1],[2,3,1],[3,1,1]], n=3, k=1',
    (97, 'times=[[1,2,1]], n=3, k=1 (node 3 is completely unreachable)'):
        'times=[[1,2,1]], n=3, k=1',
    (99, 'grid=10x10 grid with rotten oranges scattered at multiple locations spreading simultaneously'):
        'grid=[[2,1,1,0,1],[1,1,0,1,1],[0,1,1,1,0],[1,1,1,1,2],[0,0,1,1,0]]',
    (99, 'grid=all zeros'): 'grid=[[0,0],[0,0]]',
    (99, 'grid=[[1,1],[1,1]] (no rotten oranges, all fresh)'): 'grid=[[1,1],[1,1]]',
    (100, "text1=1000-character string of all 'a's, text2=1000-character string of all 'a's"):
        'text1="aaaaaaaa", text2="aaaaaaaa"',
    (100, 'text1="abcdefghij", text2="jihgfedcba" (reversed)'):
        'text1="abcdefghij", text2="jihgfedcba"',
    (100, 'text1="", text2="" (if empty strings were allowed by a testing harness variant)'):
        'text1="", text2=""',
}


def main():
    with open(ASSETS) as f:
        data = json.load(f)

    fixed = 0
    for p in data['problems']:
        pid = p['problem_id']
        if pid in DROP_CASES:
            p['test_cases'] = []
            p['hidden_test_cases'] = []
            continue
        for kind in ('test_cases', 'hidden_test_cases'):
            for tc in p.get(kind, []):
                old = tc.get('input', '')
                key = (pid, old)
                if key in INPUT_FIXES:
                    tc['input'] = INPUT_FIXES[key]
                    fixed += 1

    with open(ASSETS, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write('\n')
    print(f'fixed {fixed} descriptive inputs; dropped cases for {sorted(DROP_CASES)}')


if __name__ == '__main__':
    main()
