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

pragma Restrictions (No_Elaboration_Code);

with Interfaces;

with BBF.Drivers.MPU;
with BBF.I2C;

package body BBF.Drivers.MPU.MPU6050 is

   --  AK8975_Address : constant BBF.I2C.Device_Address := 16#0C#;

   MPU6050_WHOAMI : constant := 16#68#;

   type INT_PIN_CFG_Register is record
      Reserved_0        : Boolean := False;
      BYPASS_EN         : Boolean := False;
      FSYNC_INT_MODE_EN : Boolean := False;
      ACTL_FSYNC        : Boolean := False;
      INT_ANYRD_2CLEAR  : Boolean := False;
      LATCH_INT_EN      : Boolean := False;
      OPEN              : Boolean := False;
      ACTL              : Boolean := False;
   end record
     with Object_Size => 8;
   for INT_PIN_CFG_Register use record
      Reserved_0        at 0 range 0 .. 0;
      BYPASS_EN         at 0 range 1 .. 1;
      FSYNC_INT_MODE_EN at 0 range 2 .. 2;
      ACTL_FSYNC        at 0 range 3 .. 3;
      INT_ANYRD_2CLEAR  at 0 range 4 .. 4;
      LATCH_INT_EN      at 0 range 5 .. 5;
      OPEN              at 0 range 6 .. 6;
      ACTL              at 0 range 7 .. 7;
   end record;

   type MPU6050_INT_ENABLE_Register is record
      DATA_RDY_EN    : Boolean := False;
      Reserved_1     : Boolean := False;
      Reserved_2     : Boolean := False;
      I2C_MST_INT_EN : Boolean := False;
      FIFO_OFLOW_EN  : Boolean := False;
      Reserved_5     : Boolean := False;
      Reserved_6     : Boolean := False;
      Reserved_7     : Boolean := False;
   end record
     with Pack, Object_Size => 8;

   type MPU6050_CLKSEL_Type is
     (Internal, PLL_X, PLL_Y, PLL_Z, PLL_32_768_K, PLL_19_2_M, Stop)
     with Size => 3;
   for MPU6050_CLKSEL_Type use
     (Internal     => 0,
      PLL_X        => 1,
      PLL_Y        => 2,
      PLL_Z        => 3,
      PLL_32_768_K => 4,
      PLL_19_2_M   => 5,
      Stop         => 7);

   type MPU6050_PWR_MGMT_1_Register is record
      CLKSEL       : MPU6050_CLKSEL_Type := Internal;
      TEMP_DIS     : Boolean             := False;
      Reserved     : Boolean             := False;
      CYCLE        : Boolean             := False;
      SLEEP        : Boolean             := False;
      DEVICE_RESET : Boolean             := False;
   end record
     with Pack, Object_Size => 8;

   --------------------------------
   -- Internal_Enable_Interrupts --
   --------------------------------

   overriding procedure Internal_Enable_Interrupts
     (Self    : in out MPU6050_Sensor;
      Success : in out Boolean)
   is
      INT_ENABLE : MPU6050_INT_ENABLE_Register :=
        (DATA_RDY_EN => True, others => False);
      Buffer     : Interfaces.Unsigned_8 with Address => INT_ENABLE'Address;
      INT_PIN_CFG : INT_PIN_CFG_Register :=
        (LATCH_INT_EN => False,
         ACTL         => True,
         OPEN         => False,
         INT_ANYRD_2CLEAR => True,
         others       => <>);
      Buffer_2   : Interfaces.Unsigned_8 with Address => INT_PIN_CFG'Address;

   begin
      if not Success then
         return;
      end if;

      Self.Bus.Write_Synchronous
        --  (Self.Device, INT_PIN_CFG_Address, 16#80#, Success);
        (Self.Device, INT_PIN_CFG_Address, Buffer_2, Success);
      Self.Bus.Write_Synchronous
        --  (Self.Device, INT_ENABLE_Address, 16#01#, Success);
        (Self.Device, INT_ENABLE_Address, Buffer, Success);
      Self.Bus.Write_Synchronous
        (Self.Device, PWR_MGMT_2_Address, 16#00#, Success);
   end Internal_Enable_Interrupts;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self    : in out MPU6050_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean) is
   begin
      Self.Internal_Probe (MPU6050_WHOAMI, Success);

      if not Success then
         --  Check may be removed after change convention about Success in I2C.

         return;
      end if;

      --  Reset

      declare
         PWR_MGMT_1 : MPU6050_PWR_MGMT_1_Register :=
           (DEVICE_RESET => True,
            CLKSEL       => Internal,
            others       => False);
         Buffer     : Interfaces.Unsigned_8 with Address => PWR_MGMT_1'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device, MPU.PWR_MGMT_1_Address, Buffer, Success);

         if not Success then
            return;
         end if;
      end;

      Delays.Delay_Milliseconds (100);

      --  Wakeup

      declare
         PWR_MGMT_1 : MPU6050_PWR_MGMT_1_Register :=
           (DEVICE_RESET => False,
            CLKSEL       => PLL_X,
            --  CLKSEL       => Internal,
            others       => False);
         Buffer     : Interfaces.Unsigned_8 with Address => PWR_MGMT_1'Address;

      begin
         if not Success then
            return;
         end if;

         Self.Bus.Write_Synchronous
           (Self.Device, MPU.PWR_MGMT_1_Address, Buffer, Success);
      end;

      --  Initialize common data structures and defaults.

      Self.Internal_Initialize (Success);
   end Initialize;

end BBF.Drivers.MPU.MPU6050;
