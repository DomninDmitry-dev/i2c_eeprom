DEV_KERNEL_DIR := 4.19.59-sunxi
HOST_KERNEL_DIR := orange-pi-4.19.59
PROJ_NAME := prog-i2c-eeprom
DTB_NAME := sun8i-h3-orangepi-one
USER_DIR := dmitry

ifeq ($(shell uname -n), ThinkPad-T430s)
	DEV_ROOT_IP := root@192.168.0.120
	PORT := 0
else
	DEV_ROOT_IP := root@185.200.62.68
	PORT := 10120
endif

ifeq ($(shell uname -m), x86_64)
	KDIR := $(HOME)/Kernels/$(HOST_KERNEL_DIR)
else
	KDIR := /lib/modules/$(shell uname -r)/build
endif

WARNFLAGS := -Wall
REMFLAGS := -g -O0
#COMPILER_CROSS := arm-unknown-linux-gnueabihf-
COMPILER_CROSS := arm-linux-gnueabihf-
PWD := $(shell pwd)
TARGET_PROG := main

# Опция -g - помещает в объектный или исполняемый файл информацию необходимую для
# работы отладчика gdb. При сборке какого-либо проекта с целью последующей отладки,
# опцию -g необходимо включать как на этапе компиляции так и на этапе компоновки.

# Опция -O0 - отменяет какую-либо оптимизацию кода. Опция необходима на этапе
# отладки приложения. Как было показано выше, оптимизация может привести к
# изменению структуры программы до неузнаваемости, связь между исполняемым и
# исходным кодом не будет явной, соответственно, пошаговая отладка программы
# будет не возможна. При включении опции -g, рекомендуется включать и -O0.

ifeq ($(shell uname -m), x86_64)
	CC := $(COMPILER_CROSS)gcc
else
	CC := gcc
endif

# https://www.opennet.ru/docs/RUS/gnumake/

SRC_DIRS	:= src1 \
				src2

SRC_FILES 	:= $(wildcard src/*.c)
HEAD_FILES	:= $(wildcard inc/*.h)
OBJ_FILES	:= $(patsubst %.c, %.o, $(notdir $(SRC_FILES)))
#OBJ_FILES	:= $(SRC_FILES:.c=.o)

all: myprog

myprog: main.o myi2c.o
	$(CC) $(WARNFLAGS) $(addprefix -I../, $(SRC_FILES)) $(addprefix -I../, $(HEAD_FILES)) $^ -o $@

main.o: src/main.c
	$(CC) -c $(addprefix -I../, $(SRC_FILES)) $(addprefix -I../, $(HEAD_FILES)) $<
	
myi2c.o: src/myi2c.c
	$(CC) -c $(addprefix -I../, $(SRC_FILES)) $(addprefix -I../, $(HEAD_FILES)) $<

#myprog: $(TARGET_PROG).o myi2c.o
#	$(CC) $(REMFLAGS) $(WARNFLAGS) $(TARGET_PROG).o myi2c.o -o $(TARGET_PROG)
#$(TARGET_PROG).o: $(TARGET_PROG).c
#	$(CC) -c $(TARGET_PROG).c
#myi2c.o: myi2c.c myi2c.h
#	$(CC) -c myi2c.c 


reboot_dev:
	@./commands.sh -c reboot -devip $(DEV_ROOT_IP)
copy_prog:
	@./commands.sh -c copy-prog -projname $(PROJ_NAME) -progname $(TARGET_PROG) -devip $(DEV_ROOT_IP) -p $(PORT) -userdir $(USER_DIR)

clean:
	@rm -f *.o .*.cmd .*.flags *.mod.c *.order *.dwo *.mod.dwo .*.dwo
	@rm -f .*.*.cmd *~ *.*~ TODO.*
	@rm -fR .tmp*
	@rm -rf .tmp_versions
	@rm -f *.ko *.symvers
