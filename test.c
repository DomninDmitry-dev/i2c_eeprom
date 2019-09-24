/*
 * test.cpp
 *
 *  Created on: may 28, 2019
 *      Author: Dmitry Domnin
 */

/* ****************************************************************************************************************
// This program writes a page of 128 bytes into a 24C*** EEPROM with 16 bit memory address
//
*/

#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <string.h> // for memcpy
#include <unistd.h> // for usleep
#include "myi2c.h"

// This is '1010 111 x' related to an EEPROM with A0, A1 and A2 pins connected to +Vcc (ID 111 = 7)
// Normally the last bit 'x' should be 0 for writing and 1 for reading, this is handled by the read/write functions
#define ADDRESS 0x50
#define SIZE_PAGE	32

// EEPROM is connected to I2C
#define I2C_BUS "/dev/i2c-1"

//------------------------------------------------------------------------------
int main(int argc, char **argv)
{
	int start_Addr = 0; 				// 16 bit memory address ranging 0 ~ 65535
	unsigned char rbuf[SIZE_PAGE] = {'\0'};	// Read buffer

	// A test string to write (must be less than 32 characters!)
	char wstring[] = "A test string to write";

	// Open the I2C Bus
	int fd = open(I2C_BUS, O_RDWR);
	if (fd < 0)
	{
		printf("ERROR: open failed\n");
		exit(EXIT_FAILURE);
	}

	// Take control over the I2C slave
	if (ioctl(fd, I2C_SLAVE, ADDRESS) < 0)
	{
		printf("ERROR: ioctl error\n");
		close(fd);
		exit(EXIT_FAILURE);
	}

	writeReg16DataBuf(fd, start_Addr, (void*)wstring, strlen(wstring));

	// Pause 10 milliseconds, give the EEPROM some time to complete the write cycle
	usleep(10000);

	readReg16DataBuf(fd, start_Addr, rbuf, sizeof(rbuf));

	// Print result
	printf("Read buffer content:\n'%s'\n", (char*)rbuf); 	// In a string format
	for(int i=0; i<sizeof(rbuf); ++i) printf("0x%02X, ", rbuf[i]);		// Read each single byte
	printf("\n");

	// Close I2C communication
	close(fd);
	return EXIT_SUCCESS;
}

