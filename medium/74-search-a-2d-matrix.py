class Solution:
    def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
        m = len(matrix)
        n = len(matrix[0])
        down, up = 0, m - 1
        while down <= up:
            mid = (up + down) // 2
            if matrix[mid][0] <= target <= matrix[mid][n - 1]:
                left, right = 0, n - 1
                while left <= right:
                    middle = (left + right) // 2
                    if matrix[mid][middle] == target:
                        return True
                    elif matrix[mid][middle] < target:
                        left = middle + 1
                    else:
                        right = middle - 1
                return False
            elif matrix[mid][0] > target:
                up = mid - 1
            else:
                down = mid + 1
        return False