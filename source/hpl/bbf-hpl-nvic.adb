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

pragma Restrictions (No_Elaboration_Code);

with Ada.Unchecked_Conversion;

package body BBF.HPL.NVIC is

   ----------------------
   -- Enable_Interrupt --
   ----------------------

   procedure Enable_Interrupt (Id : BBF.HPL.Peripheral_Identifier) is

      use type BBF.HRI.UInt32;

      function To_Unsigned_8 is
        new Ada.Unchecked_Conversion
              (Peripheral_Identifier, Interfaces.Unsigned_8);

      Aux : constant Integer := Integer (To_Unsigned_8 (Id));

   begin
      if Aux < 32 then
         BBF.HRI.NVIC.NVIC_Periph.ISER0 := 2 ** Aux;

      else
         BBF.HRI.NVIC.NVIC_Periph.ISER1 := 2 ** (Aux mod 32);
      end if;
   end Enable_Interrupt;

end BBF.HPL.NVIC;
