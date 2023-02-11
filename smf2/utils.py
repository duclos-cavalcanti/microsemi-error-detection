from typing import List
import sys

def image_to_array(image: str) -> List[str]:
    i = 0
    arr = []
    for i in range(0, len(image), 11):
        arr.append(image[i:i+11])
    arr[-1] += '0' * (11 - len(arr[-1]))
    return arr


def print_hamming_trafo(squid, image, enc_image) -> None:
    print("IMAGE\t\t\tARRANGED IMAGE\t\tENC ARRANGED IMAGE")
    for idx, row in enumerate(image):
        # image row
        if idx < len(squid):
            sys.stdout.write(f"{squid[idx]}")
            sys.stdout.write(f"\t")
        else:
            sys.stdout.write(f"\t\t\t")
        # arranged image row
        sys.stdout.write(f"{row}")
        # enc arranged  image row
        sys.stdout.write(f"\t\t")
        for i,c in enumerate(enc_image[idx]):
            clear_prefix='\x1b[0m'
            red_prefix='\x1b[00;31m'
            if i in [0, 1, 2, 4, 8]:
                sys.stdout.write(f"{red_prefix}{c}{clear_prefix}")
            else:
                sys.stdout.write(f"{c}")
        sys.stdout.write(f"\n")

    print("-------------------------------------------------------")



