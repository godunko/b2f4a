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

package body BBF.HPL.RTT is

   ---------------------
   -- Get_Timer_Value --
   ---------------------

   function Get_Timer_Value
    (Self : BBF.HRI.SYSC.RTT_Peripheral) return Interfaces.Unsigned_32
   is
      use type Interfaces.Unsigned_32;

   begin
      return Result : Interfaces.Unsigned_32
               := Interfaces.Unsigned_32 (Self.VR)
      do
	 --  The Real-Time Timer value can be updated asynchronously from the
         --  Master Clock, follow advise to read this register twice at the
         --  same value to improve accuracy of the returned value.

         while Result /= Interfaces.Unsigned_32 (Self.VR) loop
            Result := Interfaces.Unsigned_32 (Self.VR);
         end loop;
      end return;
   end Get_Timer_Value;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
    (Self      : in out BBF.HRI.SYSC.RTT_Peripheral;
     Prescaler : Interfaces.Unsigned_16) is
   begin
      Self.MR :=
       (RTPRES    => BBF.HRI.UInt16 (Prescaler),
        RTTRST    => True,
        RTTINCIEN => False,
        ALMIEN    => False,
        others    => <>);
   end Initialize;

end BBF.HPL.RTT;
