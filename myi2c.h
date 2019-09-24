/*
 * i2c.h
 *
 *  Created on: Sep 24, 2019
 *      Author: dmitry
 */

#ifndef MYI2C_H_
#define MYI2C_H_

#include <stdio.h>
#include <stdlib.h>

int writeReg16DataBuf(int fd, u_int16_t regAddr, void* buf, int size);
int readReg16DataBuf(int fd, u_int16_t regAddr, void* buf, int size);


#endif /* MYI2C_H_ */
