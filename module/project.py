from threading import Thread,Event
from queue import Queue

import re
import sys
import time

from . import uart

def hide_cursor():
    sys.stdout.write('\x1b[?25l')

def show_cursor():
    sys.stdout.write('\x1b[?25h')

def cursor_start():
    sys.stdout.write('\x1b[0G') # cursor to beginning of line

def cursor_up(cnt:int=1):
    for _ in range(cnt):
        sys.stdout.write('\x1b[1A') # cursor up twice

def clean_screen(nr_lines):
    for _ in range(nr_lines):
        sys.stdout.write('\x1b[0G') # cursor to beginning of line
        sys.stdout.write('\x1b[2K') # clear line
        sys.stdout.write('\x1b[1A') # cursor up

def write_screen(data:str):
    sys.stdout.write(f"{data}")

class Project():
    def __init__(self, payload, interval=0.5) -> None:
        self.uart = uart.UART_Interface(timeout=0.5)
        self.payload = payload
        self.interval = interval
        self.thread = Thread(target=self.backend)
        self.queue = Queue()
        self.event = Event()

    def parse(self, state):
        # s = re.compile("STATE")
        pass

    def backend(self):
        p_index = 0
        prev_time = time.time()
        for data in self.uart.FetchData():
            if (len(data.split("\n")) > 3):
                self.queue.put(data)
            if self.event.is_set(): break
            if time.time() - prev_time > self.interval:
                if p_index < len(self.payload):
                    self.uart.SendData(self.payload[p_index].encode())
                    p_index += 1
                prev_time = time.time()
        self.uart.CleanUp()

    def run(self):
        start=time.time()
        nr_lines = 0
        self.thread.start()
        try:
            while 1:
                state = self.queue.get()
                self.parse(state)
                if nr_lines > 0: clean_screen(nr_lines - 1)
                write_screen(state)
                nr_lines = len(state.split("\n"))
                if time.time() - start > 25:
                    break

        except KeyboardInterrupt:
            pass

        self.event.set()
        self.thread.join()
        return

    def start(self):
        hide_cursor()
        self.run()
        show_cursor()
        print("Finished!")
