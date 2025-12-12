#ifndef I2C_h
#define I2C_h

#include <stdio.h>
#include <stdint.h>
#include <errno.h>
#include <math.h>
#include <unistd.h>

    //Allows for I2C interfacing to the MCU
#include <wiringPi.h>
#include <wiringPiI2C.h>

    //Allows for the Attitude sensor chipsets regristers to be accessed sanely
#include "LIS3MDL.h"
#include "LSM6DSO.h"
#include "MS5607_02BA03.h"

#define I2CBUs "/dev/i2c-1"
//Investigate BARRO_fd further to verify not the RPI seeing itself
    //Address From Factory for altimiter and temprature sensor is 01110110b or 0x76???
#define ALT_ADDR 0x76
    //Address From Factory for gyro and accelerometer is 1101011b or 0x6B
#define IMU_ADDR 0x6B
    //Address From Factory for magnetometer is 0011110b or 0x1E
#define MAG_ADDR 0x1E


    //Graphical
void Dash_Line(void);

    //Data Manipulation
uint8_t Buffer_Reconstruct_uint8(uint8_t * Read_In_Data);
uint16_t Buffer_Reconstruct_uint16(uint8_t * Read_In_Data);
uint32_t Buffer_Reconstruct_uint24(uint8_t * Read_In_Data);
uint32_t Buffer_Reconstruct_uint32(uint8_t * Read_In_Data);
uint64_t Buffer_Reconstruct_uint64(uint8_t * Read_In_Data);

    //GPIO
uint8_t GPIOInit(int *, int *, int *);
int RFFEControlInit(void);

    //Sensors
void InitAttitudeSensors(int, int, int, struct ALT_CAL *);
int8_t InitALT(int, struct ALT_CAL *);
uint32_t get_PreasureRaw(int, int);
uint32_t get_TempratureRaw(int, int);
int32_t Calculate_Temprature(uint32_t, struct ALT_CAL *, int32_t *);
int64_t Compensate_Preasure(int32_t, struct ALT_CAL *, int32_t);
void Run_Altimiter(int, struct ALT_CAL *, struct ALT_OUT *);
int8_t InitIMU(int);
int8_t InitMAG(int);

#endif