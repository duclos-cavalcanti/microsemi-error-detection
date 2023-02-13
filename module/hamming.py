import sys
from typing import List

class HammingEncoder():
    def __init__(self) -> None:
        self.data = []
        self.enc_data = []
        self.enc_bistream = ""

    def TransformArr(self, s) -> List[int]:
        arr = []
        for c in s:
            if c == '1':
                arr.append(1)
            elif c == '0':
                arr.append(0)
            else:
                raise NotImplementedError
        self.data = arr
        return arr

    def TransformStr(self, arr) -> str:
        s = ""
        for d in arr:
            if d == 1:
                s += '1'
            elif d == 0:
                s += '0'
            else:
                raise NotImplementedError
        self.enc_bistream = s
        return self.enc_bistream

    def EncodeDoubleError(self) -> List[int]:
        double_error = 0
        for d in self.enc_data:
            double_error ^= d
        self.enc_data = [ double_error ] + self.enc_data
        return self.enc_data

    def Encode15_11(self, data) -> List[int]:
        p = [ 0, 0, 0, 0 ]
        p[0] = (                                 data[0] ^
                            data[1] ^            data[3] ^
                            data[4] ^            data[6] ^
                            data[8] ^            data [10])

        p[1] = (                                 data[0] ^
                                      data[2]  ^ data[3] ^
                                      data[5]  ^ data[6] ^
                                      data[9]  ^ data[10])

        p[2] = (            data[1] ^ data[2]  ^ data[3] ^

                data [7] ^  data[8] ^ data[9]  ^ data[10])

        p[3] = (
                            data[4] ^ data[5] ^  data[6] ^
                data [7] ^  data[8] ^ data[9] ^  data[10])

        self.enc_data = [p[0], p[1], data[0], p[2]] + data[1:4] + [p[3]] + data[4:]
        return self.enc_data

    def DetectError(self):
        pass

    def Run(self, bitstream:str) -> str:
        self.Encode15_11(self.TransformArr(bitstream))
        self.EncodeDoubleError()
        return self.TransformStr(self.enc_data)


def main():
    pass

if __name__ == "__main__":
    main()
