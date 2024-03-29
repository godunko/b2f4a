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

--  Pulse Width Modulator (PWM)

pragma Restrictions (No_Elaboration_Code);

package BBF.PWM is

   pragma Pure;

   type Channel is limited interface;

end BBF.PWM;
