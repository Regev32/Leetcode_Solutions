class Solution(object):
    def hasIncreasingSubarrays(self, nums, k):
        """
        :type nums: List[int]
        :type k: int
        :rtype: bool
        """
        num = [nums[i] < nums[i + 1] for i in range(len(nums) - 1)]
        s = sum(num[:2 * k - 1]) - num[k - 1]
        for i in range(len(num) - 2 * k + 1):
            if s == 2 * k - 2:
                return True
            s = s + num[i + k - 1] - num[i + k] + num[i + 2 * k - 1] - num[i]
        return s == 2 * k - 2
