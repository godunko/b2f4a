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

package body BBF.Drivers.MPU.MPU6500 is

   MPU6500_WHOAMI : constant := 16#70#;

   ACCEL_CONFIG_2_Address : constant := 16#1D#;

   type MPU_6500_PWR_MGMT_1_Register is record
      CLKSEL       : MPU_6500_CLKSEL_Type := Internal;
      TEMP_DIS     : Boolean              := False;
      GYRO_STANDBY : Boolean              := False;
      CYCLE        : Boolean              := False;
      SLEEP        : Boolean              := False;
      DEVICE_RESET : Boolean              := False;
   end record
     with Pack, Object_Size => 8;

   type A_DLPF_CFG_Type is mod 2**3;

   type ACCEL_CONFIG_2_Register is record
      A_DLPF_CFG       : A_DLPF_CFG_Type := 0;
      ACCEL_F_CHOICE_B : Boolean         := False;
      Reserved_4       : Boolean         := False;
      Reserved_5       : Boolean         := False;
      FIFO_SIZE_1024   : Boolean         := False;  --  Not documented.
      Reserved_7       : Boolean         := False;
   end record
     with Pack, Object_Size => 8;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self    : in out MPU6500_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean) is
   begin
      Self.Internal_Probe (MPU6500_WHOAMI, Success);

      if not Success then
         --  Check may be removed after change convention about Success in I2C.

         return;
      end if;

      --  Reset

      declare
         PWR_MGMT_1 : MPU_6500_PWR_MGMT_1_Register :=
           (DEVICE_RESET => True,
            CLKSEL       => Internal,
            others       => False);
         Buffer     : Interfaces.Unsigned_8 with Address => PWR_MGMT_1'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device, PWR_MGMT_1_Address, Buffer, Success);

         if not Success then
            return;
         end if;
      end;

      Delays.Delay_Milliseconds (100);

      --  Wakeup

      declare
         PWR_MGMT_1 : MPU_6500_PWR_MGMT_1_Register :=
           (DEVICE_RESET => False,
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

      --  Initialize common data structures and defaults.

      Self.Internal_Initialize (Success);
   end Initialize;

   -------------------------
   -- Internal_Initialize --
   -------------------------

   overriding procedure Internal_Initialize
     (Self    : in out MPU6500_Sensor;
      Success : in out Boolean)
   is
   begin
      if not Success then
         return;
      end if;

      --  MPU6500 shares 4kB of memory between the DMP and the FIFO. Since the
      --  first 3kB are needed by the DMP, we'll use the last 1kB for the FIFO.

      declare
         ACCEL_CONFIG_2 : ACCEL_CONFIG_2_Register :=
           (FIFO_SIZE_1024 => True,
            ACCEL_F_CHOICE_B => True,
            others => <>);
         Buffer      : Interfaces.Unsigned_8
           with Address => ACCEL_CONFIG_2'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device, ACCEL_CONFIG_2_Address, Buffer, Success);

         if not Success then
            return;
         end if;
      end;

      BBF.Drivers.MPU.Internal_Initialize
        (Abstract_MPU_Sensor (Self), Success);
   end Internal_Initialize;

end BBF.Drivers.MPU.MPU6500;
