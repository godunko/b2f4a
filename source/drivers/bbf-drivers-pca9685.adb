------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                        Runtime Library Component                         --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2019, Vadim Godunko <vgodunko@gmail.com>                     --
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

   MODE1_Address     : constant BBF.I2C.Internal_Address_8 := 16#00#;
   PRE_SCALE_Address : constant BBF.I2C.Internal_Address_8 := 16#FE#;

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
    (Self      : in out PCA9685_Controller'Class;
     Frequency : Interfaces.Unsigned_16)
   is
      use type Interfaces.Unsigned_16;

      Success : Boolean;
      Scale   : Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8
         (Interfaces.Unsigned_16 (OSC_CLOCK / 4_096) / Frequency - 1);

   begin
      Self.Bus.Write_Synchronous
       (Self.Device_Address, PRE_SCALE_Address, Scale, Success);

      if not Success then
         return;
      end if;

      --  Configure controller:
      --   - switch to normal mode
      --   - enable register auto-increment
      --   - disable ALLCALL address
      --   - set totem pole structure of output lines
      --   - invert output logic state

      declare
         Registers : constant MODE_Register
           := (MODE1 =>
                (AI      => True,
                 SLEEP   => False,
                 ALLCALL => False,
                 others  => <>),
               MODE2 =>
                (OUTDRV => True,
                 others => <>));
         Value    : BBF.I2C.Unsigned_8_Array (1 .. 2)
           with Import => True,
                Convention => Ada,
                Address    => Registers'Address;

      begin
         Self.Bus.Write_Synchronous
          (Self.Device_Address, MODE1_Address, Value, Success);

         if not Success then
            return;
         end if;
      end;
   end Initialize;

end BBF.Drivers.PCA9685;
