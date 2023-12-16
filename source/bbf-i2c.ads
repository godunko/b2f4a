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

--  General type for I2C bus

pragma Restrictions (No_Elaboration_Code);

with Interfaces;

package BBF.I2C is

   pragma Preelaborate;

   type Device_Address is mod 2 ** 7;
   for Device_Address'Size use 7;

   subtype Internal_Address_8 is Interfaces.Unsigned_8;

end BBF.I2C;
