#!/usr/bin/env bash

 #
 # Script For Building Android Kernel
 #

##----------------------------------------------------------##
# Specify Kernel Directory
KERNEL_DIR="$(pwd)"

##----------------------------------------------------------##
# Device Name and Model
MODEL=Xiaomi
DEVICE=ginkgo

# Kernel Version Code
#VERSION=

# Kernel Defconfig
DEFCONFIG=${DEVICE}-perf_defconfig

# Select LTO variant ( Full LTO by default )
DISABLE_LTO=0
THIN_LTO=1

# Files
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DTBO=$(pwd)/out/arch/arm64/boot/dtbo.img
#DTB=$(pwd)/out/arch/arm64/boot/dts/qcom

# Verbose Build
VERBOSE=0

# Kernel Version
KERVER=$(make kernelversion)

COMMIT_HEAD=$(git log --oneline -1)

# Date and Time
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
TANGGAL=$(date +"%F%S")

# Specify Final Zip Name
ZIPNAME=SUPER.KERNEL
FINAL_ZIP=${ZIPNAME}-${DEVICE}-${TANGGAL}.zip
FINAL_ZIP_ALIAS=Karenulgink-${TANGGAL}.zip

##----------------------------------------------------------##
# Specify compiler.

COMPILER=xrage

##----------------------------------------------------------##
# Specify Linker
LINKER=ld.lld

##----------------------------------------------------------##

##----------------------------------------------------------##
# Clone ToolChain
function cloneTC() {

	if [ $COMPILER = "atomx" ];
	then
	git clone --depth=1 https://gitlab.com/ElectroPerf/atom-x-clang.git clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"
    
    elif [ $COMPILER = "trb" ];
    then
    git clone --depth=1 https://gitlab.com/varunhardgamer/trb_clang.git clang
    PATH="${KERNEL_DIR}/clang/bin:$PATH"
    
    elif [ $COMPILER = "gf" ];
    then
    git clone --depth=1 https://github.com/greenforce-project/clang-llvm.git -b main clang
    PATH="${KERNEL_DIR}/clang/bin:$PATH"
    
    elif [ $COMPILER = "neutron" ];
    then
    #git clone --depth=1 https://github.com/greenforce-project/clang-llvm.git -b main clang
    wget https://github.com/Neutron-Toolchains/clang-build-catalogue/releases/download/11032023/neutron-clang-11032023.tar.zst && mkdir neutron && tar --use-compress-program=unzstd -xvf neutron-clang-11032023.tar.zst -C neutron/
    PATH="${KERNEL_DIR}/neutron/bin:$PATH"
    
    elif [ $COMPILER = "cosmic" ];
    then
    git clone --depth=1 https://gitlab.com/PixelOS-Devices/playgroundtc.git -b 17 cosmic
    PATH="${KERNEL_DIR}/cosmic/bin:$PATH"
    
    elif [ $COMPILER = "cosmic-clang" ];
    then
    git clone --depth=1 https://gitlab.com/GhostMaster69-dev/cosmic-clang.git -b master cosmic-clang
    PATH="${KERNEL_DIR}/cosmic-clang/bin:$PATH"
    
	elif [ $COMPILER = "azure" ];
	then
	git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"

	elif [ $COMPILER = "proton" ];
	then
	git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"
	
	elif [ $COMPILER = "xrage" ];
	then
	git clone --depth=1 https://github.com/xyz-prjkt/xRageTC-clang.git -b main clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"
	
	elif [ $COMPILER = "sdclang" ];
	then
    git clone --depth=1 https://github.com/ZyCromerZ/SDClang.git --single-branch --branch="14" sdclang
	git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git --single-branch --branch="lineage-19.0" gcc
	git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git --single-branch --branch="lineage-19.0" gcc32
	PATH="${KERNEL_DIR}/sdclang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"

	elif [ $COMPILER = "aosp" ];
	then
	wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/7d21a2e4192728bc50841994d88637ccc45b5692/clang-r468909b.tar.gz && mkdir aosp-clang && tar -xzvf clang-r468909b.tar.gz -C aosp-clang/
	export KERNEL_CLANG_PATH="${KERNEL_DIR}/aosp-clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    #CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
    
	git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git -b lineage-19.1 gcc64
	export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-android-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
	
	git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git -b lineage-19.1 gcc32
	export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-androideabi-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
	
	fi
	
	
    # Clone AnyKernel
    git clone --depth=1 https://github.com/missgoin/AnyKernel3.git

	}


##------------------------------------------------------##
# Export Variables
function exports() {
	
        # Export KBUILD_COMPILER_STRING
        if [ -d ${KERNEL_DIR}/clang ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/clang/lib:$LD_LIBRARY_PATH"
           
        elif [ -d ${KERNEL_DIR}/cosmic ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/cosmic/lib:$LD_LIBRARY_PATH"
                       
        elif [ -d ${KERNEL_DIR}/cosmic-clang ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic-clang/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/cosmic-clang/lib:$LD_LIBRARY_PATH"
         
         elif [ -d ${KERNEL_DIR}/neutron ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/neutron/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/neutron/lib:$LD_LIBRARY_PATH"
     
        ##elif [ -d ${KERNEL_DIR}/sdclang ];
           #then
               #export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/sdclang/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')
               #export LD_LIBRARY_PATH="${KERNEL_DIR}/sdclang/lib:$LD_LIBRARY_PATH"
               
        elif [ -d ${KERNEL_DIR}/aosp-clang ];
            then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/aosp-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
        fi
        
        # Export ARCH and SUBARCH
        export ARCH=arm64
        export SUBARCH=arm64
        
        # Export Local Version
        #export LOCALVERSION="-${VERSION}"
        
        # KBUILD HOST and USER
        export KBUILD_BUILD_HOST=Pancali
        export KBUILD_BUILD_USER="unknown"
        
	    export PROCS=$(nproc --all)
	    export DISTRO=$(source /etc/os-release && echo "${NAME}")
	    
	    # Server caching for speed up compile
	    #export LC_ALL=C && export USE_CCACHE=1
	    #ccache -M 100G
	
	}
        
##----------------------------------------------------------------##
# Telegram Bot Integration
##----------------------------------------------------------------##

# Export Configs
function configs() {
    if [ -d ${KERNEL_DIR}/clang ] || [ -d ${KERNEL_DIR}/aosp-clang  ] || [ -d ${KERNEL_DIR}/cosmic-clang  ]; then
       if [ $DISABLE_LTO = "1" ]; then
          sed -i 's/CONFIG_LTO_CLANG=y/# CONFIG_LTO_CLANG is not set/' arch/arm64/configs/${DEFCONFIG}
          sed -i 's/CONFIG_LTO=y/# CONFIG_LTO is not set/' arch/arm64/configs/${DEFCONFIG}
          sed -i 's/# CONFIG_LTO_NONE is not set/CONFIG_LTO_NONE=y/' arch/arm64/configs/${DEFCONFIG}
       elif [ $THIN_LTO = "1" ]; then
          sed -i 's/# CONFIG_THINLTO is not set/CONFIG_THINLTO=y/' arch/arm64/configs/${DEFCONFIG}
       fi
    elif [ -d ${KERNEL_DIR}/gcc64 ]; then
       sed -i 's/CONFIG_LLVM_POLLY=y/# CONFIG_LLVM_POLLY is not set/' arch/arm64/configs/${DEFCONFIG}
       sed -i 's/# CONFIG_GCC_GRAPHITE is not set/CONFIG_GCC_GRAPHITE=y/' arch/arm64/configs/${DEFCONFIG}
       if ! [ $DISABLE_LTO = "1" ]; then
          sed -i 's/# CONFIG_LTO_GCC is not set/CONFIG_LTO_GCC=y/' arch/arm64/configs/${DEFCONFIG}
       fi
    fi
}

# Speed up build process
MAKE="./makeparallel"


##----------------------------------------------------------##
# Compilation
function compile() {
START=$(date +"%s")
		
	# Compile
	make O=out ARCH=arm64 ${DEFCONFIG}

	if [ -d ${KERNEL_DIR}/clang ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	       LD=${LINKER} \
	       #LLVM=1 \
	       #LLVM_IAS=1 \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/cosmic ];
	   then
	       make -j$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
           CROSS_COMPILE=aarch64-linux-gnu- \
           CROSS_COMPILE_ARM32=arm-linux-gnueabi \
           #LLVM=1 \
           #LLVM_IAS=1 \
           #AR=llvm-ar \
           #NM=llvm-nm \
           #LD=${LINKER} \
           #OBJCOPY=llvm-objcopy \
           #OBJDUMP=llvm-objdump \
           #STRIP=llvm-strip \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/cosmic-clang ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	       #LD=${LINKER} \
	       #LLVM=1 \
	       #LLVM_IAS=1 \
	       #AR=llvm-ar \
	       #NM=llvm-nm \
	       #OBJCOPY=llvm-objcopy \
	       #OBJDUMP=llvm-objdump \
	       #STRIP=llvm-strip \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/neutron ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	       #LD=${LINKER} \
	       #LLVM=1 \
	       #LLVM_IAS=1 \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       V=$VERBOSE 2>&1 | tee error.log
	
	elif [ -d ${KERNEL_DIR}/gcc64 ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CROSS_COMPILE_ARM32=arm-eabi- \
	       CROSS_COMPILE=aarch64-elf- \
	       LD=aarch64-elf-${LINKER} \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/sdclang ];
       then
           make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
           #HOSTCC=clang \
	       #HOSTCXX=clang++ \
	       CLANG_TRIPLE=aarch64-linux-gnu- \
	       CROSS_COMPILE=aarch64-linux-android- \
	       CROSS_COMPILE_ARM32=arm-linux-androideabi- \
	       #LD=${LINKER} \
	       #AR=llvm-ar \
	       #NM=llvm-nm \
	       #OBJCOPY=llvm-objcopy \
	       #OBJDUMP=llvm-objdump \
           #STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
    elif [ -d ${KERNEL_DIR}/aosp-clang ];
       then
           make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=$KERNEL_CLANG \
	       CLANG_TRIPLE=aarch64-linux-gnu- \
	       CROSS_COMPILE=$KERNEL_CCOMPILE64 \
	       CROSS_COMPILE_ARM32=$KERNEL_CCOMPILE32 \
	       LD=${LINKER} \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
           STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	fi
	
	echo "**** Verify Image.gz-dtb & dtbo.img ****"
    ls $(pwd)/out/arch/arm64/boot/Image.gz-dtb
    ls $(pwd)/out/arch/arm64/boot/dtbo.img
    
}

##----------------------------------------------------------------##
function zipping() {
	# Copy Files To AnyKernel3 Zip
	cp $IMAGE AnyKernel3
	cp $DTBO AnyKernel3
	#find $DTB -name "*.dtb" -exec cat {} + > AnyKernel3/dtb
	
	# Zipping and Push Kernel
	cd AnyKernel3 || exit 1
        zip -r9 ${FINAL_ZIP_ALIAS} *
        MD5CHECK=$(md5sum "$FINAL_ZIP_ALIAS" | cut -d' ' -f1)
        echo "Zip: $FINAL_ZIP_ALIAS"
        #curl -T $FINAL_ZIP_ALIAS temp.sh; echo
        #curl -T $FINAL_ZIP_ALIAS https://oshi.at; echo
        curl --upload-file $FINAL_ZIP_ALIAS https://free.keep.sh; echo
    cd ..
}

    
##----------------------------------------------------------##

cloneTC
exports
configs
compile
zipping

##----------------*****-----------------------------##