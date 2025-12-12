#include "I2C_Test.h"

int main()
{
    int ALT_fd = 0;
    int IMU_fd = 0;
    int MAG_fd = 0;

    uint8_t GPIO_Status = GPIOInit(&ALT_fd, &IMU_fd, &MAG_fd);

    struct ACC_OUT IMU_Lin_Accel_Read;
    struct GYRO_OUT IMU_Rot_Accel_Read;

    struct MAG_OUT Compas_Mag_Read;

    struct ALT_CAL Altimiter_Cal_Values;
    struct ALT_OUT Altimiter_Read;

    InitAttitudeSensors(ALT_fd, IMU_fd, MAG_fd, &Altimiter_Cal_Values);
    Run_Altimiter(ALT_fd, &Altimiter_Cal_Values, &Altimiter_Read);

    
    return(0);
}