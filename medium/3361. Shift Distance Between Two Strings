class Solution(object):
    def shiftDistance(self, s, t, nextCost, previousCost):
        """
        :type s: str
        :type t: str
        :type nextCost: List[int]
        :type previousCost: List[int]
        :rtype: int
        """
        total_cost = 0
        for i in range(len(s)):
            if s[i] == t[i]:
                continue
            index_s = ord(s[i]) - ord('a')
            index_t = ord(t[i]) - ord('a')
            if index_s < index_t:
                costNext = nextCost[index_s: index_t]
                costPrev = previousCost[:index_s + 1] + previousCost[index_t + 1:]
                total_cost += min(sum(costNext), sum(costPrev))
            elif index_s > index_t:
                costPrev2 = previousCost[index_s: index_t:-1]
                next22 = nextCost[index_s:] + nextCost[:index_t]
                total_cost += min(sum(costPrev2), sum(next22))
        return total_cost