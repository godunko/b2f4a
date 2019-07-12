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

with BBF.BSL.Clocks;

package body BBF.BSL.Delays is

   procedure Delay_Cycles
    (Self   : SAM_SYSTICK_Controller'Class;
     Cycles : BBF.HRI.UInt32);
   --  Delay loop to delay n number of cycles

   function Milliseconds_To_Cycles
    (Milliseconds : Interfaces.Unsigned_32) return BBF.HRI.UInt32;
   --  Retrieve the amount of cycles to delay for the given amount of ms

   ------------------
   -- Delay_Cycles --
   ------------------

   procedure Delay_Cycles
    (Self   : SAM_SYSTICK_Controller'Class;
     Cycles : BBF.HRI.UInt32)
   is
      use type BBF.HRI.UInt32;

      Rounds    : constant BBF.HRI.UInt32 := Cycles / 16#0100_0000#;
      --  Number of full rounds of maximal value of SysTick counter.

      Remaining : constant BBF.HRI.UInt24
        := BBF.HRI.UInt24 (Cycles and 16#00FF_FFFF#);
      --  Number of remaining cycles.

   begin
      for J in 1 .. Rounds loop
         BBF.HRI.SYST.SYST_Periph.LOAD.RELOAD := 16#FF_FFFF#;
         BBF.HRI.SYST.SYST_Periph.VAL.CURRENT := 16#00_0000#;

         while not BBF.HRI.SYST.SYST_Periph.CTRL.COUNTFLAG loop
            null;
         end loop;
      end loop;

      BBF.HRI.SYST.SYST_Periph.LOAD.RELOAD := Remaining;
      BBF.HRI.SYST.SYST_Periph.VAL.CURRENT := 16#00_0000#;

      while not BBF.HRI.SYST.SYST_Periph.CTRL.COUNTFLAG loop
         null;
      end loop;
   end Delay_Cycles;

   ------------------------
   -- Delay_Milliseconds --
   ------------------------

   overriding procedure Delay_Milliseconds
    (Self         : SAM_SYSTICK_Controller;
     Milliseconds : Interfaces.Unsigned_32) is
   begin
      Self.Delay_Cycles (Milliseconds_To_Cycles (Milliseconds));
   end Delay_Milliseconds;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Self : in out SAM_SYSTICK_Controller'Class) is
   begin
      BBF.HRI.SYST.SYST_Periph.LOAD.RELOAD := 16#FF_FFFF#;
      Self.Controller.CTRL :=
       (ENABLE    => True,
        CLKSOURCE => BBF.HRI.SYST.MCK,
        others => <>);
   end Initialize;

   ----------------------------
   -- Milliseconds_To_Cycles --
   ----------------------------

   function Milliseconds_To_Cycles
    (Milliseconds : Interfaces.Unsigned_32) return BBF.HRI.UInt32
   is
      use type BBF.HRI.UInt32;

   begin
      return
        BBF.HRI.UInt32 (Milliseconds)
          * (BBF.BSL.Clocks.Main_Clock_Frequency / 1_000);
   end Milliseconds_To_Cycles;

end BBF.BSL.Delays;
