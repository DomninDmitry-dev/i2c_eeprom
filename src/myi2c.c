/*
 * i2c.c
 *
 *  Created on: Sep 24, 2019
 *      Author: dmitry
 */

#include "../inc/myi2c.h"
#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <string.h>

//------------------------------------------------------------------------------
int writeReg16DataBuf(int fd, u_int16_t regAddr, void* buf, int size)
{
	u_int8_t addr[2] = {0};
	int w = 0;
	void *wbuf = NULL;	// Write buffer

	wbuf = malloc(size);

	addr[0] = regAddr >> 8; 	// high nibble
	addr[1] = regAddr & 255; 	// low nibble

	// Insert the memory address into the write buffer
	memcpy(wbuf, addr, 2);

	// Append the data to write (up to 128 bytes)
	memcpy(wbuf+2, buf, size);

	// Write bytes to EEPROM
	w = write(fd, (const void*)wbuf, size);
	if (w != size) {
		printf("Failed to write buffer\n");
		free(wbuf);
		return -1;
	}
	printf("Reg addr: 0x%02X, Write bytes: %d\n", regAddr, w);
	free(wbuf);
	return 0;
}
//------------------------------------------------------------------------------
int readReg16DataBuf(int fd, u_int16_t regAddr, void* buf, int size)
{
	u_int8_t addr[2] = {0};
	int r = 0;

	addr[0] = regAddr >> 8; 	// high nibble
	addr[1] = regAddr & 255; 	// low nibble

	// Write memory address again
	write(fd, (const void*)addr, 2);

	// Read bytes
	r = read(fd, buf, size);
	if(r != size) {
		printf("Failed to read buffer\n");
		return -1;
	}
	printf("Reg addr: 0x%02X, Read bytes: %d\n", regAddr, r);
	return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
