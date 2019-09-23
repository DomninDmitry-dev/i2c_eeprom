DEV_KERNEL_DIR = 4.19.59-sunxi
HOST_KERNEL_DIR = orange-pi-4.19.59
PROJ_NAME = prog-i2c-eeprom
DEV_ROOT_IP = root@192.168.0.120
MOD_DIR = gpio
DTB_NAME = sun8i-h3-orangepi-one
USER_DIR=dmitry

ifeq ($(shell uname -r), $(DEV_KERNEL_DIR))
	KDIR = /lib/modules/$(shell uname -r)/build
else
	KDIR = $(HOME)/Kernels/$(HOST_KERNEL_DIR)
endif

ARCH = arm
CCFLAGS = -C
COMPILER_PROG = arm-unknown-linux-gnueabihf-
COMPILER = arm-linux-gnueabihf-
PWD = $(shell pwd)
TARGET_PROG = test
REMFLAGS = -g -O0

# Опция -g - помещает в объектный или исполняемый файл информацию необходимую для
# работы отладчика gdb. При сборке какого-либо проекта с целью последующей отладки,
# опцию -g необходимо включать как на этапе компиляции так и на этапе компоновки.

# Опция -O0 - отменяет какую-либо оптимизацию кода. Опция необходима на этапе
# отладки приложения. Как было показано выше, оптимизация может привести к
# изменению структуры программы до неузнаваемости, связь между исполняемым и
# исходным кодом не будет явной, соответственно, пошаговая отладка программы
# будет не возможна. При включении опции -g, рекомендуется включать и -O0.

obj-m   := $(TARGET_MOD).o
CFLAGS_$(TARGET_MOD).o := -DDEBUG

all: $(TARGET_PROG).c
ifeq ($(shell uname -r), $(DEV_KERNEL_DIR))
	cc $(TARGET_PROG).c -o $(TARGET_PROG) $(REMFLAGS)
else
	$(COMPILER_PROG)cc $(TARGET_PROG).c -o $(TARGET_PROG) $(REMFLAGS)
endif


reboot_dev:
	@./commands.sh -c reboot -devip $(DEV_ROOT_IP)
copy_prog:
	@./commands.sh -c copy-prog -projname $(PROJ_NAME) -devip $(DEV_ROOT_IP) -userdir $(USER_DIR)

clean:
	@rm -f *.o .*.cmd .*.flags *.mod.c *.order *.dwo *.mod.dwo .*.dwo
	@rm -f .*.*.cmd *~ *.*~ TODO.*
	@rm -fR .tmp*
	@rm -rf .tmp_versions
	@rm -f *.ko *.symvers
