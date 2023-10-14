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

--   MPU-9150: The Motion Processing Unit

pragma Restrictions (No_Elaboration_Code);

with BBF.Delays;
with BBF.Drivers.MPU.MPU6050;

package BBF.Drivers.MPU.MPU9150 is

   pragma Preelaborate;

   type MPU9150_Sensor is new Abstract_MPU_Sensor with private;

   procedure Initialize
     (Self    : in out MPU9150_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean);

private

   type MPU9150_Sensor is new MPU6050.MPU6050_Sensor with null record;

end BBF.Drivers.MPU.MPU9150;
