#!/bin/bash
#################################################
####    Build Script v1.0 for Exynos7580     ####
################### Dev name ####################
COSMIC_DEV=SandwichEater
#################### Main Dir ###################
COSMIC_DIR=$(pwd)
############## Define toolchan path #############
COSMIC_TC=/home/moin/Downloads/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
### Define proper arch and dir for dts files ###
COSMIC_DTS=arch/arm64/boot/dts
########### Compiled image location #############
COSMIC_KERNEL=$COSMIC_DIR/arch/arm64/boot/Image
################ Compiled dtb by  ###############
COSMIC_DTB=$COSMIC_DIR/boot.img-dt
################## Thread count #################
COSMIC_JOBS=$((`nproc`-1))
################## Target ARCH ##################
COSMIC_ARCH=arm64
############## Build Requirements ###############
export ARCH=$COSMIC_ARCH
export CROSS_COMPILE=$COSMIC_TC
##### Device specific Variables [SM-J700F] ######
COSMIC_DTSFILES_J700F="
exynos7580-j7e3g_rev00.dtb
exynos7580-j7e3g_rev05.dtb
exynos7580-j7e3g_rev08.dtb
exynos7580-j7elte_rev00.dtb
exynos7580-j7elte_rev04.dtb
exynos7580-j7elte_rev06.dtb"
COSMIC_CONFG_J700F=sandwich_defconfig
COSMIC_VARIANT_J700F=J700X
############### Script functions ################
read -p "Clean or Dirty ? (c/d) > " yn
if [ "$yn" = "C" -o "$yn" = "c" ]; then
     echo "Clean Build"
     make clean && make mrproper
     rm -r -f $COSMIC_DTB
     rm -rf $COSMIC_DTS/.*.tmp
     rm -rf $COSMIC_DTS/.*.cmd
     rm -rf $COSMIC_DTS/*.dtb
else
     echo "Dirty Build"
     rm -r -f $COSMIC_DTB
     rm -rf $COSMIC_DTS/.*.tmp
     rm -rf $COSMIC_DTS/.*.cmd
     rm -rf $COSMIC_DTS/*.dtb
fi
################### Kernel ######################
BUILD_ZIMAGE()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building Image for $COSMIC_VARIANT"
	make  $COSMIC_CONFG
	make -j$COSMIC_JOBS
	if [ ! -e ./arch/arm64/boot/Image ]; then
	exit 0;
	echo "Image Failed to Compile"
	echo " Abort "
	fi
	du -k "$COSMIC_KERNEL" | cut -f1 >sizT
	sizT=$(head -n 1 sizT)
	rm -rf sizT
	echo " "
	echo "----------------------------------------------"
}
############## Compiling the DTB ################
BUILD_DTB()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building DTB for $COSMIC_VARIANT"
	make $COSMIC_DTSFILES
	./scripts/dtbTool/dtbTool -o $COSMIC_DTB -d $COSMIC_DTS/ -s 2048
	if [ ! -e $COSMIC_DTB ]; then
	exit 0;
	echo "DTB Failed to Compile"
	echo " Abort "
	fi
	rm -rf $COSMIC_DTS/.*.tmp
	rm -rf $COSMIC_DTS/.*.cmd
	rm -rf $COSMIC_DTS/*.dtb
	du -k "$COSMIC_DTB" | cut -f1 >sizdT
	sizdT=$(head -n 1 sizdT)
	rm -rf sizdT
	echo " "
	echo "----------------------------------------------"
}
################## Main Menu ####################
clear
echo "----------------------------------------------"
echo "$COSMIC_NAME $COSMIC_VERSION Kernel Script"
echo "----------------------------------------------"
PS3='Please select your option (1-2): '
menuvar=("SM-J700X" "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
        "SM-J700X")
            clear
            echo "Starting $COSMIC_VARIANT_J700F kernel build..."
            COSMIC_VARIANT=$COSMIC_VARIANT_J700F
            COSMIC_CONFG=$COSMIC_CONFG_J700F
            COSMIC_DTSFILES=$COSMIC_DTSFILES_J700F
            BUILD_ZIMAGE
            BUILD_DTB
            echo " "
            echo "----------------------------------------------"
            echo "$COSMIC_VARIANT Build Complete."
            echo "Compiled DTB Size = $sizdT Kb"
            echo "Kernel Image Size = $sizT Kb"
            echo "Press any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
            "Exit")
            break
            ;;
        *) echo Invalid option.;;
    esac
done
#################################################
########## coded by themagicalmammal ############
#################################################
