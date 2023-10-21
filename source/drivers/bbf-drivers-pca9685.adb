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

package body BBF.Drivers.PCA9685 is

   OSC_CLOCK : constant := 25_000_000;
   --  Internal oscillator frequency.

   MODE1_Address         : constant BBF.I2C.Internal_Address_8 := 16#00#;
   LED0_ON_L_Address     : constant BBF.I2C.Internal_Address_8 := 16#06#;
   ALL_LED_ON_H_Address  : constant BBF.I2C.Internal_Address_8 := 16#FA#;
   ALL_LED_OFF_H_Address : constant BBF.I2C.Internal_Address_8 := 16#FD#;
   PRE_SCALE_Address     : constant BBF.I2C.Internal_Address_8 := 16#FE#;

   type MODE1_Register is record
      ALLCALL : Boolean := True;
      SUB3    : Boolean := False;
      SUB2    : Boolean := False;
      SUB1    : Boolean := False;
      SLEEP   : Boolean := True;
      AI      : Boolean := False;
      EXTCLK  : Boolean := False;
      RESTART : Boolean := False;
   end record
     with Size => 8;

   for MODE1_Register use record
      ALLCALL at 0 range 0 .. 0;
      SUB3    at 0 range 1 .. 1;
      SUB2    at 0 range 2 .. 2;
      SUB1    at 0 range 3 .. 3;
      SLEEP   at 0 range 4 .. 4;
      AI      at 0 range 5 .. 5;
      EXTCLK  at 0 range 6 .. 6;
      RESTART at 0 range 7 .. 7;
   end record;

   type OUTNE_Mode is (Off, OUTDRV, High_Impendance)
     with Size => 2;

   type MODE2_Register is record
      OUTNE      : OUTNE_Mode := Off;
      OUTDRV     : Boolean    := True;
      OCH        : Boolean    := False;
      INVRT      : Boolean    := False;
      Reserved_5 : Boolean    := False;
      Reserved_6 : Boolean    := False;
      Reserved_7 : Boolean    := False;
   end record
     with Size => 8;

   for MODE2_Register use record
      OUTNE      at 0 range 0 .. 1;
      OUTDRV     at 0 range 2 .. 2;
      OCH        at 0 range 3 .. 3;
      INVRT      at 0 range 4 .. 4;
      Reserved_5 at 0 range 5 .. 5;
      Reserved_6 at 0 range 6 .. 6;
      Reserved_7 at 0 range 7 .. 7;
   end record;

   type Mode_Register is record
      MODE1 : MODE1_Register;
      MODE2 : MODE2_Register;
   end record;

   procedure On_Transmit_Done (Closure : System.Address);

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Self      : in out PCA9685_Controller_Driver'Class;
      Frequency : Interfaces.Unsigned_16;
      Success   : in out Boolean)
   is
      use type Interfaces.Unsigned_16;

      --  Equation (1) in 7.3.5 assume use of real numbers. Modified version is
      --  used to produce same result with integer operations only.

      Scale       : constant Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8
         ((Interfaces.Unsigned_16 (2 * OSC_CLOCK / 4_096) / Frequency - 1) / 2);

      MODE        : MODE_Register;
      MODE_Buffer : BBF.I2C.Unsigned_8_Array (1 .. 2)
        with Address => MODE'Address;

   begin
      if not Success or not Self.Initialized then
         Success := False;

         return;
      end if;

      --  Configure PCA9685 to be in sleep state. Sleep state is necessary
      --  to write PRE_SCALE register.
      --
      --  XXX Should some parameters be configurable?

      MODE.MODE1 :=
        (AI      => True,    --  Default: FALSE
         --  Enable autoincrement to write many registers by single I2C bus
         --  write operation.
         EXTCLK  => False,   --  Default: FALSE
         SLEEP   => True,    --  Default: TRUE
         RESTART => False,   --  Default: FALSE
         SUB1    => False,   --  Default: FALSE
         SUB2    => False,   --  Default: FALSE
         SUB3    => False,   --  Default: FALSE
         ALLCALL => False);  --  Default: TRUE
         --  ALLCALL address is not used, but may conflict with another device
         --  on I2C bus.

      MODE.MODE2 :=
        (OUTDRV     => True,    --  Default: TRUE
         OUTNE      => Off,     --  Default: OFF
         OCH        => False,   --  Default: FALSE
         INVRT      => False,   --  Default: FALSE
         Reserved_5 => False,   --  Default: FALSE
         Reserved_6 => False,   --  Default: FALSE
         Reserved_7 => False);  --  Default: FALSE

      Self.Bus.Write_Synchronous
        (Self.Device, MODE1_Address, MODE_Buffer, Success);

      if not Success then
         return;
      end if;

      --  Configure PRE_SCALE register.

      Self.Bus.Write_Synchronous
       (Self.Device, PRE_SCALE_Address, Scale, Success);

      if not Success then
         return;
      end if;

      --  Wakeup controller.

      MODE.MODE1.SLEEP := False;
      Self.Bus.Write_Synchronous
        (Self.Device, MODE1_Address, MODE_Buffer (1 .. 1), Success);

      if not Success then
         return;
      end if;
   end Configure;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self    : in out PCA9685_Controller_Driver'Class;
      Success : in out Boolean) is
   begin
      Self.Initialized := False;

      --  Do controller's probe.

      Success := Self.Bus.Probe (Self.Device);

      if not Success then
         return;
      end if;

      --  Shutdown all channels. It resets RESTART mode too.
      --
      --  It is down by setting of bit 4 in ALL_LED_OFF_H register.

      declare
         R : constant Registers.LED_OFF_H_Register :=
           (Count => 0, Off => True, others => False);
         B : BBF.I2C.Unsigned_8_Array (1 .. 1) with Address => R'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device, ALL_LED_OFF_H_Address, B, Success);

         if not Success then
            return;
         end if;
      end;

      --  Configure PCA9685 to almost default configuration and push into the
      --  sleep state. Sleep state is necessary be able to write PRE_SCALE
      --  register.
      --
      --  Difference from the default configuration:
      --   - AI (autoincrement) is enabled
      --   - ALLCALL mode is disable
      --   - PRE_SCALE register is not changed (it will be set by configuration
      --     procedure)

      declare
         MODE        : MODE_Register;
         MODE_Buffer : BBF.I2C.Unsigned_8_Array (1 .. 2)
           with Address => MODE'Address;

      begin
         MODE.MODE1 :=
           (AI      => True,    --  Default: FALSE
            --  Enable autoincrement to write many registers by single I2C bus
            --  write operation.
            EXTCLK  => False,   --  Default: FALSE
            SLEEP   => True,    --  Default: TRUE
            RESTART => False,   --  Default: FALSE
            SUB1    => False,   --  Default: FALSE
            SUB2    => False,   --  Default: FALSE
            SUB3    => False,   --  Default: FALSE
            ALLCALL => False);  --  Default: TRUE
           --  ALLCALL address is not used, but may conflict with another
           --  device I2C bus.

         MODE.MODE2 :=
           (OUTDRV     => True,    --  Default: TRUE
            OUTNE      => Off,     --  Default: OFF
            OCH        => False,   --  Default: FALSE
            INVRT      => False,   --  Default: FALSE
            Reserved_5 => False,   --  Default: FALSE
            Reserved_6 => False,   --  Default: FALSE
            Reserved_7 => False);  --  Default: FALSE

         Self.Bus.Write_Synchronous
           (Self.Device, MODE1_Address, MODE_Buffer, Success);

         if not Success then
            return;
         end if;
      end;

      Self.Buffer      := (others => <>);
      Self.Initialized := True;
   end Initialize;

   ---------
   -- Off --
   ---------

   overriding procedure Off (Self : in out PCA9685_Channel_Driver) is
      use type Interfaces.Unsigned_8;
      use type BBF.PCA9685.Value_Type;

      Base    : constant Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8 (Self.Channel) * 4 + LED0_ON_L_Address;
      Success : Boolean := True;

   begin
      Self.Controller.Buffer (Self.Channel) :=
        (LED_ON_L  => (Count => 0),
         LED_ON_H  => (Count => 0, On => False, others => <>),
         LED_OFF_L => (Count => 0),
         LED_OFF_H => (Count => 0, Off => True, others => <>));
      Self.Controller.Bus.Write_Asynchronous
        (Device     => Self.Controller.Device,
         Register   => Base,
         Data       => Self.Controller.Buffer (Self.Channel)'Address,
         Length     => 4,
         On_Success => On_Transmit_Done'Access,
         On_Error   => On_Transmit_Done'Access,
         Closure    => Self'Address,
         Success    => Success);

      if not Success then
         raise Program_Error;
      end if;
   end Off;

   ---------
   -- Off --
   ---------

   overriding procedure Off (Self : in out PCA9685_Controller_Driver) is
      Value   : constant Registers.LEDXX_Register :=
        (LED_ON_L  => (Count => 0),
         LED_ON_H  => (Count => 0, On => False, others => <>),
         LED_OFF_L => (Count => 0),
         LED_OFF_H => (Count => 0, Off => True, others => <>));
      Success : Boolean := True;

   begin
      for J in Self.Buffer'Range loop
         Self.Buffer (J) := Value;
      end loop;

      Self.Bus.Write_Asynchronous
        (Device     => Self.Device,
         Register   => ALL_LED_ON_H_Address,
         Data       => Self.Buffer (Self.Buffer'First)'Address,
         --  Operation is asynchronous, and Value is local variable and can't
         --  be used.
         Length     => 4,
         On_Success => null,
         On_Error   => null,
         Closure    => System.Null_Address,
         Success    => Success);

      if not Success then
         raise Program_Error;
      end if;
   end Off;

   --------
   -- On --
   --------

   overriding procedure On (Self : in out PCA9685_Channel_Driver) is
      use type Interfaces.Unsigned_8;
      use type BBF.PCA9685.Value_Type;

      Base    : constant Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8 (Self.Channel) * 4 + LED0_ON_L_Address;
      Success : Boolean := True;

   begin
      Self.Controller.Buffer (Self.Channel) :=
        (LED_ON_L  => (Count => 0),
         LED_ON_H  => (Count => 0, On => True, others => <>),
         LED_OFF_L => (Count => 0),
         LED_OFF_H => (Count => 0, Off => False, others => <>));
      Self.Controller.Bus.Write_Asynchronous
        (Device     => Self.Controller.Device,
         Register   => Base,
         Data       => Self.Controller.Buffer (Self.Channel)'Address,
         Length     => 4,
         On_Success => On_Transmit_Done'Access,
         On_Error   => On_Transmit_Done'Access,
         Closure    => Self'Address,
         Success    => Success);

      if not Success then
         raise Program_Error;
      end if;
   end On;

   --------
   -- On --
   --------

   overriding procedure On (Self : in out PCA9685_Controller_Driver) is
      Value   : constant Registers.LEDXX_Register :=
        (LED_ON_L  => (Count => 0),
         LED_ON_H  => (Count => 0, On => True, others => <>),
         LED_OFF_L => (Count => 0),
         LED_OFF_H => (Count => 0, Off => False, others => <>));
      Success : Boolean := True;

   begin
      for J in Self.Buffer'Range loop
         Self.Buffer (J) := Value;
      end loop;

      Self.Bus.Write_Asynchronous
        (Device     => Self.Device,
         Register   => ALL_LED_ON_H_Address,
         Data       => Self.Buffer (Self.Buffer'First)'Address,
         --  Operation is asynchronous, and Value is local variable and can't
         --  be used.
         Length     => 4,
         On_Success => null,
         On_Error   => null,
         Closure    => System.Null_Address,
         Success    => Success);

      if not Success then
         raise Program_Error;
      end if;
   end On;

   ----------------------
   -- On_Transmit_Done --
   ----------------------

   procedure On_Transmit_Done (Closure : System.Address) is
   begin
      null;
   end On_Transmit_Done;

   ---------
   -- Set --
   ---------

   overriding procedure Set
     (Self  : in out PCA9685_Channel_Driver;
      On    : BBF.PCA9685.Value_Type;
      Off   : BBF.PCA9685.Value_Type)
   is
      use type Interfaces.Unsigned_8;
      use type BBF.PCA9685.Value_Type;

      Base    : constant Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8 (Self.Channel) * 4 + LED0_ON_L_Address;
      Success : Boolean := True;

   begin
      Self.Controller.Buffer (Self.Channel) :=
        (LED_ON_L  => (Count => Registers.LSB_Count (On mod 256)),
         LED_ON_H  =>
           (Count => Registers.MSB_Count (On / 256), On => False, others => <>),
         LED_OFF_L => (Count => Registers.LSB_Count (Off mod 256)),
         LED_OFF_H =>
           (Count => Registers.MSB_Count (Off / 256), Off => False, others => <>));
      Self.Controller.Bus.Write_Asynchronous
        (Device     => Self.Controller.Device,
         Register   => Base,
         Data       => Self.Controller.Buffer (Self.Channel)'Address,
         Length     => 4,
         On_Success => On_Transmit_Done'Access,
         On_Error   => On_Transmit_Done'Access,
         Closure    => Self'Address,
         Success    => Success);

      if not Success then
         raise Program_Error;
      end if;
   end Set;

end BBF.Drivers.PCA9685;
