import os
import sys
import time
import serial
import random

class UART_Interface():
    def __init__(self, port_name="/dev/ttyUSB0", baudrate=57600, timeout=1.0) -> None:
        self.port_name = port_name
        self.baudrate = baudrate
        self.timeout = timeout
        self.rx_size = 0
        self.ser = serial.Serial(
            port=self.port_name,
            baudrate=self.baudrate,
            timeout=self.timeout,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS
        )

    def TestPort(self):
        try:
            self.ser.open()
            if (self.ser.is_open()):
                print("Port successfully configured!\n\
                        Port Name: {0}\n\
                        Baudrate: {1}".format(self.port_name, self.baudrate))
        except Exception as e:
            print(e)

    def OpenPort(self):
        if (self.ser.is_open):
            self.ser.close()
        self.ser.open()

    def ClosePort(self):
        self.ser.close()

    def FlushInputBuffer(self):
        self.ser.flushInput()

    def SendData(self, data:bytes):
        self.OpenPort()
        self.ser.write(data)
        self.ClosePort()

    def ReceiveData(self):
        self.OpenPort()
        data = self.ser.read()
        self.ClosePort()
        return str(data, 'utf-8')

    def YieldData(self):
        data = ""
        while 1:
            self.OpenPort()
            rdata = self.ser.readlines()
            data = ''.join([ str(d, 'utf-8') for d in rdata ])
            success = ( len(rdata) > 0 )
            self.ClosePort()
            if success: yield data, True
            yield data, False

    def CleanDisplay(self, nr_lines):
        for _ in range(nr_lines):
            sys.stdout.write('\x1b[0G') # cursor to beginning of line
            sys.stdout.write('\x1b[2K') # clear line
            sys.stdout.write('\x1b[1A') # cursor up

    def Display(self):
        for data, success in  self.YieldData():
            if success:
                if self.rx_size > 0:
                    self.CleanDisplay(self.rx_size)
                sys.stdout.write(data)
                self.rx_size = ( len(data.split("\n")) - 1 )

    def TestMode(self, rand=True):
        cnt = 0
        words = ("hello world", "hello ala", "hello daniel")
        prev = time.time()
        try:
            while 1:
                for data, success in  self.YieldData():
                    if success:
                        if self.rx_size > 0:
                            self.CleanDisplay(self.rx_size)
                        sys.stdout.write(data)
                        self.rx_size = ( len(data.split("\n")) - 1 )
                    else:
                        if time.time() - prev > 3:
                            if rand: word = random.choice(words)
                            else: word = words[(cnt)%3]
                            self.SendData(word.encode())
                            prev = time.time()
                            cnt += 1
        except KeyboardInterrupt:
            if (self.ser.is_open):
                self.ser.close()
            print("\r\n\n\
                  \r---------------\n\
                  \rQuit TEST MODE!\n")


    def DebugMode(self):
        try:
            while(1):
                self.Display()
        except KeyboardInterrupt:
            if (self.ser.is_open):
                self.ser.close()
            print("\r\n\n\
                  \r---------------\n\
                  \rQuit DEBUG MODE!\n")


    def ImageMode(self, payload):
        scnt = 0
        cnt = 0
        complete = False
        prev = time.time()
        # hide cursor
        sys.stdout.write('\x1b[?25l')
        try:
            while 1:
                for data, success in  self.YieldData():
                    if success:
                        scnt += 1
                        if self.rx_size > 0:
                            self.CleanDisplay(self.rx_size)
                        sys.stdout.write(data)
                        self.rx_size = ( len(data.split("\n")) - 1 )
                    else:
                        if time.time() - prev > 0.5 and not complete and scnt > 0:
                            print(f"\nSending: {payload[cnt]} ...")
                            sys.stdout.write('\x1b[0G') # cursor to beginning of line
                            sys.stdout.write('\x1b[2A') # cursor up twice
                            self.SendData(payload[cnt].encode())
                            prev = time.time()
                            cnt += 1
                            if cnt == len(payload): complete = True

        except KeyboardInterrupt:
            if (self.ser.is_open):
                self.ser.close()
            print("\r\n\n\
                  \r---------------\n\
                  \rQuit TEST MODE!\n")

        # show cursor
        sys.stdout.write('\x1b[?25h')
