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

package body BBF.Drivers.MPU.MPU6500.MPU9250 is

   MPU9250_WHOAMI : constant := 16#71#;

   type MPU_9250_PWR_MGMT_1_Register is record
      CLKSEL       : MPU_6500_CLKSEL_Type := Internal;
      PD_PTAT      : Boolean              := False;
      GYRO_STANDBY : Boolean              := False;
      CYCLE        : Boolean              := False;
      SLEEP        : Boolean              := False;
      DEVICE_RESET : Boolean              := False;
   end record
     with Pack, Object_Size => 8;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self    : in out MPU9250_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean) is
   begin
      Self.Internal_Probe (MPU9250_WHOAMI, Success);

      if not Success then
         --  Check may be removed after change convention about Success in I2C.

         return;
      end if;

      --  Reset

      declare
         PWR_MGMT_1 : MPU_9250_PWR_MGMT_1_Register :=
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
         PWR_MGMT_1 : MPU_9250_PWR_MGMT_1_Register :=
           (DEVICE_RESET => False,
            CLKSEL       => Internal,
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

      --  XXX Initialize compass
   end Initialize;

end BBF.Drivers.MPU.MPU6500.MPU9250;
