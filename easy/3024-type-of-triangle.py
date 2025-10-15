class Solution(object):
    def triangleType(self, nums):
        """
        :type nums: List[int]
        :rtype: str
        """
        a, b, c = nums
        if a + b > c and b + c > a and c + a > b:
            if a == b and b == c:
                return "equilateral"
            elif a == b or b == c or c == a:
                return "isosceles"
            else:
                return "scalene"
        return "none"
