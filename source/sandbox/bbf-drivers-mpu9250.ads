------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--   MPU-9250: The Motion Processing Unit

pragma Restrictions (No_Elaboration_Code);

with BBF.Drivers.MPU.MPU6500.MPU9250;

package BBF.Drivers.MPU9250 renames BBF.Drivers.MPU.MPU6500.MPU9250;
