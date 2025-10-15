class Solution:
    def sortColors(self, nums: List[int]) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        colors = [0, 0, 0]
        for item in nums:
            colors[item] += 1
        nums[:] = [0]*colors[0] + [1]*colors[1] + [2]*colors[2]