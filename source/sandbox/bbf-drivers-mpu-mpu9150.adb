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

pragma Restrictions (No_Elaboration_Code);

package body BBF.Drivers.MPU.MPU9150 is

   ----------------
   -- Initialize --
   ----------------

   overriding procedure Initialize
     (Self    : in out MPU9150_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean) is
   begin
      BBF.Drivers.MPU.MPU6050.Initialize
        (BBF.Drivers.MPU.MPU6050.MPU6050_Sensor (Self), Delays, Success);

      --  XXX Initialize compass
   end Initialize;

end BBF.Drivers.MPU.MPU9150;
