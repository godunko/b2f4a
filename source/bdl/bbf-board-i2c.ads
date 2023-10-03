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

--  I2C interfaces for Arduino Due/X board

private with BBF.BSL.I2C_Masters;
private with BBF.HPL.PIO;
private with BBF.HRI.TWI;
with BBF.I2C.Master;

package BBF.Board.I2C is

   I2C0 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class;
   I2C1 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class;

   procedure Initialize_I2C_0;
   procedure Initialize_I2C_1;

private

   TWI0_I2C : aliased BBF.BSL.I2C_Masters.SAM3_I2C_Master_Controller
     := (Controller   => BBF.HRI.TWI.TWI0_Periph'Access,
         Peripheral   => BBF.HPL.Two_Wire_Interface_0,
         SCL          => PA18_TWCK0_Pin'Access,
         SCL_Function => BBF.HPL.PIO.A,
         SDA          => PA17_TWD0_Pin'Access,
         SDA_Function => BBF.HPL.PIO.A);
   TWI1_I2C : aliased BBF.BSL.I2C_Masters.SAM3_I2C_Master_Controller
     := (Controller   => BBF.HRI.TWI.TWI1_Periph'Access,
         Peripheral   => BBF.HPL.Two_Wire_Interface_1,
         SCL          => PB13_TWCK1_Pin'Access,
         SCL_Function => BBF.HPL.PIO.A,
         SDA          => PB12_TWD1_Pin'Access,
         SDA_Function => BBF.HPL.PIO.A);

   I2C0 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class
     := TWI0_I2C'Access;
   I2C1 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class
     := TWI1_I2C'Access;

end BBF.Board.I2C;
