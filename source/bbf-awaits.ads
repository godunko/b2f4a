--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Await till callback.

private with Ada.Synchronous_Task_Control;

with A0B.Callbacks;

package BBF.Awaits
  with Preelaborate
is

   type Await is limited private;

   function Create_Callback
     (Self : aliased in out Await) return A0B.Callbacks.Callback;
   --  Returns callback object that unblocks call of Delay_Till.

   procedure Suspend_Till_Callback (Self : in out Await);
   --  Suspend execution till callback has been called.

private

   type Await is limited record
      Barrier : aliased Ada.Synchronous_Task_Control.Suspension_Object;
   end record;

end BBF.Awaits;
