class Solution:
    def romanToInt(self, s: str) -> int:
        roman = list(s)
        s = 0
        symbol = {
            "I": 1,
            "V": 5,
            "X": 10,
            "L": 50,
            "C": 100,
            "D": 500,
            "M": 1000
        }
        i = 0
        while i < len(roman) - 1:
            if roman[i] == "I":
                if roman[i + 1] == "V":
                    s += 4
                    i += 2
                elif roman[i + 1] == "X":
                    s += 9
                    i += 2
                elif roman[i + 1] == "I":
                    if i + 2 < len(roman):
                        if roman[i + 2] == "I":
                            s += 3
                            i += 3
                        else:
                            s += 2
                            i += 2
                    else:
                        s += 1
                        i += 1
            elif roman[i] == "X":
                if roman[i + 1] == "L":
                    s += 40
                    i += 2
                elif roman[i + 1] == "C":
                    s += 90
                    i += 2
                else:
                    s += 10
                    i += 1
            elif roman[i] == "C":
                if roman[i + 1] == "D":
                    s += 400
                    i += 2
                elif roman[i + 1] == "M":
                    s += 900
                    i += 2
                else:
                    s += 100
                    i += 1
            else:
                s += symbol[roman[i]]
                i += 1

        if i < len(roman):
            s += symbol[roman[-1]]
        return s