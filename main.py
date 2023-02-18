import sys
import argparse

from module import project, image, hamming, utils, uart

SQUID = ["0000000110000000",
         "0000011111100000",
         "0001111111111000",
         "0011111111111100",
         "0101101111011010",
         "1111111111111111",
         "0011100000011100",
         "0001000000001000"]

SQUID_ARR = ''.join(SQUID)

def Debug():
    uart_serial = uart.UART_Interface(timeout=0.5)
    try:
        while(1):
            nr_lines = 0
            for data in uart_serial.FetchData():
                if nr_lines > 0: project.clean_screen(nr_lines)
                project.write_screen(data)
                nr_lines = len(data.split("\n")) - 1

    except KeyboardInterrupt:
        uart_serial.CleanUp()
        sys.exit(0)

def Start():
    encoder = hamming.HammingEncoder()
    payload = [ encoder.Run(i) for i in utils.image_to_array(SQUID_ARR) ]

    print("ERROR CORRECTION SIMULATION!")
    print("-------------------------------------------------------")
    print("LIVE FEED:")

    application = project.Application(payload)
    application.start()

def GetArgs():
    """docstring for GetArgs"""
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        "-m",
        "--mode",
        default="demo",
        help="mode in which the script runs",
    )

    args = parser.parse_args()
    return args

def main():
    args = GetArgs()
    if args.mode == "debug":
        Debug()
    else:
        Start()

if __name__ == "__main__":
    main()

