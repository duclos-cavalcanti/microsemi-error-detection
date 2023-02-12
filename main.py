import sys
import argparse

from smf2 import image, hamming, utils, uart_serial

def Test():
    uart = uart_serial.UART_Interface(timeout=0.5)
    uart.TestMode(rand=False)

def Debug():
    uart = uart_serial.UART_Interface(timeout=0.5)
    uart.DebugMode()

def Start():
    encoder = hamming.HammingEncoder()
    squid = ["0000000110000000",
             "0000011111100000",
             "0001111111111000",
             "0011111111111100",
             "0101101111011010",
             "1111111111111111",
             "0011100000011100",
             "0001000000001000"]

    image = utils.image_to_array(''.join(squid))
    enc_image = [ encoder.Run(i) for i in image ]

    print("ERROR CORRECTION SIMULATION!")
    print("-------------------------------------------------------")

    print("LIVE FEED:")
    uart = uart_serial.UART_Interface(timeout=0.5)
    uart.ImageMode(payload=enc_image)

def GetArgs():
    """docstring for GetArgs"""
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        "-m",
        "--mode",
        default="image",
        help="mode in which the script runs",
    )

    args = parser.parse_args()
    return args

def main():
    args = GetArgs()
    if args.mode == "image":
        Start()

    elif args.mode == "debug":
        Debug()

    elif args.mode == "test":
        Test()

    else:
        pass

if __name__ == "__main__":
    main()

