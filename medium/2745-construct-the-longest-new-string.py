class Solution:
    def longestString(self, x: int, y: int, z: int) -> int:
        if x == y:
            return 4 * x + 2 * z
        return 4 * min(x, y) + 2 * z + 2