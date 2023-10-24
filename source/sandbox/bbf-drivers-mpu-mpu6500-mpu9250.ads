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

package BBF.Drivers.MPU.MPU6500.MPU9250 is

   pragma Preelaborate;

   type MPU9250_Sensor is
     new Abstract_MPU_Sensor with private with Preelaborable_Initialization;

   procedure Initialize
     (Self    : in out MPU9250_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean);

private

   type MPU9250_Sensor is new MPU6500_Sensor with null record;

end BBF.Drivers.MPU.MPU6500.MPU9250;
