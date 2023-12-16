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

pragma Restrictions (No_Elaboration_Code);

with System;

package BBF is

   pragma Pure;

   type Unsigned_1 is mod 2 ** 1;
   type Unsigned_8 is mod 2 ** 8;
   type Unsigned_16 is mod 2 ** 16;

   --  subtype Bit is Unsigned_1; / is Boolean; ???
   subtype Byte is Unsigned_8;

   type Unsigned_8_Array_16 is array (Unsigned_16 range <>) of Unsigned_8;
   subtype Byte_Array_16 is Unsigned_8_Array_16;

   type Callback is access procedure (Closure : System.Address);
   --  Callback function.
   --
   --  @param Closure  User defined data, provided on callback registration.

end BBF;
