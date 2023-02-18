import serial

class UART_Interface():
    def __init__(self, port_name="/dev/ttyUSB0", baudrate=57600, timeout=1.0) -> None:
        self.port_name = port_name
        self.baudrate = baudrate
        self.timeout = timeout
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

    def CleanUp(self):
        if (self.ser.is_open):
            self.ser.close()

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

    def FetchData(self):
        for data, success in self.YieldData():
            if success:
                yield data
