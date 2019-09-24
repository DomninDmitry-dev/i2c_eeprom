#!/bin/sh

while [ -n "$1" ]
do
	case "$1" in
		-hostdir) 	echo "-hostdir = $2"
					HOST_KERNEL_DIR="$2"
					shift ;;
		-devdir) 	echo "-devdir = $2"
					DEV_KERNEL_DIR="$2"
					shift ;;
		-projname) 	echo "-projname = $2"
					PROJ_NAME="$2"
					shift ;;
		-progname) 	echo "-progname = $2"
					TARGET_PROG="$2"
					shift ;;
		-devip) 	echo "-devip = $2"
					DEV_ROOT_IP="$2"
					shift ;;
		-comp) 		echo "-comp = $2"
					COMPILER="$2"
					shift ;;
		-modname) 	echo "-modname = $2"
					TARGET_MOD="$2"
					shift ;;
		-moddir) 	echo "-moddir = $2"
					MOD_DIR="$2"
					shift ;;
		-dtbname) 	echo "-dtbname = $2"
					DTB_NAME="$2"
					shift ;;
		-userdir) 	echo "-userdir = $2"
					USER_DIR="$2"
					shift ;;
		-p) 		echo "-port = $2"
					if [ "$2" -ne 0 ]; then
						PORT="-P $2"
					fi
					shift ;;
		-c) echo "-c = $2"
			COMM="$2"
			shift ;;
		--) shift
			break ;;
		*) echo "$1 is not an option";;
	esac
		shift
done

if [ "$COMM" = "copy-dtbo" ]; then
	echo "Copy $TARGET_MOD.dtbo"
	scp ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/DTS/$TARGET_MOD.dtbo $DEV_ROOT_IP:/boot/overlay-user

elif [ "$COMM" = "copy-dtb" ]; then
	echo "Copy $DTB_NAME.dtb"
	scp ~/Kernels/$HOST_KERNEL_DIR/arch/arm/boot/dts/$DTB_NAME.dtb $DEV_ROOT_IP:/boot/dtb

elif [ "$COMM" = "delete-ko" ]; then
	echo "Delete $TARGET_MOD.ko on board"
	ssh $DEV_ROOT_IP 'rm /lib/modules/$DEV_KERNEL_DIR/kernel/drivers/$MOD_DIR/$TARGET_MOD.ko'

elif [ "$COMM" = "copy-ko" ]; then
	echo "Copy $TARGET_MOD.ko to board"
	scp ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/$TARGET_MOD.ko $DEV_ROOT_IP:/lib/modules/$DEV_KERNEL_DIR/kernel/drivers/$MOD_DIR

elif [ "$COMM" = "compile-dts" ]; then
	echo "Copy dts from my project to kernel host"
	cp ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/DTS/$DTB_NAME.dts ~/Kernels/$HOST_KERNEL_DIR/arch/arm/boot/dts
	echo "Compiling dts"
	cd ~/Kernels/$HOST_KERNEL_DIR
	make ARCH=arm CROSS_COMPILE=$COMPILER $DTB_NAME.dtb
	echo "Copy dtb from kernel host to my project"
	cp ~/Kernels/$HOST_KERNEL_DIR/arch/arm/boot/dts/$DTB_NAME.dtb ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/DTS
	
elif [ "$COMM" = "compile-dtsi" ]; then
	~/Kernels/$HOST_KERNEL_DIR/scripts/dtc/dtc -I dts -O dtb -o ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/DTS/$TARGET_MOD.dtbo \
															 ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/DTS/$TARGET_MOD.dtsi
elif [ "$COMM" = "reboot" ]; then
	echo "Reboot"
	ssh $DEV_ROOT_IP 'reboot'

elif [ "$COMM" = "copy-prog" ]; then
	echo "Copy prog"
	scp $PORT ~/eclipse-workspace-drivers-OPI/$PROJ_NAME/$TARGET_PROG $DEV_ROOT_IP:/home/$USER_DIR/
fi
