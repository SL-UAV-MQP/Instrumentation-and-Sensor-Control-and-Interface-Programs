#ifndef LSM6DSO_h
#define LSM6DSO_h

struct ACC_OUT
{
    int16_t X_Lin_Accel;
    int16_t Y_Lin_Accel;
    int16_t Z_Lin_Accel;
};


struct GYRO_OUT
{
    int16_t X_Rot_Accell;
    int16_t Y_Rot_Accell;
    int16_t Z_Rot_Accell;
};


enum LSM6DSO_Register_Addresses
{
    FUNC_CFG_ACCESS = 0x01,
    DSO_PIN_CTRL = 0x02,

    DSO_FIFO_CTRL1 = 0x07,
    DSO_FIFO_CTRL2 = 0x08,
    DSO_FIFO_CTRL3 = 0x09,
    DSO_FIFO_CTRL4 = 0x0A,

    COUNTER_BDR_REG1 = 0x0B,
    COUNTER_BDR_REG2 = 0x0C,
    INT1_CTRL = 0x0D,
    INT2_CTRL = 0x0E,
    WHO_AM_I_LSM = 0x0F,
    CTRL1_XL = 0x10,
    CTRL2_G = 0x11,
    CTRL3_C = 0x12,
    CTRL4_C = 0x13,
    CTRL5_C = 0x14,
    CTRL6_C = 0x15,
    CTRL7_G = 0x16,
    CTRL8_XL = 0x17,
    CTRL9_XL = 0x18,
    CTRL10_C = 0x19,
    ALL_INT_SRC = 0x1A,
    WAKE_UP_SRC = 0x1B,
    TAP_SRC = 0x1C,
    D6D_SRC = 0x1D,
    STATUS_REG_LSM = 0x1E,
    STATUS_SPIAux = 0x1E,

    OUT_TEMP_L = 0x20,
    OUT_TEMP_H = 0x21,
    OUTX_L_G = 0x22,
    OUTX_H_G = 0x23,
    OUTY_L_G = 0x24,
    OUTY_H_G = 0x25,
    OUTZ_L_G = 0x26,
    OUTZ_H_G = 0x27,
    OUTX_L_A = 0x28,
    OUTX_H_A = 0x29,
    OUTY_L_A = 0x2A,
    OUTY_H_A = 0x2B,
    OUTZ_L_A = 0x2C,
    OUTZ_H_A = 0x2D,

    EMB_FUNC_STATUS_MAINPAGE = 0x35,
    FSM_STATUS_A_MAINPAGE = 0x36,
    FSM_STATUS_B_MAINPAGE = 0x37,

    STATUS_MASTER_MAINPAGE = 0x39,

    FIFO_STATUS1 = 0x3A,
    FIFO_STATUS2 = 0x3B,
    TIMESTAMP0 = 0x40,
    TIMESTAMP1 = 0x41,
    TIMESTAMP2 = 0x42,
    TIMESTAMP3 = 0x43,

    TAP_CFG0 = 0x56,
    TAP_CFG1 = 0x57,
    TAP_CFG2 = 0x58,
    TAP_THS_6D = 0x59,
    INT_DUR2 = 0x5A,
    WAKE_UP_THS = 0x5B,
    WAKE_UP_DUR = 0x5C,
    FREE_FALL = 0x5D,
    MD1_CFG = 0x5E,
    MD2_CFG = 0x5F,

    I3C_BUS_AVB = 0x62,
    INTERNAL_FREQ_FINE = 0x63,

    INT_OIS = 0x6F,
    CTRL1_OIS = 0x70,
    CTRL2_OIS = 0x71,
    CTRL3_OIS = 0x72,
    X_OFS_USR = 0x73,
    Y_OFS_USR = 0x74,
    Z_OFS_USR = 0x75,
    FIFO_DATA_OUT_TAG = 0x78,
    FIFO_DATA_OUT_X_L = 0x79,
    FIFO_DATA_OUT_X_H = 0x7A,
    FIFO_DATA_OUT_Y_L = 0x7B,
    FIFO_DATA_OUT_Y_H = 0x7C,
    FIFO_DATA_OUT_Z_L = 0x7D,
    FIFO_DATA_OUT_Z_H = 0x7E,

    // LSM6DSO embedded functions registers

    PAGE_SEL = 0x02,

    EMB_FUNC_EN_A = 0x04,
    EMB_FUNC_EN_B = 0x05,

    PAGE_ADDRESS = 0x08,
    PAGE_VALUE = 0x09,
    EMB_FUNC_INT1 = 0x0A,
    FSM_INT1_A = 0x0B,
    FSM_INT1_B = 0x0C,

    EMB_FUNC_INT2 = 0x0E,
    FSM_INT2_A = 0x0F,
    FSM_INT2_B = 0x10,

    EMB_FUNC_STATUS = 0x12,
    FSM_STATUS_A = 0x13,
    FSM_STATUS_B = 0x14,

    PAGE_RW = 0x17,

    EMB_FUNC_FIFO_CFG = 0x44,

    FSM_ENABLE_A = 0x46,
    FSM_ENABLE_B = 0x47,
    FSM_LONG_COUNTER_L = 0x48,
    FSM_LONG_COUNTER_H = 0x49,
    FSM_LONG_COUNTER_CLEAR = 0x4A,

    FSM_OUTS1 = 0x4C,
    FSM_OUTS2 = 0x4D,
    FSM_OUTS3 = 0x4E,
    FSM_OUTS4 = 0x4F,
    FSM_OUTS5 = 0x50,
    FSM_OUTS6 = 0x51,
    FSM_OUTS7 = 0x52,
    FSM_OUTS8 = 0x53,
    FSM_OUTS9 = 0x54,
    FSM_OUTS10 = 0x55,
    FSM_OUTS11 = 0x56,
    FSM_OUTS12 = 0x57,
    FSM_OUTS13 = 0x58,
    FSM_OUTS14 = 0x59,
    FSM_OUTS15 = 0x5A,
    FSM_OUTS16 = 0x5B,

    EMB_FUNC_ODR_CFG_B = 0x5F,

    DSO_STEP_COUNTER_L = 0x62,
    DSO_STEP_COUNTER_H = 0x63,
    EMB_FUNC_SRC = 0x64,

    EMB_FUNC_INIT_A = 0x66,
    EMB_FUNC_INIT_B = 0x67,

    // LSM6DSO embedded advanced features registers page = 0

    EMB_SENSITIVITY_L = 0xBA,
    EMB_SENSITIVITY_H = 0xBB,

    EMB_OFFX_L = 0xC0,
    EMB_OFFX_H = 0xC1,
    EMB_OFFY_L = 0xC2,
    EMB_OFFY_H = 0xC3,
    EMB_OFFZ_L = 0xC4,
    EMB_OFFZ_H = 0xC5,
    EMB_SI_XX_L = 0xC6,
    EMB_SI_XX_H = 0xC7,
    EMB_SI_XY_L = 0xC8,
    EMB_SI_XY_H = 0xC9,
    EMB_SI_XZ_L = 0xCA,
    EMB_SI_XZ_H = 0xCB,
    EMB_SI_YY_L = 0xCC,
    EMB_SI_YY_H = 0xCD,
    EMB_SI_YZ_L = 0xCE,
    EMB_SI_YZ_H = 0xCF,
    EMB_SI_ZZ_L = 0xD0,
    EMB_SI_ZZ_H = 0xD1,

    EMB_CFG_A = 0xD4,
    EMB_CFG_B = 0xD5,

    // LSM6DSO embedded advanced features registers page 1

    FSM_LC_TIMEOUT_L = 0x7A,
    FSM_LC_TIMEOUT_H = 0x7B,
    FSM_PROGRAMS = 0x7C,

    FSM_START_ADD_L = 0x7E,
    FSM_START_ADD_H = 0x7F,

    PEDO_CMD_REG = 0x83,
    PEDO_DEB_STEPS_CONF = 0x84,

    PEDO_SC_DELTAT_L = 0xD0,
    PEDO_SC_DELTAT_H = 0xD1,

    // LSM6DSO sensor hub registers

    SENSOR_HUB_1 = 0x02,
    SENSOR_HUB_2 = 0x03,
    SENSOR_HUB_3 = 0x04,
    SENSOR_HUB_4 = 0x05,
    SENSOR_HUB_5 = 0x06,
    SENSOR_HUB_6 = 0x07,
    SENSOR_HUB_7 = 0x08,
    SENSOR_HUB_8 = 0x09,
    SENSOR_HUB_9 = 0x0A,
    SENSOR_HUB_10 = 0x0B,
    SENSOR_HUB_11 = 0x0C,
    SENSOR_HUB_12 = 0x0D,
    SENSOR_HUB_13 = 0x0E,
    SENSOR_HUB_14 = 0x0F,
    SENSOR_HUB_15 = 0x10,
    SENSOR_HUB_16 = 0x11,
    SENSOR_HUB_17 = 0x12,
    SENSOR_HUB_18 = 0x13,
    MASTER_CONFIG = 0x14,
    SLV0_ADD = 0x15,
    SLV0_SUBADD = 0x16,
    SLV0_CONFIG = 0x17,
    SLV1_ADD = 0x18,
    SLV1_SUBADD = 0x19,
    SLV1_CONFIG = 0x1A,
    SLV2_ADD = 0x1B,
    SLV2_SUBADD = 0x1C,
    SLV2_CONFIG = 0x1D,
    SLV3_ADD = 0x1E,
    SLV3_SUBADD = 0x1F,
    SLV3_CONFIG = 0x20,
    DATAWRITE_SLV0 = 0x21,
    STATUS_MASTER = 0x22
};

#endif