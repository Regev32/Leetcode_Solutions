class Solution(object):
    def furthestDistanceFromOrigin(self, moves):
        """
        :type moves: str
        :rtype: int
        """
        dash = 0
        dist = 0
        for move in moves:
            if move == '_':
                dash += 1
            elif move == 'R':
                dist += 1
            else:
                dist -= 1
        return abs(dist) + dash
