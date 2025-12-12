#ifndef MS5607_h
#define MS5607_h

struct ALT_CAL
{
    uint16_t FACTORY_DATA;
    uint16_t T1_SENS;
    uint16_t T1_OFF;
    uint16_t TCS;
    uint16_t TCO;
    uint16_t TREFF;
    uint16_t TEMPSENS;
    uint16_t SERIAL_AND_CRC;
};

struct ALT_OUT
{
    int64_t Preasure;
    int32_t Temperature;
};


    //note there is only 1 register for interfacing with for the purposes of reading, and 8 single byte memory addresses to read from
enum MS5607_Byte_Commands
{
        //Loads Callibration data into the Internal register. Call to get sensor into setup mode
    RESET = 0x1E, 

        //Used to read the output of the ADC, is read off in MSB (23 -> 0). Must call after D1 or D2 conversion call, cannot handle both at once.
    ADC_READ = 0x00,

        //Calls for Uncompensated Preasure Conversion to start with the enumerated OSR value (256, 512, 1024, 2048, 4096 read samples per returned output value).
    D1_CONV_256 = 0x40,
    D1_CONV_512 = 0x42,
    D1_CONV_1024 = 0x44,
    D1_CONV_2048 = 0x46,
    D1_CONV_4096 = 0x48,

        //Calls for Uncompensated Temprature Conversion to start with the enumerated OSR value (256, 512, 1024, 2048, 4096 read samples per returned output value).
    D2_CONV_256 = 0x50,
    D2_CONV_512 = 0x52,
    D2_CONV_1024 = 0x54,
    D2_CONV_2048 = 0x56,
    D2_CONV_4096 = 0x58,

        //Calibration Data to be run once after reset to calculate calibration constants for calculation constants.
    FACTORY_PROM_READ = 0xA0,

    C1_PROM_READ = 0xA2,
    C2_PROM_READ = 0xA4,
    C3_PROM_READ = 0xA6,
    C4_PROM_READ = 0xA8,
    C5_PROM_READ = 0xAA,
    C6_PROM_READ = 0xAC,

    SERIAL_PROM_READ = 0xAE
};


#endif