class Solution(object):
    def complexNumberMultiply(self, num1, num2):
        """
        :type num1: str
        :type num2: str
        :rtype: str
        """
        a, b = num1.split('+')
        c, d = num2.split('+')

        a = int(a)
        c = int(c)
        b = int(b[:-1])
        d = int(d[:-1])
        return str(a * c - b * d) + "+" + str(a * d + b * c) + "i"
