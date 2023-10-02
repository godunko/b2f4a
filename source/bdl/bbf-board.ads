------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                         Board Description Layer                          --
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

--  This version of the package provides definitions for Arduino Due/X board.

with BBF.Clocks;
with BBF.Delays;
with BBF.GPIO;
private with BBF.HRI.PIO;
private with BBF.HRI.SYSC;
private with BBF.HRI.SYST;
private with BBF.BSL.Clocks;
private with BBF.BSL.Delays;
private with BBF.BSL.GPIO;

package BBF.Board is

   pragma Preelaborate;

   Pin_SCL1   : constant not null access BBF.GPIO.Pin'Class;
   Pin_SDA1   : constant not null access BBF.GPIO.Pin'Class;

   Pin_0_RX0  : constant not null access BBF.GPIO.Pin'Class;
   Pin_1_TD0  : constant not null access BBF.GPIO.Pin'Class;
   Pin_13_LED : constant not null access BBF.GPIO.Pin'Class;
   Pin_20_SDA : constant not null access BBF.GPIO.Pin'Class;
   Pin_21_SCL : constant not null access BBF.GPIO.Pin'Class;
   Pin_52     : constant not null access BBF.GPIO.Pin'Class;
   Pin_53     : constant not null access BBF.GPIO.Pin'Class;

   Delay_Controller :
     constant not null access BBF.Delays.Delay_Controller'Class;

   procedure Initialize_Delay_Controller;

   Real_Time_Clock_Controller :
     constant not null access BBF.Clocks.Real_Time_Clock_Controller'Class;

   procedure Initialize_Real_Time_Clock_Controller;

private

   PA08_URXD_Pin  : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
         Pin        => 8);
   PA09_UTXD_Pin  : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
         Pin        => 9);
   PA17_TWD0_Pin  : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
         Pin        => 17);
   PA18_TWCK0_Pin : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
         Pin        => 18);

   PB12_TWD1_Pin  : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 12);
   PB13_TWCK1_Pin : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 13);
   PB14_Pin       : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 14);
   PB21_Pin       : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 21);
   PB27_Pin       : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 27);

   Delay_Instance : aliased BBF.BSL.Delays.SAM_SYSTICK_Controller
     := (Controller => BBF.HRI.SYST.SYST_Periph'Access);

   Clock_Instance : aliased BBF.BSL.Clocks.SAM_RTT_Clock_Controller
     := (Controller => BBF.HRI.SYSC.RTT_Periph'Access);

   Pin_SCL1   : constant not null access BBF.GPIO.Pin'Class
     := PA18_TWCK0_Pin'Access;
   Pin_SDA1   : constant not null access BBF.GPIO.Pin'Class
     := PA17_TWD0_Pin'Access;

   Pin_0_RX0  : constant not null access BBF.GPIO.Pin'Class
     := PA08_URXD_Pin'Access;
   Pin_1_TD0  : constant not null access BBF.GPIO.Pin'Class
     := PA09_UTXD_Pin'Access;

   Pin_13_LED : constant not null access BBF.GPIO.Pin'Class
     := PB27_Pin'Access;

   Pin_20_SDA : constant not null access BBF.GPIO.Pin'Class
     := PB12_TWD1_Pin'Access;
   Pin_21_SCL : constant not null access BBF.GPIO.Pin'Class
     := PB13_TWCK1_Pin'Access;
   Pin_52     : constant not null access BBF.GPIO.Pin'Class
     := PB21_Pin'Access;
   Pin_53     : constant not null access BBF.GPIO.Pin'Class
     := PB14_Pin'Access;

   Delay_Controller :
     constant not null access BBF.Delays.Delay_Controller'Class
       := Delay_Instance'Access;

   Real_Time_Clock_Controller :
     constant not null access BBF.Clocks.Real_Time_Clock_Controller'Class
       := Clock_Instance'Access;

end BBF.Board;
