import os
import sys
import subprocess
import argparse

appdir = os.path.dirname(os.path.realpath(__file__))

STACK_PTR_DEF = "0x3FC"

EXPECTED_DIR_STRUCTURE = """ .
├── build-leros-llvm
│   └─── bin
├── leros-lib
│   └─── runtime
└── VelonaCore
    └─── applications <- you are here
         └─── ${TARGET}
"""

def build(target, stackptr):
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
    VerifyDirExists("../VelonaCore.srcs/sources_1/rom_init")
    VerifyDirExists(target)

    # Generate filenames
    exec_fn = target + "/" + target
    bin_fn = exec_fn + ".bin"
    txt_fn = exec_fn + ".txt"

    # Build app using Makefile
    TryCall(["make", "TARGET="+target, "LEROS_STACK_PTR="+stackptr])

    # Extract the raw binary using objcopy
    TryCall(["../../build-leros-llvm/bin/llvm-objcopy",
        "-O",
        "binary",
        exec_fn,
        bin_fn])

    # Convert binary to text (bintotxt.py adds .txt extension)
    TryCall(["python", "bintotxt.py", bin_fn])

    # Move to source folder
    TryCall(["cp", txt_fn, "../VelonaCore.srcs/sources_1/rom_init"])

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("app", help="Name of application to build")
    parser.add_argument("--sp",
        help="Initial stack pointer value, default: " + STACK_PTR_DEF,
        default=STACK_PTR_DEF,
        type=str)

    args = parser.parse_args()

    if args.app == None:
        parser.print_help()
        sys.exit(1)
    
    build(args.app, args.sp)
