------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                           Hardware Proxy Layer                           --
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

with Ada.Unchecked_Conversion;

with BBF.HRI.PMC;

package body BBF.HPL.PMC is

   -----------------------------
   -- Enable_Peripheral_Clock --
   -----------------------------

   procedure Enable_Peripheral_Clock (Id : BBF.HPL.Peripheral_Identifier) is

      function To_Unsigned_8 is
        new Ada.Unchecked_Conversion
              (BBF.HPL.Peripheral_Identifier, Interfaces.Unsigned_8);

      Aux : constant Integer := Integer (To_Unsigned_8 (Id));

   begin
      if Aux < 32 then
         if not BBF.HRI.PMC.PMC_Periph.PMC_PCSR0.PID.Arr (Aux) then
            BBF.HRI.PMC.PMC_Periph.PMC_PCER0.PID.Arr (Aux) := True;
         end if;

      else
         if not BBF.HRI.PMC.PMC_Periph.PMC_PCSR1.PID.Arr (Aux) then
            BBF.HRI.PMC.PMC_Periph.PMC_PCER1.PID.Arr (Aux) := True;
         end if;
      end if;
   end Enable_Peripheral_Clock;

end BBF.HPL.PMC;
