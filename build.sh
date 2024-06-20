#!/bin/bash
[ ! -d "toolchain" ] && echo  "installing toolchain..." && bash init_clang.sh
export KBUILD_BUILD_USER=ghazzor

PATH=$PWD/toolchain/bin:$PATH
export LLVM_DIR=$PWD/toolchain/bin
export LLVM=1

export ARCH=arm64

if [ -z "$DEVICE" ]; then
export DEVICE=g84
fi

if [[ -z "$1" || "$1" = "-c" ]]; then
echo "Clean Build"
rm -rf out
make distclean
elif [ "$1" = "-d" ]; then
echo "Dirty Build"
else
echo "Error: Set $1 to -c or -d"
exit 1
fi

ARGS='
CC=clang
LD='${LLVM_DIR}/ld.lld'
ARCH=arm64
AR='${LLVM_DIR}/llvm-ar'
NM='${LLVM_DIR}/llvm-nm'
AS='${LLVM_DIR}/llvm-as'
OBJCOPY='${LLVM_DIR}/llvm-objcopy'
OBJDUMP='${LLVM_DIR}/llvm-objdump'
READELF='${LLVM_DIR}/llvm-readelf'
OBJSIZE='${LLVM_DIR}/llvm-size'
STRIP='${LLVM_DIR}/llvm-strip'
LLVM_AR='${LLVM_DIR}/llvm-ar'
LLVM_DIS='${LLVM_DIR}/llvm-dis'
LLVM_NM='${LLVM_DIR}/llvm-nm'
LLVM=1
'

make ${ARGS} O=out ${DEVICE}_defconfig moto.config
make ${ARGS} O=out -j$(nproc)

rm -rf AnyKernel3
cp -r akv3 AnyKernel3
cp out/arch/arm64/boot/Image AnyKernel3/Image
cp -r out/.config AnyKernel3/config
kver=$(make kernelversion)
kmod=$(echo ${kver} | awk -F'.' '{print $3}')
cd AnyKernel3
zip -r9 O_KERNEL.${kmod}_${DEVICE}-${TIME}.zip * -x .git README.md *placeholder
cd ..
