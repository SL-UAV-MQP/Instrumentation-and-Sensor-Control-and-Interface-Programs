#include "I2C_Test.h"

void Dash_Line()
{
    printf("\n\n");
    for(int i = 0; i < 80; i++)
    {
        printf("-");
    }
    printf("\n\n");
}


uint8_t Buffer_Reconstruct_uint8(uint8_t * Read_In_Data_8)
{
    return(Read_In_Data_8[0]);
}

uint16_t Buffer_Reconstruct_uint16(uint8_t * Read_In_Data_16)
{
    return(
            ((uint16_t)Read_In_Data_16[0] <<  8) | 
            ((uint16_t)Read_In_Data_16[1])
        );
}


uint32_t Buffer_Reconstruct_uint24(uint8_t * Read_In_Data_24)
{
    return(
            ((uint32_t)Read_In_Data_24[0] << 16) | 
            ((uint32_t)Read_In_Data_24[1] <<  8) | 
            ((uint32_t)Read_In_Data_24[2])
        );
}

uint32_t Buffer_Reconstruct_uint32(uint8_t * Read_In_Data_32)
{
    return(
            ((uint32_t)Read_In_Data_32[0] << 24) | 
            ((uint32_t)Read_In_Data_32[1] << 16) | 
            ((uint32_t)Read_In_Data_32[2] <<  8) | 
            ((uint32_t)Read_In_Data_32[3])
        );
}

uint64_t Buffer_Reconstruct_uint64(uint8_t * Read_In_Data_64)
{
    return(
            ((uint64_t)Read_In_Data_64[0] << 56) | 
            ((uint64_t)Read_In_Data_64[1] << 48) | 
            ((uint64_t)Read_In_Data_64[2] << 40) | 
            ((uint64_t)Read_In_Data_64[3] << 32) | 
            ((uint64_t)Read_In_Data_64[4] << 24) | 
            ((uint64_t)Read_In_Data_64[5] << 16) | 
            ((uint64_t)Read_In_Data_64[6] <<  8) | 
            ((uint64_t)Read_In_Data_64[7])
        );
}



uint8_t GPIOInit(int * Alt_Handle, int * IMU_Handle, int * MAG_Handle)
{
    puts("Setting Up GPIO Pins ...");
    int Pin_Enumerate_Init = wiringPiSetupPinType(WPI_PIN_BCM);

    if(Pin_Enumerate_Init == 0)
    {
        puts("Pins Sucessfuly Setup.");

        puts("Configuring GPIO Control Pins...");

        uint8_t Control_GPIO_Status = RFFEControlInit();

        puts("GPIO Control Pins Sucessfuly configured...");

        Dash_Line();

        uint8_t ALT_Status = 0;
        uint8_t IMU_Status = 0;
        uint8_t MAG_Status = 0;

        *Alt_Handle  = wiringPiI2CSetup(ALT_ADDR);
        if(*Alt_Handle == -1)
        {
            puts("Altimeter: Address Setup: Fail");
        }
        else
        {
            puts("Altimeter: Address Setup: Sucess");
            ALT_Status = 1;
        }
        *IMU_Handle = wiringPiI2CSetup(IMU_ADDR);
        if(*IMU_Handle == -1)
        {
            puts("IMU: Address Setup: Fail");
        }
        else
        {
            puts("IMU: Address Setup: Sucess");
            IMU_Status = 1;
        }
        *MAG_Handle = wiringPiI2CSetup(MAG_ADDR);
        if(*MAG_Handle == -1)
        {
            puts("Magnetometer: Address Setup: Fail");
        }
        else
        {
            puts("Magnetometer: Address Setup: Sucess");
            MAG_Status = 1;
        }

        Dash_Line();

        return(ALT_Status+IMU_Status+MAG_Status+Control_GPIO_Status);
    }
    else
    {
        return(-1);
    }
}

int RFFEControlInit()
{
    puts("Starting Pin configuration...");

    pinMode(17, OUTPUT);
    pullUpDnControl(17, PUD_DOWN);
    puts("Pin 17 Configured to OUTPUT and PULL DOWN.");

    pinMode(27, OUTPUT);
    pullUpDnControl(27, PUD_DOWN);
    puts("Pin 27 Configured to OUTPUT and PULL DOWN.");

    pinMode(10, OUTPUT);
    pullUpDnControl(10, PUD_DOWN);
    puts("Pin 10 Configured to OUTPUT and PULL DOWN.");

    pinMode(9, OUTPUT);
    pullUpDnControl(9, PUD_DOWN);
    puts("Pin 09 Configured to OUTPUT and PULL DOWN.");

    pinMode(0, OUTPUT);
    pullUpDnControl(0, PUD_DOWN);
    puts("Pin 00 Configured to OUTPUT and PULL DOWN.");

    pinMode(5, OUTPUT);
    pullUpDnControl(5, PUD_DOWN);
    puts("Pin 05 Configured to OUTPUT and PULL DOWN.");

    pinMode(6, OUTPUT);
    pullUpDnControl(6, PUD_DOWN);
    puts("Pin 06 Configured to OUTPUT.");

    pinMode(13, OUTPUT);
    pullUpDnControl(13, PUD_DOWN);
    puts("Pin 13 Configured to OUTPUT and PULL DOWN.");

    pinMode(19, OUTPUT);
    pullUpDnControl(19, PUD_DOWN);
    puts("Pin 19 Configured to OUTPUT and PULL DOWN.");

    pinMode(26, OUTPUT);
    pullUpDnControl(26, PUD_DOWN);
    puts("Pin 26 Configured to OUTPUT and PULL DOWN.");

    return(10);
}

