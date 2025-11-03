class Solution(object):
    def canJump(self, nums):
        """
        :type nums: List[int]
        :rtype: bool
        """
        last_index = len(nums) - 1
        index = 0
        jump = nums[index]

        while index < last_index:
            if jump == 0:
                return False
            max_jump = 0
            dill = 0
            current_index = index
            for i, possible_jump in enumerate(nums[index + 1:index + jump + 1]):
                if index + jump >= last_index:
                    return True
                if i  - dill > max_jump:
                    max_jump = 0
                    dill = i
                if possible_jump >= max_jump:
                    if possible_jump == 0:
                        continue
                    index = current_index + i + 1
                    jump = possible_jump
                    max_jump = possible_jump
            if max_jump == 0:
                return False
        return True

## more elegant solution (O(n) instead of O(n^2)):
# far = 0
# last = len(nums) - 1
# for i, jump in enumerate(nums):
#     if i > far:
#         return False
#     far = max(far, i + jump)
#     if far >= last:
#         return True
