class Solution:
    #Xor is commutative.
    #The maximum xor of X and Y is the same as the maximum xor of X and [].
    def maxXorSubsequences(self, nums: List[int]) -> int:
        # initializing basis
        basis = [0] * max(nums).bit_length()

        # reducing all elements in nums
        for num in nums:
            for index in range(len(basis) - 1, -1, -1):
                pivot = basis[index]
                if pivot and (num >> index) & 1:
                    num ^= pivot
            if not num:
                continue
            highest_bit = num.bit_length() - 1
            basis[highest_bit] = num

        # xoring only if not destroying
        result = 0
        for index in range(len(basis) - 1, -1, -1):
            pivot = basis[index]
            if result ^ pivot > result:
                result ^= pivot

        return result