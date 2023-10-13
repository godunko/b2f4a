------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                        Runtime Library Component                         --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2019-2023, Vadim Godunko <vgodunko@gmail.com>                --
-- All rights reserved.                                                     --
--                                                                          --
-- Redistribution and use in source and binary forms, with or without       --
-- modification, are permitted provided that the following conditions       --
-- are met:                                                                 --
--                                                                          --
--  * Redistributions of source code must retain the above copyright        --
--    notice, this list of conditions and the following disclaimer.         --
--                                                                          --
--  * Redistributions in binary form must reproduce the above copyright     --
--    notice, this list of conditions and the following disclaimer in the   --
--    documentation and/or other materials provided with the distribution.  --
--                                                                          --
--  * Neither the name of the Vadim Godunko, IE nor the names of its        --
--    contributors may be used to endorse or promote products derived from  --
--    this software without specific prior written permission.              --
--                                                                          --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT     --
-- HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   --
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED --
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   --
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     --
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       --
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             --
--                                                                          --
------------------------------------------------------------------------------

package body BBF.Drivers.PCA9685 is

   OSC_CLOCK : constant := 25_000_000;
   --  Internal oscillator frequency.

   MODE1_Address         : constant BBF.I2C.Internal_Address_8 := 16#00#;
   LED0_ON_L_Address     : constant BBF.I2C.Internal_Address_8 := 16#06#;
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

   function Device_Address
    (Self : PCA9685_Controller'Class) return BBF.I2C.Device_Address;
   --  Returns device address on I2C bus.

   procedure On_Transmit_Done (Closure : System.Address);

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Self      : in out PCA9685_Controller'Class;
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
        (Self.Device_Address, MODE1_Address, MODE_Buffer, Success);

      if not Success then
         return;
      end if;

      --  Configure PRE_SCALE register.

      Self.Bus.Write_Synchronous
       (Self.Device_Address, PRE_SCALE_Address, Scale, Success);

      if not Success then
         return;
      end if;

      --  Wakeup controller.

      MODE.MODE1.SLEEP := False;
      Self.Bus.Write_Synchronous
        (Self.Device_Address, MODE1_Address, MODE_Buffer (1 .. 1), Success);

      if not Success then
         return;
      end if;
   end Configure;

   --------------------
   -- Device_Address --
   --------------------

   function Device_Address
    (Self : PCA9685_Controller'Class) return BBF.I2C.Device_Address is
   begin
      --  XXX Address configuration is not supported yet.

      return 16#40#;
   end Device_Address;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self    : in out PCA9685_Controller'Class;
      Success : in out Boolean) is
   begin
      Self.Initialized := False;

      --  Do controller's probe.

      Success := Self.Bus.Probe (Self.Device_Address);

      if not Success then
         return;
      end if;

      --  Shutdown all channels. It resets RESTART mode too.
      --
      --  It is down by setting of bit 4 in ALL_LED_OFF_H register.

      declare
         R : constant LED_OFF_H_Register :=
           (Count => 0, Off => True, others => False);
         B : BBF.I2C.Unsigned_8_Array (1 .. 1) with Address => R'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device_Address, ALL_LED_OFF_H_Address, B, Success);

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
           (Self.Device_Address, MODE1_Address, MODE_Buffer, Success);

         if not Success then
            return;
         end if;
      end;

      Self.Buffer      := (others => <>);
      Self.Initialized := True;
   end Initialize;

   ----------------------
   -- On_Transmit_Done --
   ----------------------

   procedure On_Transmit_Done (Closure : System.Address) is
   begin
      null;
   end On_Transmit_Done;

   -------------------
   -- Set_Something --
   -------------------

   procedure Set_Something
     (Self    : in out PCA9685_Controller'Class;
      Channel : Channel_Identifier;
      Value   : Value_Type)
   is
      use type Interfaces.Unsigned_8;

      Base    : constant Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8 (Channel) * 4 + LED0_ON_L_Address;
      Success : Boolean := True;

   begin
      Self.Buffer (Channel) :=
        (LED_ON_L  => (Count => 0),
         LED_ON_H  => (Count => 0, others => <>),
         LED_OFF_L => (Count => LSB_Count (Value mod 256)),
         LED_OFF_H => (Count => MSB_Count (Value / 256), others => <>));
      Self.Bus.Write_Asynchronous
        (Device     => Self.Device_Address,
         Register   => Base,
         Data       => Self.Buffer (Channel)'Address,
         Length     => 4,
         On_Success => On_Transmit_Done'Access,
         On_Error   => On_Transmit_Done'Access,
         Closure    => Self'Address,
         Success    => Success);

      if not Success then
         raise Program_Error;
      end if;
   end Set_Something;

end BBF.Drivers.PCA9685;
