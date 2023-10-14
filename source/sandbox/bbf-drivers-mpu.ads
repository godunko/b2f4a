------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Common code for MPU-6000/MPU-6050/MPU-6500/MPU-9150/MPU-9250 family: the
--  Motion Processing Units

pragma Restrictions (No_Elaboration_Code);

private with Interfaces;

with BBF.Delays;
with BBF.I2C.Master;

package BBF.Drivers.MPU is

   pragma Preelaborate;

   type Abstract_MPU_Sensor
     (Bus    : not null access BBF.I2C.Master.I2C_Master_Controller'Class;
      Device : BBF.I2C.Device_Address)
      --  Default device address is 16#68#. Sensor can be configured to 16#69#.
       is abstract tagged limited private;

   type Accelerometer_Range_Type is
     (FSR_2G,
      FSR_4G,
      FSR_8G,
      FSR_16G,
      Disabled);

   type Gyroscope_Range_Type is
     (FSR_250DPS,
      FSR_500DPS,
      FSR_1000DPS,
      FSR_2000DPS,
      Disabled);

   type Sample_Rate_Type is range 4 .. 1_000;

   procedure Configure
     (Self                : in out Abstract_MPU_Sensor'Class;
      Delays              : not null access BBF.Delays.Delay_Controller'Class;
      Accelerometer_Range : Accelerometer_Range_Type;
      Gyroscope_Range     : Gyroscope_Range_Type;
      Temperature         : Boolean;
      Filter              : Boolean;
      Sample_Rate         : Sample_Rate_Type;
      Success             : in out Boolean);
   --  Rate of the Digital Low Pass Filter is selected automatically depending
   --  on given sample rate. Filter rate might be 188, 98, 42, 20, 10, or 5 Hz
   --  and at least two times less than sample rate.

   procedure Enable
     (Self   : in out Abstract_MPU_Sensor'Class;
      Delays : not null access BBF.Delays.Delay_Controller'Class);
   --  Enables data load from the sensor.

   procedure Dump (Self : in out Abstract_MPU_Sensor'Class);
   --  XXX Temporary!

   function Get_Flag return Boolean;

private

   package Registers is

      --  SMPLRT_DIV (25/19)

      type SMPLRT_DIV_Register is record
         SMPLRT_DIV : Interfaces.Unsigned_8;
      end record
        with Object_Size => 8;

      --  CONFIG (26/1A)

      type DLPF_CFG_Type is mod 2 ** 3
        with Size => 3;
      --  Value 7 used by MPU6500/MPU9215 only

      type EXT_SYNC_SET_TYpe is
        (Disabled,
         TEMP_OUT_L,
         GYRO_XOUT_L,
         GYRO_YOUT_L,
         GYRO_ZOUT_L,
         ACCEL_XOUT_L,
         ACCEL_YOUT_L,
         ACCEL_ZOUT_L)
        with Size => 3;

      type CONFIG_Register is record
         DLPF_CFG          : DLPF_CFG_Type     := 0;
         EXT_SYNC_SET      : EXT_SYNC_SET_Type := Disabled;
         MPU6500_FIFO_MODE : Boolean           := False;
         Reserved_7        : Boolean           := False;
      end record
        with Pack, Object_Size => 8;

      --  GYRO_CONFIG (27/1B)

      type MPU6500_FCHOICE_B_Type is mod 2 ** 2
        with Size => 2;

      type GYRO_FS_SEL_Type is
        (G_250,
         G_500,
         G_1000,
         G_2000)
        with Size => 2;

      type GYRO_CONFIG_Register is record
         MPU6500_FCHOICE_B : MPU6500_FCHOICE_B_Type := 0;
         Reserved_2        : Boolean                := False;
         GYRO_FS_SEL       : GYRO_FS_SEL_Type       := G_250;
         ZG_ST             : Boolean                := False;
         YG_ST             : Boolean                := False;
         XG_ST             : Boolean                := False;
      end record
        with Pack, Object_Size => 8;

      --  ACCEL_CONFIG (28/1C)

      type ACCEL_FS_SEL_Type is
        (A_2,
         A_4,
         A_8,
         A_16)
        with Size => 2;

      type ACCEL_CONFIG_Register is record
         Reserved_0   : Boolean           := False;
         Reserved_1   : Boolean           := False;
         Reserved_2   : Boolean           := False;
         ACCEL_FS_SEL : ACCEL_FS_SEL_Type := A_2;
         ZA_ST        : Boolean           := False;
         YA_ST        : Boolean           := False;
         XA_ST        : Boolean           := False;
      end record
        with Pack, Object_Size => 8;

      --  MPU6500 ACCEL_CONFIG_2 (29/1D)

      type MPU6500_A_DLPF_CFG_Type is mod 2 ** 3
        with Size => 3;

      type MPU6500_ACCEL_CONFIG_2_Register is record
         A_DLPF_CFG     : MPU6500_A_DLPF_CFG_Type := 0;
         ACCEL_CHOICE_B : Boolean                 := False;
         Reserved_4     : Boolean                 := False;
         Reserved_5     : Boolean                 := False;
         FIFO_SIZE_1024 : Boolean                 := False;
         --  FIFO_SIZE_1024 is not documented.
         Reserved_7     : Boolean                 := False;
      end record
        with Pack, Object_Size => 8;

      --  FIFO_EN (35/23)

      type FIFO_EN_Register is record
         SLV0_FIFO_EN  : Boolean := False;
         SLV1_FIFO_EN  : Boolean := False;
         SLV2_FIFO_EN  : Boolean := False;
         ACCEL_FIFO_EN : Boolean := False;
         ZG_FIFO_EN    : Boolean := False;
         YG_FIFO_EN    : Boolean := False;
         XG_FIFO_EN    : Boolean := False;
         TEMP_FIFO_EN  : Boolean := False;
      end record
        with Pack, Object_Size => 8;

      --  INT_PIN_CFG (55/37)

      type INT_PIN_CFG_Register is record
         Reserved_0        : Boolean := False;
         I2C_BYPASS_EN     : Boolean := False;
         FSYNC_INT_MODE_EN : Boolean := False;
         ACTL_FSYNC        : Boolean := False;
         INT_ANYRD_2CLEAR  : Boolean := False;
         LATCH_INT_EN      : Boolean := False;
         OPEN              : Boolean := False;
         ACTL              : Boolean := False;
      end record
        with Pack, Object_Size => 8;

      --  INT_ENABLE (56/38)

      type INT_ENABLE_Register is record
         RAW_RDY_EN                  : Boolean := False;
         Reserved_1                  : Boolean := False;
         Reserved_2                  : Boolean := False;
         I2C_MST_INT_EN_FSYNC_INT_EN : Boolean := False;
         --  MPU6050: I2C_MST_INT
         --  MPU6500: FSYNC_INT_EN
         FIFO_OFLOW_EN               : Boolean := False;
         Reserved_5                  : Boolean := False;
         MPU6500_WOM_EN              : Boolean := False;
         Reserved_7                  : Boolean := False;
      end record
        with Pack, Object_Size => 8;

      --  INT_STATUS (58/3A)

      type IN_STATUS_Register is record
         DATA_RDY_INT : Boolean := False;
         Reserved_1                  : Boolean := False;
         Reserved_2                  : Boolean := False;
         I2C_MST_INT_EN_FSYNC_INT_EN : Boolean := False;
         --  MPU6050: I2C_MST_INT
         --  MPU6500: FSYNC_INT_EN
         FIFO_OFLOW_EN               : Boolean := False;
         Reserved_5                  : Boolean := False;
         MPU6500_WOM_EN              : Boolean := False;
         Reserved_7                  : Boolean := False;
      end record
        with Pack, Object_Size => 8;

      --  SIGNAL_PATH_RESET (104/68)

      type SIGNAL_PATH_RESET_Register is record
         TEMP_Reset  : Boolean := False;
         ACCEL_Reset : Boolean := False;
         GYRO_Reset  : Boolean := False;
         Reserved_3  : Boolean := False;
         Reserved_4  : Boolean := False;
         Reserved_5  : Boolean := False;
         Reserved_6  : Boolean := False;
         Reserved_7  : Boolean := False;
      end record
        with Pack, Object_Size => 8;

      --  USER_CTRL (106/6A)

      type USER_CTRL_Register is record
         SIG_COND_RESET : Boolean := False;
         I2C_MST_RESET  : Boolean := False;
         FIFO_RESET     : Boolean := False;
         Reserved_3     : Boolean := False;
         I2C_IF_DIS     : Boolean := False;
         I2C_MST_EN     : Boolean := False;
         FIFO_EN        : Boolean := False;
         Reserved_7     : Boolean := False;
      end record
        with Pack, Object_Size => 8;

      --  PWR_MGM_1 (107/6B)

      type CLKSEL_Type is    --     MPU6050              MPU6500
        (Internal,           --  Internal 8MHz        Internal 20MHz
         PLL_X,              --  PLL X gyro           Internal/PLL auto
         PLL_Y,              --  PLL Y guro           Internal/PLL auto
         PLL_Z,              --  PLL Z gyro           Internal/PLL auto
         PLL_32_768_K,       --  External 32.768kHz   Internal/PLL auto
         PLL_19_2_M,         --  External 19.2MHz     Internal/PLL auto
         MPU6500_Internal,   --                       Internal 20MHz
         Stop)
        with Size => 3;

      type PWR_MGMT_1_Register is record
         CLKSEL           : CLKSEL_Type := Internal;
         TEMP_DIS         : Boolean     := False;
         --  MPU9250 name it as PD_PTAT: Power Disable Proportional To Absolute
         --  Temperature sensor
         GYRO_STANDBY     : Boolean     := False;
         CYCLE            : Boolean     := False;
         SLEEP            : Boolean     := False;
         DEVICE_RESET     : Boolean     := False;
      end record
        with Pack, Object_Size => 8;

      --  PWR_MGMT_2 (108/6C)

      type LP_WAKE_CTRL_Type is mod 2 ** 2
        with Size => 2;

      type PWR_MGMT_2_Register is record
         STBY_ZG      : Boolean := False;
         STBY_YG      : Boolean := False;
         STBY_XG      : Boolean := False;
         STBY_ZA      : Boolean := False;
         STBY_YA      : Boolean := False;
         STBY_XA      : Boolean := False;
         LP_WAKE_CTRL : LP_WAKE_CTRL_Type := 0;
         --  Not supported by MPU9250
      end record
        with Pack, Object_Size => 8;

   end Registers;

   --  AK8975_Address : constant BBF.I2C.Device_Address := 16#0C#;

   MPU6050_WHOAMI : constant := 16#68#;
   MPU6500_WHOAMI : constant := 16#70#;
   MPU9250_WHOAMI : constant := 16#71#;

   SMPLRT_DIV_Address        : constant BBF.I2C.Internal_Address_8 := 16#19#;
   CONFIG_Address            : constant BBF.I2C.Internal_Address_8 := 16#1A#;
   GYRO_CONFIG_Address       : constant BBF.I2C.Internal_Address_8 := 16#1B#;
   ACCEL_CONFIG_Address      : constant BBF.I2C.Internal_Address_8 := 16#1C#;
   MPU6500_ACCEL_CONFIG_2_Address :
                               constant BBF.I2C.Internal_Address_8 := 16#1D#;

   FIFO_EN_Address           : constant BBF.I2C.Internal_Address_8 := 16#23#;

   INT_PIN_CFG_Address       : constant BBF.I2C.Internal_Address_8 := 16#37#;
   INT_ENABLE_Address        : constant BBF.I2C.Internal_Address_8 := 16#38#;

   INT_STATUS_Address        : constant BBF.I2C.Internal_Address_8 := 16#3A#;

   ACCEL_XOUT_H_Address      : constant BBF.I2C.Internal_Address_8 := 16#3B#;

   TEMP_OUT_H_Address        : constant BBF.I2C.Internal_Address_8 := 16#41#;

   GYRO_XOUT_H_Address       : constant BBF.I2C.Internal_Address_8 := 16#43#;

   SIGNAL_PATH_RESET_Address : constant BBF.I2C.Internal_Address_8 := 16#68#;

   USER_CTRL_Address         : constant BBF.I2C.Internal_Address_8 := 16#6A#;
   PWR_MGMT_1_Address        : constant BBF.I2C.Internal_Address_8 := 16#6B#;
   PWR_MGMT_2_Address        : constant BBF.I2C.Internal_Address_8 := 16#6C#;

   FIFO_COUNT_H_Address      : constant BBF.I2C.Internal_Address_8 := 16#72#;
   FIFO_COUNT_L_Address      : constant BBF.I2C.Internal_Address_8 := 16#73#;
   FIFO_R_W_Address          : constant BBF.I2C.Internal_Address_8 := 16#74#;
   WHO_AM_I_Address          : constant BBF.I2C.Internal_Address_8 := 16#75#;

   type ACCEL_OUT_Register is record
      ACCEL_XOUT_H : Interfaces.Integer_8  := 0;
      ACCEL_XOUT_L : Interfaces.Unsigned_8 := 0;
      ACCEL_YOUT_H : Interfaces.Integer_8  := 0;
      ACCEL_YOUT_L : Interfaces.Unsigned_8 := 0;
      ACCEL_ZOUT_H : Interfaces.Integer_8  := 0;
      ACCEL_ZOUT_L : Interfaces.Unsigned_8 := 0;
   end record
     with Pack;

   type TEMP_OUT_Register is record
      TEMP_OUT_H : Interfaces.Integer_8  := 0;
      TEMP_OUT_L : Interfaces.Unsigned_8 := 0;
   end record
     with Pack;

   type GYRO_OUT_Register is record
      GYRO_XOUT_H : Interfaces.Integer_8  := 0;
      GYRO_XOUT_L : Interfaces.Unsigned_8 := 0;
      GYRO_YOUT_H : Interfaces.Integer_8  := 0;
      GYRO_YOUT_L : Interfaces.Unsigned_8 := 0;
      GYRO_ZOUT_H : Interfaces.Integer_8  := 0;
      GYRO_ZOUT_L : Interfaces.Unsigned_8 := 0;
   end record
     with Pack;

   type Raw_Out_Registers is record
      ACCEL : ACCEL_OUT_Register;
      TEMP  : TEMP_OUT_Register;
      GYRO  : GYRO_OUT_Register;
   end record
     with Pack;

   type Raw_Out_Register_Array is array (Boolean) of Raw_Out_Registers;

   type Abstract_MPU_Sensor
     (Bus    : not null access BBF.I2C.Master.I2C_Master_Controller'Class;
      Device : BBF.I2C.Device_Address)
   is abstract tagged limited record
      Initialized           : Boolean := False;

      Accelerometer_Enabled : Boolean := False;
      Gyroscope_Enabled     : Boolean := False;
      Temperature_Enabled   : Boolean := False;

      User_Bank             : Boolean := False with Volatile;
      Data                  : Raw_Out_Register_Array;
      --  Two banks of collected information: one is used by the user, and
      --  another one asynchronous read handler. Banks are switched by the
      --  handler after successful load of new packet of data.

      Buffer                : BBF.I2C.Unsigned_8_Array (1 .. 20);
      --  FIFO packet IO buffer, size is enough to store
      --    - accelerometer data (6 bytes)
      --    - temperature data (2 bytes)
      --    - gyroscope data (6 bytes)
      --    - magnitometer data (6 bytes)
   end record;

   procedure Internal_Initialize
     (Self    : in out Abstract_MPU_Sensor'Class;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      WHOAMI  : Interfaces.Unsigned_8;
      Success : in out Boolean);
   --  First step of the initialization procedure. Probe controller and check
   --  chip identifier.

   not overriding function Is_6500_9250
     (Self : Abstract_MPU_Sensor) return Boolean is (raise Program_Error);

end BBF.Drivers.MPU;
