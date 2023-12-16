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

with Interfaces;

package body BBF.Drivers.BNO055 is

   CHIP_ID_Address        : constant BBF.I2C.Internal_Address_8 := 16#00#;
   GRV_DATA_X_LSB_Address : constant BBF.I2C.Internal_Address_8 := 16#2E#;
   OPR_MODE_Address       : constant BBF.I2C.Internal_Address_8 := 16#3D#;
   SYS_TRIGGER_Address    : constant BBF.I2C.Internal_Address_8 := 16#3F#;

   type OPR_MODE_Register is record
      Operation_Mode : BNO055.Operation_Mode;
      Reserved_4     : Boolean := False;
      Reserved_5     : Boolean := False;
      Reserved_6     : Boolean := False;
      Reserved_7     : Boolean := False;
   end record
     with Size => 8;
   for OPR_MODE_Register use record
      Operation_Mode at 0 range 0 .. 3;
      Reserved_4     at 0 range 4 .. 4;
      Reserved_5     at 0 range 5 .. 5;
      Reserved_6     at 0 range 6 .. 6;
      Reserved_7     at 0 range 7 .. 7;
   end record;

   type SYS_TRIGGER_Register is record
      Self_Test  : Boolean := False;
      Reserved_1 : Boolean := False;
      Reserved_2 : Boolean := False;
      Reserved_3 : Boolean := False;
      Reserved_4 : Boolean := False;
      RST_SYS    : Boolean := False;
      RST_INT    : Boolean := False;
      CLK_SEL    : Boolean := False;
   end record
      with Size => 8;
   for SYS_TRIGGER_Register use record
      Self_Test  at 0 range 0 .. 0;
      Reserved_1 at 0 range 1 .. 1;
      Reserved_2 at 0 range 2 .. 2;
      Reserved_3 at 0 range 3 .. 3;
      Reserved_4 at 0 range 4 .. 4;
      RST_SYS    at 0 range 5 .. 5;
      RST_INT    at 0 range 6 .. 6;
      CLK_SEL    at 0 range 7 .. 7;
   end record;

   type Gravity_Vector_Register is record
      X : Interfaces.Integer_16;
      Y : Interfaces.Integer_16;
      Z : Interfaces.Integer_16;
   end record;

   function Device_Address
    (Self : BNO055_Sensor'Class) return BBF.I2C.Device_Address;
   --  Return configured device address on I2C bus.

   function To_Linear_Acceleration
    (Item : Interfaces.Integer_16) return BBF.Motion.Linear_Acceleration;
   --  Converts linear acceleration from device units to HAL units.

   --------------------
   -- Device_Address --
   --------------------

   function Device_Address
    (Self : BNO055_Sensor'Class) return BBF.I2C.Device_Address is
   begin
      if Self.Alternative_Address then
         return 16#28#;

      else
         return 16#29#;
      end if;
   end Device_Address;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
    (Self : in out BNO055_Sensor'Class;
     Mode : Operation_Mode)
   is
      CHIP_ID_Buffer : BBF.Unsigned_8;
      Success        : Boolean;

   begin
      --  Obtain and check device identifier.

      Self.Controller.Read_Synchronous
       (Self.Device_Address, CHIP_ID_Address, CHIP_ID_Buffer, Success);

      if not Success or else CHIP_ID_Buffer /= 16#A0# then
         return;
      end if;

      --  Enable external oscillator.

      declare
         Register : constant SYS_TRIGGER_Register
           := (CLK_SEL => True, others => <>);
         Value    : BBF.Unsigned_8
           with Import     => True,
                Convention => Ada,
                Address    => Register'Address;

      begin
         Self.Controller.Write_Synchronous
          (Self.Device_Address, SYS_TRIGGER_Address, Value, Success);

         if not Success then
            return;
         end if;
      end;

      --  Configure operational mode.

      declare
         Value  : constant OPR_MODE_Register
           := (Operation_Mode => Mode, others => <>);
         Buffer : BBF.Unsigned_8
           with Import     => True,
                Convention => Ada,
                Address    => Value'Address;

      begin
         Self.Controller.Write_Synchronous
          (Self.Device_Address, OPR_MODE_Address, Buffer, Success);

         if not Success then
            return;
         end if;
      end;
   end Initialize;

   ------------------------
   -- Get_Gravity_Vector --
   ------------------------

   overriding procedure Get_Gravity_Vector
    (Self      : in out BNO055_Sensor;
     X         : out BBF.Motion.Linear_Acceleration;
     Y         : out BBF.Motion.Linear_Acceleration;
     Z         : out BBF.Motion.Linear_Acceleration;
     Timestamp : out BBF.Clocks.Time)
   is
      Register : Gravity_Vector_Register;
      Value    : BBF.Unsigned_8_Array_16 (1 .. 6)
        with Import     => True,
             Convention => Ada,
             Address    => Register'Address;
      Success  : Boolean;

   begin
      Self.Controller.Read_Synchronous
       (Self.Device_Address, GRV_DATA_X_LSB_Address, Value, Success);

      if Success then
         X         := To_Linear_Acceleration (Register.X);
         Y         := To_Linear_Acceleration (Register.Y);
         Z         := To_Linear_Acceleration (Register.Z);
         Timestamp := Self.Clock.Clock;

      else
         X         := 0.0;
         Y         := 0.0;
         Z         := 0.0;
         Timestamp := 0.0;
      end if;
   end Get_Gravity_Vector;

   ----------------------------
   -- To_Linear_Acceleration --
   ----------------------------

   function To_Linear_Acceleration
    (Item : Interfaces.Integer_16) return BBF.Motion.Linear_Acceleration
   is
      use type BBF.Motion.Linear_Acceleration;

   begin
      return BBF.Motion.Linear_Acceleration (Item) / 100.0;
   end To_Linear_Acceleration;

end BBF.Drivers.BNO055;
