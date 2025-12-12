#include "I2C_Test.h"

void InitAttitudeSensors(int ALT_Handle, int IMU_Handle, int MAG_Handle, struct ALT_CAL * Altimiter_Cal)
{

    int8_t ALT_Status = InitALT(ALT_Handle, Altimiter_Cal);

    Dash_Line();

    int8_t IMU_Status = InitIMU(IMU_Handle);

    Dash_Line();

    int8_t MAG_Status = InitMAG(MAG_Handle);

    Dash_Line();

}

    //Altitude sensor functions
int8_t InitALT(int ALT, struct ALT_CAL * Cal_Struct_Access)
{
    puts("Resetting Altimiter...");
    int8_t Reset_Status = wiringPiI2CWrite(ALT, RESET);

        //DO NOT SHORTEN WILL FAIL OTHERWISE
    while(wiringPiI2CReadReg16(ALT, FACTORY_PROM_READ) == -1)
    {
        sleep(0.1);
    }

    if(Reset_Status == 0)
    {
        puts("Reading Altimiter Factory Byte...");
        Cal_Struct_Access->FACTORY_DATA =  __builtin_bswap16(wiringPiI2CReadReg16(ALT, FACTORY_PROM_READ));
        printf("Factory Data: %i\n\n", (Cal_Struct_Access->FACTORY_DATA));

        puts("Reading Configuration Byte 1...");
        Cal_Struct_Access->T1_SENS =  __builtin_bswap16(wiringPiI2CReadReg16(ALT, C1_PROM_READ));
        printf("Pressure sensitivity: %i\n\n", (Cal_Struct_Access->T1_SENS));

        puts("Reading Configuration Byte 2...");
        Cal_Struct_Access->T1_OFF = __builtin_bswap16(wiringPiI2CReadReg16(ALT, C2_PROM_READ));
        printf("Pressure offset: %i\n\n", (Cal_Struct_Access->T1_OFF));

        puts("Reading Configuration Byte 3...");
        Cal_Struct_Access->TCS = __builtin_bswap16(wiringPiI2CReadReg16(ALT, C3_PROM_READ));
        printf("Temperature coefficient of pressure sensitivity: %i\n\n", (Cal_Struct_Access->TCS));

        puts("Reading Configuration Byte 4...");
        Cal_Struct_Access->TCO = __builtin_bswap16(wiringPiI2CReadReg16(ALT, C4_PROM_READ));
        printf("Temperature coefficient of pressure offset: %i\n\n", (Cal_Struct_Access->TCO));

        puts("Reading Configuration Byte 5...");
        Cal_Struct_Access->TREFF = __builtin_bswap16(wiringPiI2CReadReg16(ALT, C5_PROM_READ));
        printf("Reference temperature: %i\n\n", (Cal_Struct_Access->TREFF));

        puts("Reading Configuration Byte 6...");
        Cal_Struct_Access->TEMPSENS = __builtin_bswap16(wiringPiI2CReadReg16(ALT, C6_PROM_READ));
        printf("Temperature coefficient of the temperature: %i\n\n", (Cal_Struct_Access->TEMPSENS));

        puts("Reading Serial and CRC Byte...");
        Cal_Struct_Access->SERIAL_AND_CRC = __builtin_bswap16(wiringPiI2CReadReg16(ALT, SERIAL_PROM_READ));
        printf("Serial Code and CRC: %i\n\n", (Cal_Struct_Access->SERIAL_AND_CRC));
        puts("Altimiter Configuration Complete!");
        return(1);
    }
    else
    {
        puts("Altimiter Reset Failed...");
        return(-1);
    }
}



uint32_t get_PreasureRaw(int ALT_SLAVE_PREASURE_HANDLE, int Preasure_Resolution)
{
    int8_t Conversion_Start_Status = 0;
    uint8_t ADC_Preasure_Return[3] = {0};
    int8_t bytes_read = 0;

    switch(Preasure_Resolution)
    {
        case 256:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_PREASURE_HANDLE, D1_CONV_256);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Preasure_Resolution);
                usleep(900);
            }
            break;
        }
        case 512:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_PREASURE_HANDLE, D1_CONV_512);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Preasure_Resolution);
                usleep(1400);
            }
            break;
        }
        case 1024:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_PREASURE_HANDLE, D1_CONV_1024);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Preasure_Resolution);
                usleep(2500);
            }
            break;
        }
        case 2048:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_PREASURE_HANDLE, D1_CONV_2048);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Preasure_Resolution);
                usleep(4700);
            }
            break;
        }
        case 4096:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_PREASURE_HANDLE, D1_CONV_4096);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Preasure_Resolution);
                usleep(9200);
            }
            break;
        }
    }

    bytes_read = wiringPiI2CReadBlockData(ALT_SLAVE_PREASURE_HANDLE, ADC_READ, ADC_Preasure_Return, 3);

                printf("Byte 1: %i\nByte 2: %i\nByte 3: %i\n", ADC_Preasure_Return[1], ADC_Preasure_Return[2], ADC_Preasure_Return[3]);
                if(bytes_read == -1)
                {
                    puts("Read Operation Failed...");
                }

    if(bytes_read >= 0)
    {
        return(Buffer_Reconstruct_uint24(ADC_Preasure_Return));
    }
    else
    {
        return(-1);
    }
}

uint32_t get_TempratureRaw(int ALT_SLAVE_TEMP_HANDLE, int Temp_Resolution)
{
    int8_t Conversion_Start_Status = 0;
    uint8_t ADC_Temp_Return[3] = {0};
    int8_t bytes_read = 0;

    switch(Temp_Resolution)
    {
        case 256:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_TEMP_HANDLE, D2_CONV_256);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Temp_Resolution);
                usleep(900);
            }
            break;
        }
        case 512:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_TEMP_HANDLE, D2_CONV_512);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Temp_Resolution);
                usleep(1400);
            }
            break;
        }
        case 1024:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_TEMP_HANDLE, D2_CONV_1024);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Temp_Resolution);
                usleep(2500);
            }
            break;
        }
        case 2048:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_TEMP_HANDLE, D2_CONV_2048);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Temp_Resolution);
                usleep(4700);
            }
            break;
        }
        case 4096:
        {
            Conversion_Start_Status = wiringPiI2CWrite(ALT_SLAVE_TEMP_HANDLE, D2_CONV_4096);
            if(Conversion_Start_Status == 0)
            {
                printf("%i sample conversion starting...\n", Temp_Resolution);
                usleep(9200);
            }
            break;
        }
    }

    bytes_read = wiringPiI2CReadBlockData(ALT_SLAVE_TEMP_HANDLE, ADC_READ, ADC_Temp_Return, 3);

                printf("Byte 1: %i\nByte 2: %i\nByte 3: %i\n", ADC_Temp_Return[1], ADC_Temp_Return[2], ADC_Temp_Return[3]);
                if(bytes_read == -1)
                {
                    puts("Read Operation Failed...");
                }

    if(bytes_read >= 0)
    {
        return(Buffer_Reconstruct_uint24(ADC_Temp_Return));
    }
    else
    {
        return(-1);
    }
}

int32_t Calculate_Temprature(uint32_t Temp_Raw, struct ALT_CAL * Temprature_Compensation, int32_t * Temp_Differential)
{
    int32_t dT = Temp_Raw - ((Temprature_Compensation->TREFF)*256);
    printf("dT: %i\n", dT);
    *Temp_Differential = dT;
    printf("Temprature offset: %i mC\n", (dT*((Temprature_Compensation->TEMPSENS)/8388608)));
    return(2000 + dT*((Temprature_Compensation->TEMPSENS)/8388608));
}

int64_t Compensate_Preasure(int32_t Preasure_Raw, struct ALT_CAL * Preasure_Compensation, int32_t Temprature_Sup_Data)
{
    int64_t Preasure_Offset = ((Preasure_Compensation->T1_OFF)*131072)+(((Preasure_Compensation->TCO)*(Temprature_Sup_Data))/64);
    printf("Preasure Offset: %li\n", Preasure_Offset);

    int64_t Sensitivity = ((Preasure_Compensation->T1_SENS)*65536)+(((Preasure_Compensation->TCS)*(Temprature_Sup_Data))/128);
    printf("Sensitivity: %li\n", Sensitivity);

    return((((Preasure_Raw*Sensitivity)/2097152)-Preasure_Offset)/32768);
}

void Run_Altimiter(int ALT, struct ALT_CAL * CAL, struct ALT_OUT * OUT)
{
    uint32_t Raw_Temprature = get_TempratureRaw(ALT, 256);
    uint32_t Raw_Preasure = get_PreasureRaw(ALT, 256);

    printf("Raw Temprature Read: %i\nRaw Preasure Read: %i\n", Raw_Temprature, Raw_Preasure);

    int32_t Temp_Diff = 0;
    int32_t Real_Temprature = Calculate_Temprature(Raw_Temprature ,CAL, &Temp_Diff);
    int32_t Real_Preasure = Compensate_Preasure(Raw_Preasure ,CAL, Temp_Diff);
    printf("Real Temprature Read: %f C\nReal Preasure Read: %f Bar\n", (float)Real_Temprature/100, (float)Real_Preasure/100000);
}


    //IMU Sensor functions
int8_t InitIMU(int IMU)
{
    return(1);
}

    //Magmotometer Sensor functions
int8_t InitMAG(int MAG)
{
    puts("Configureing Magnotometer Control 1 Register...");
        //Temp Sensor Enable, X-Y axis Ultra High Preformance Mode, 80Hz data rate, Self Test Off
    int8_t CTRL1_INIT_Status = wiringPiI2CWriteReg8(MAG, CTRL_REG1, 0xFC);
    if(CTRL1_INIT_Status == 0)
    {
        puts("Configureing Magnotometer Control 1 Register Sucessfuly Configured!");
        printf("Control Regrister 1 set to: %X\n\n", wiringPiI2CReadReg8(MAG, CTRL_REG1));
    }
    else
    {
        puts("Configureing Magnotometer Control 1 Register Configuration Fail.");
    }

    puts("Configureing Magnotometer Control 2 Register...");
        //Full scale mag range set to +- 4 gauss
    uint8_t CTRL2_INIT_Status = wiringPiI2CWriteReg8(MAG, CTRL_REG2, 0x00);
    if(CTRL2_INIT_Status == 0)
    {
        puts("Configureing Magnotometer Control 2 Register Sucessfuly Configured!");
        printf("Control Regrister 2 set to: %X\n\n", wiringPiI2CReadReg8(MAG, CTRL_REG2));
    }
    else
    {
        puts("Configureing Magnotometer Control 2 Register Configuration Fail.");
    }

    puts("Configureing Magnotometer Control 3 Register...");
        //Set Operating mode to single sample (required for 80Hz)
    uint8_t CTRL3_INIT_Status = wiringPiI2CWriteReg8(MAG, CTRL_REG3, 0x01);
    if(CTRL3_INIT_Status == 0)
    {
        puts("Configureing Magnotometer Control 3 Register Sucessfuly Configured!");
        printf("Control Regrister 3 set to: %X\n\n", wiringPiI2CReadReg8(MAG, CTRL_REG3));
    }
    else
    {
        puts("Configureing Magnotometer Control 3 Register Configuration Fail.");
    }

    puts("Configureing Magnotometer Control 4 Register...");
        //Set Zaxis to Ultra High Preformance Mode, Data to Big Endian mode to match other sensors
    uint8_t CTRL4_INIT_Status = wiringPiI2CWriteReg8(MAG, CTRL_REG4, 0x0E);
    if(CTRL4_INIT_Status == 0)
    {
        puts("Configureing Magnotometer Control 4 Register Sucessfuly Configured!");
        printf("Control Regrister 4 set to: %X\n\n", wiringPiI2CReadReg8(MAG, CTRL_REG4));
    }
    else
    {
        puts("Configureing Magnotometer Control 4 Register Configuration Fail.");
    }
    
    if((CTRL1_INIT_Status+CTRL2_INIT_Status+CTRL3_INIT_Status+CTRL4_INIT_Status) == 0)
    {
        puts("Magnotometer Configuration Complete!");
        return(1);
    }
    else
    {
        puts("magnotometer Configuration Errors Occured.");
        return((CTRL1_INIT_Status+CTRL2_INIT_Status+CTRL3_INIT_Status+CTRL4_INIT_Status));
    }
}
