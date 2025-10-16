class Solution:
    def longestArithSeqLength(self, nums: List[int]) -> int:
        difs = [{} for _ in nums]
        for i in range(len(nums)):
            for j in range(i):
                dif = nums[i] - nums[j]
                difs[i][dif] = difs[j].get(dif, 1) + 1
        longest = 0
        for d in difs[1:]:
            longest = max(longest, max(list(d.values())))
        return longest
