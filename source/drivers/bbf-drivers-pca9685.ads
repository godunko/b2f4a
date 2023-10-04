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

--  Driver for PCA9685: 16-channel, 12-bit PWM Fm+ I2C-bus LED controller

with Interfaces;

with BBF.I2C.Master;
with BBF.PWM;

package BBF.Drivers.PCA9685 is

   pragma Preelaborate;

   type Channel_Identifier is range 0 .. 15;

   type Value_Type is mod 2**12;

   type PCA9685_Controller
     (Bus : not null access BBF.I2C.Master.I2C_Master_Controller'Class)
       is tagged limited private;

   procedure Initialize
     (Self    : in out PCA9685_Controller'Class;
      Success : in out Boolean);
   --  Do controller's probe, disable all channels, shutdown internal
   --  oscillator, reset output configuration to default, and disable
   --  listening of SUB* and ALLCALL addresses.
   --
   --  Before use of any channel, controller must be configured.

   procedure Configure
     (Self      : in out PCA9685_Controller'Class;
      Frequency : Interfaces.Unsigned_16;
      Success   : in out Boolean);
   --  Configure controller and enable internal oscillator.
   --
   --  @param Frequency
   --    Frequency of the PWM signal in Hz.

   procedure Set_Something
     (Self    : in out PCA9685_Controller'Class;
      Channel : Channel_Identifier;
      Value   : Value_Type);

   type PCA9685_Channel is limited new BBF.PWM.Channel with null record;

private

   type PCA9685_Controller
     (Bus : not null access BBF.I2C.Master.I2C_Master_Controller'Class)
        is tagged limited
   record
      Initialized : Boolean := False;
      --  Controller has been initialized.
   end record;

end BBF.Drivers.PCA9685;
