import os
import sys
import subprocess
import argparse

from bintotxt import doBinToTxt

appdir = os.path.dirname(os.path.realpath(__file__))

EXPECTED_DIR_STRUCTURE = """ .
├── build-leros-llvm
│   └─── bin
├── leros-lib
│   └─── runtime
└── VelonaCore
    └─── applications <- you are here
         └─── ${TARGET}
"""

def getSectionSizes(elf):
    """ Decodes a readelf -S output to read the sizes of ELF sections;
    ie. decodes the following output:
    There are 8 section headers, starting at offset 0x235c:

    Section Headers:
    [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            00000000 000000 000000 00      0   0  0
    [ 1] .text             PROGBITS        00000000 001000 0003f2 00  AX  0   0  4
    [ 2] .data             NOBITS          20000000 002000 000000 00  AX  0   0  1
    ...
    """
    headers = subprocess.check_output(["readelf", "-S", elf]).decode('UTF-8')
    sectionSizes = {}
    for line in headers.splitlines():
        line = line.split()
        if line and line[0].startswith('['):
            if line[2].startswith('.'):
                sectionSizes[line[2]] = int(line[6], 16)

    return (headers, sectionSizes)


def buildTarget(target):
    output_files = []
    load_info = ""
    # Ensure we are in the VelonaCore/applications folder
    os.chdir(appdir)

    def VerifyDirExists(dir):
        if not os.path.exists(dir):
            print("Could not find directory: " + appdir + "/" + dir)
            print("Ensure that the following directory structure exists:")
            print(EXPECTED_DIR_STRUCTURE)
            sys.exit(1)

    def TryCall(cmd):
        if subprocess.call(cmd) != 0:
            print(cmd[0] + " command failed, aborting...")
            sys.exit(1)

    # Verify directory layout
    VerifyDirExists("../../" + "build-leros-llvm")
    VerifyDirExists("../../" + "leros-lib")
    VerifyDirExists("../../" + "VelonaCore")
    VerifyDirExists(target)

    # Try to create mem_init folder if not there
    TryCall(["mkdir", "-p", "../VelonaCore.srcs/sources_1/mem_init"])

    # Generate filenames
    elf_fn = target + "/" + target

    textseg_bin_fn = elf_fn + ".bin.text"
    textseg_txt_fn = "../VelonaCore.srcs/sources_1/mem_init/" + "app.text"

    dataseg_bin_fn = elf_fn + ".bin.data"
    dataseg_txt_fn = "../VelonaCore.srcs/sources_1/mem_init/" + "app.data"

    # Build app using Makefile
    TryCall(["make", "TARGET="+target])

    output_files.append(elf_fn)

    # Extract the raw binary segments using objcopy.
    # Before using llvm-objcopy, it must be determined whether a section actually
    # contains information -llvm-objcopy crashes if one tries to objcopy a
    # section which is non-existant or has a size = 0
    (headers, sectionSizes) = getSectionSizes(elf_fn)

    data_section_cmds = []
    if  ".data" in sectionSizes and sectionSizes[".data"] != 0:
        data_section_cmds.append("-j")
        data_section_cmds.append(".data")
    if  ".bss" in sectionSizes and sectionSizes[".bss"] != 0:
        data_section_cmds.append("-j")
        data_section_cmds.append(".bss")

    TryCall(["../../build-leros-llvm/bin/llvm-objcopy",
        "-O", "binary", "-j", ".text", elf_fn, textseg_bin_fn])

    # Convert raw binary to textual binary
    doBinToTxt(textseg_bin_fn, textseg_txt_fn, bytesPerLine=2)
    # cleanup
    TryCall(["rm", "-f", textseg_bin_fn])
    output_files.append(textseg_txt_fn)

    if data_section_cmds:
        TryCall(["../../build-leros-llvm/bin/llvm-objcopy",
            "-O", "binary", *data_section_cmds, elf_fn, dataseg_bin_fn])
        doBinToTxt(dataseg_bin_fn, dataseg_txt_fn, bytesPerLine=4)
        TryCall(["rm", "-f", dataseg_bin_fn])
        output_files.append(dataseg_txt_fn)
    else:
        # A blank file is written to allow for the VHDL sources to stay constant
        print("No .data or .bss section in output .elf file")
        print("Writing blank app.data file")
        with open(dataseg_txt_fn, 'w') as fo:
            fo.write('')

    return (output_files, headers)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("app", help="Name of application to build")
    args = parser.parse_args()

    if args.app == None:
        parser.print_help()
        sys.exit(1)

    target = args.app.replace('/','')
    print(
"============================ VelonaCore Build system ===========================")
    print("Starting build of application: " + target + "\n")

    (output_files, headers) = buildTarget(target)

    print("\nApplication \"" + target + "\" built successfully")
    print("Output files are:")
    for f in output_files:
        print("     " + f)
    print(
"================================================================================")