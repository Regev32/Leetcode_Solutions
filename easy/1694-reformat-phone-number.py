class Solution:
    def reformatNumber(self, number: str) -> str:
        # remove all spaces and dashes
        number = "".join([digit for digit in number if digit.isdigit()])
        blocks = []
        while len(number) > 4:
            blocks.append(number[:3])
            number = number[3:]
        if len(number) == 4:
            blocks.append(number[:2])
            blocks.append(number[2:])
        else:
            blocks += [number]
        return '-'.join(blocks)