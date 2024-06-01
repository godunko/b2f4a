--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This is no tasking version of the package. It assumes that there is only
--  single "thread", so use of single global object is fine.

with A0B.ARMv7M.CMSIS;
with A0B.Callbacks.Generic_Parameterless;
with A0B.Timer;

package body BBF.Delays is

   procedure On_Delay;

   package On_Delay_Callbacks is
     new A0B.Callbacks.Generic_Parameterless (On_Delay);

   Delay_Timeout : aliased A0B.Timer.Timeout_Control_Block;
   Delay_Done    : Boolean := True with Volatile;

   ---------------
   -- Delay_For --
   ---------------

   procedure Delay_For (Interval : A0B.Time.Time_Span) is
   begin
      Delay_Done := False;

      A0B.Timer.Enqueue
        (Delay_Timeout, On_Delay_Callbacks.Create_Callback, Interval);

      while not Delay_Done loop
         A0B.ARMv7M.CMSIS.Wait_For_Interrupt;
      end loop;
   end Delay_For;

   --------------
   -- On_Delay --
   --------------

   procedure On_Delay is
   begin
      Delay_Done := True;
   end On_Delay;

end BBF.Delays;
