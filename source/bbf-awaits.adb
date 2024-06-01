--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with A0B.ARMv7M.CMSIS;
with A0B.Callbacks.Generic_Subprogram;

package body BBF.Awaits is

   procedure On_Callback (Self : in out Await);

   package Callbacks is
     new A0B.Callbacks.Generic_Subprogram (Await, On_Callback);

   ---------------------
   -- Create_Callback --
   ---------------------

   function Create_Callback
     (Self : aliased in out Await) return A0B.Callbacks.Callback is
   begin
      pragma Assert (not Self.Busy);

      Self.Busy := True;

      return Callbacks.Create_Callback (Self);
   end Create_Callback;

   -----------------
   -- On_Callback --
   -----------------

   procedure On_Callback (Self : in out Await) is
   begin
      Self.Busy := False;
   end On_Callback;

   ---------------------------
   -- Suspend_Till_Callback --
   ---------------------------

   procedure Suspend_Till_Callback (Self : Await) is
   begin
      while Self.Busy loop
         A0B.ARMv7M.CMSIS.Wait_For_Interrupt;
      end loop;
   end Suspend_Till_Callback;

end BBF.Awaits;
