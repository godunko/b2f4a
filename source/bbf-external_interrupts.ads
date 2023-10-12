------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                        Hardware Abstraction Layer                        --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  External Interrupts

pragma Restrictions (No_Elaboration_Code);

with System;

package BBF.External_Interrupts is

   pragma Pure;

   type Pin is limited interface;

   type Interrupt_Mode is
     (Rising_Edge,
      Falling_Edge,
      Low_Level,
      High_Level);

   not overriding procedure Configure
     (Self : in out Pin; Mode : Interrupt_Mode) is abstract;
   --  Configure interrupt signal detection mode.

   not overriding procedure Enable_Interrupt (Self : in out Pin) is abstract;
   --  Enable the external interrupt on the given pin.

   not overriding procedure Disable_Interrupt (Self : in out Pin) is abstract;
   --  Disable the external interrupt on the given pin.

   not overriding procedure Set_Handler
     (Self    : in out Pin;
      Handler : BBF.Callback;
      Closure : System.Address) is abstract;
   --  Sets interrupt handler subprogram.

end BBF.External_Interrupts;
