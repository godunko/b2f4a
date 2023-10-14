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

--   MPU-6500: The Motion Processing Unit

pragma Restrictions (No_Elaboration_Code);

with BBF.Delays;

package BBF.Drivers.MPU.MPU6500 is

   pragma Preelaborate;

   type MPU6500_Sensor is new Abstract_MPU_Sensor with private;

   not overriding procedure Initialize
     (Self    : in out MPU6500_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean);

private

   type MPU6500_Sensor is new Abstract_MPU_Sensor with null record;

   overriding function Is_6500_9250
     (Self : MPU6500_Sensor) return Boolean is (True);

end BBF.Drivers.MPU.MPU6500;
