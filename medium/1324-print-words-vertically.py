class Solution(object):
    def printVertically(self, s):
        """
        :type s: str
        :rtype: List[str]
        """
        s = s.split(' ')
        longest = 0
        for word in s:
            longest = max(longest, len(word))

        for i, word in enumerate(s):
            s[i] = word + ' ' * (longest - len(word))

        t = []
        for i in range(longest):
            t.append(''.join([word[i] for word in s]).rstrip())

        return t

# Question is dumb and too easy; try to get rid of all whitespaces:
# Input: s = "CONTEST IS COMING"
# Better output: ['CIC', 'OSO', 'N', 'M', 'T', 'I', 'E', 'N', 'S', 'G', 'T']
