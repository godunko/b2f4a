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

--  General Purpose Input-Output (GPIO)

pragma Restrictions (No_Elaboration_Code);

with BBF.GPIO;
with BBF.HPL.PIO;
with BBF.HRI.PIO;

package BBF.BSL.GPIO is

   pragma Preelaborate;

   type SAM3_GPIO_Pin
    (Controller : not null access BBF.HRI.PIO.PIO_Peripheral;
     Pin        : BBF.HPL.PIO.PIO_Pin) is
       limited new BBF.GPIO.Pin with record
      null;
   end record;

   overriding procedure Set_Direction
    (Self : SAM3_GPIO_Pin; To : BBF.GPIO.Direction);

   overriding procedure Set (Self : SAM3_GPIO_Pin; To : Boolean);

   overriding function Get (Self : SAM3_GPIO_Pin) return Boolean;

   procedure Set_Peripheral
    (Self : SAM3_GPIO_Pin'Class;
     To   : BBF.HPL.PIO.Peripheral_Function);
   --  Configure pin to be used by given periperal function instead of GPIO.

end BBF.BSL.GPIO;
