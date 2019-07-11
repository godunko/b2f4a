------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                           Board Support Layer                            --
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
--  This version of the package provides definitions for Arduino Due/X board.

--  pragma Restrictions (No_Elaboration_Code);

with BBF.GPIO;
private with BBF.HRI.PIO;
private with BBF.BSL.GPIO;

package BBF.Board is

   pragma Preelaborate;

   Pin_SCL1 : constant not null access BBF.GPIO.Pin'Class;
   Pin_SDA1 : constant not null access BBF.GPIO.Pin'Class;

   Pin_20   : constant not null access BBF.GPIO.Pin'Class;
   Pin_SDA  : constant not null access BBF.GPIO.Pin'Class;
   Pin_21   : constant not null access BBF.GPIO.Pin'Class;
   Pin_SCL  : constant not null access BBF.GPIO.Pin'Class;

private

   PA17_TWD0_Pin  : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
         Pin        => 17);
   PA18_TWCK0_Pin : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
         Pin        => 18);

   PB12_TWD1_Pin  : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 12);
   PB13_TWCK0_Pin : aliased BBF.BSL.GPIO.SAM3_GPIO_Pin
     := (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
         Pin        => 13);

   Pin_SCL1 : constant not null access BBF.GPIO.Pin'Class
     := PA18_TWCK0_Pin'Access;
   Pin_SDA1 : constant not null access BBF.GPIO.Pin'Class
     := PA17_TWD0_Pin'Access;

   Pin_20   : constant not null access BBF.GPIO.Pin'Class
     := PB12_TWD1_Pin'Access;
   Pin_SDA  : constant not null access BBF.GPIO.Pin'Class
     := PB12_TWD1_Pin'Access;
   Pin_21   : constant not null access BBF.GPIO.Pin'Class
     := PB13_TWCK0_Pin'Access;
   Pin_SCL  : constant not null access BBF.GPIO.Pin'Class
     := PB13_TWCK0_Pin'Access;

end BBF.Board;
