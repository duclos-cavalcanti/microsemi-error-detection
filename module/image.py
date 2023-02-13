import numpy as np
import PIL.Image as PImage

color_map = {'0': (255,255,255),
             '1': (0,0,0)}

SpaceShip_Image_Matrix = {
                        0 : "0000000110000000",
                        1 : "0000011111100000",
                        2 : "0001111111111000",
                        3 : "0011111111111100",
                        4 : "0101101111011010",
                        5 : "1111111111111111",
                        6 : "0011100000011100",
                        7 : "0001000000001000"
                   }

class Image:
    def __init__(self, image_dict) -> None:
        if (self.CheckDict(image_dict)):
            self.image_dict = image_dict
        self.image = PImage.new('RGB', (512, 256), "white")

    def CheckDict(self, image_dict: dict) -> bool:
        """Checks if all Dictionnary values have the same length"""
        result = True
        if (bool(image_dict)):
            return False
        else:
            length = len(image_dict[0])
        for key in image_dict:
            if len(image_dict[key]) != length:
                return False
            else:
                continue
        return result

    def ExpandData(self) -> str:
        value = ""
        for key in SpaceShip_Image_Matrix:
            for i in range(32):
                value = value + SpaceShip_Image_Matrix[key]
        data = []
        for letter in value:
            for i in range(32):
                data.append(color_map[letter])
        self.data = data

    def StoreData(self) -> None:
        self.image.putdata(self.data)

    def Create(self) -> None:
        self.ExpandData()
        self.StoreData()

    def Save(self, path) -> None:
        self.image.save(path)
        self.path = path

    def Show(self) -> None:
        self.image.show()

    def Read(self, path: str) -> str:
        """Read Image from path and return list of bits"""
        result = ""
        im = PImage.open(path)
        p = np.array(im)
        for byte in p.tolist():
            for pix in byte:
                for i in color_map:
                    if color_map[i]==tuple(pix):
                        result = result + str(i)
        return self.ReduceData(result)

    def ReduceData(self, bitarray_exp: str) -> str:
        reduced_row = ""
        for i in range(0, len(bitarray_exp)-1, 32):
            count_1 = bitarray_exp[i:i+32].count('1')
            count_0 = bitarray_exp[i:i+32].count('0')
            if (count_1 == 0):
                reduced_row = reduced_row+'0'
            elif (count_0 == 0):
                reduced_row = reduced_row+'1'
        result = ""
        for i in range(0, len(reduced_row)-1, 512):
            result = result + reduced_row[i:i+512][0:16]
        return result

def prepare():
    image = Image(SpaceShip_Image_Matrix)
    image.Create()
    image.Save("space_ship.bmp")
    return image.Read(image.path)



