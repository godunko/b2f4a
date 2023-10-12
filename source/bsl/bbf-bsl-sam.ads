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

--  This package provides base type of mixed purpose EI/PIO pin.

pragma Restrictions (No_Elaboration_Code);

with BBF.External_Interrupts;
with BBF.GPIO;

package BBF.BSL.SAM is

   pragma Pure;

   type Pin is limited interface
     and BBF.External_Interrupts.Pin
     and BBF.GPIO.Pin;

end BBF.BSL.SAM;
