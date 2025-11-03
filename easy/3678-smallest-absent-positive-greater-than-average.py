class Solution(object):
    def smallestAbsent(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        avg = sum(nums) / len(nums)
        avg = max(int(avg) if avg == int(avg) else int(avg) + (1 if avg > 0 else 0), 0)  # round up without math.ceil
        while True:
            avg += 1
            if not avg in nums:
                return avg
