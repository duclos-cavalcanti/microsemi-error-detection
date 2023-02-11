import sys
from vunit import VUnit
from os.path import exists

def tb():
    ut = VUnit.from_argv()

    SRC_FILE = "microsemi/libero/HammingDecoder.vhd"
    TB_FILE = "microsemi/libero/test/tb_HammingDecoder.vhd"

    if exists(SRC_FILE):
        ut.add_library("source").add_source_files(SRC_FILE)
    else:
        print(f"File: {SRC_FILE} doesn't exit!")
        sys.exit(1)


    if exists(TB_FILE):
        ut.add_library("test").add_source_files(TB_FILE)
    else:
        print(f"File: {TB_FILE} doesn't exit!")

    ut.main()

if __name__ == "__main__":
    tb()
