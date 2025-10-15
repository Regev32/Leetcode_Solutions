class Solution:
    def setZeroes(self, matrix: List[List[int]]) -> None:
        """
        Do not return anything, modify matrix in-place instead.
        """
        m = len(matrix)
        n = len(matrix[0])
        rows, cols = set(), set()
        for row in range(m):
            for col in range(n):
                if matrix[row][col] == 0:
                    rows.add(row)
                    cols.add(col)
        for row in rows:
            matrix[row] = [0] * n
        for col in cols:
            for row in range(m):
                matrix[row][col] = 0

        # TODO: For O(1) space complexity, store zeros in the first row and column.
