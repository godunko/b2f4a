------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                        Hardware Abstraction Layer                        --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

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
      if Cycles = 0 then
         return;
      end if;

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
