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

package BBF.Drivers.MPU.MPU6500 is

   pragma Preelaborate;

   type MPU6500_Sensor is new Abstract_MPU_Sensor with private;

   not overriding procedure Initialize
     (Self    : in out MPU6500_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean);

private

   type MPU_6500_CLKSEL_Type is
     (Internal,
      PLL_Auto_1,
      PLL_Auto_2,
      PLL_Auto_3,
      PLL_Auto_4,
      PLL_Auto_5,
      Internal_20_M,
      Stop)
     with Size => 3;
   for MPU_6500_CLKSEL_Type use
     (Internal      => 0,
      PLL_Auto_1    => 1,
      PLL_Auto_2    => 2,
      PLL_Auto_3    => 3,
      PLL_Auto_4    => 4,
      PLL_Auto_5    => 5,
      Internal_20_M => 6,
      Stop          => 7);

   type MPU6500_Sensor is new Abstract_MPU_Sensor with null record;

   overriding procedure Internal_Initialize
     (Self    : in out MPU6500_Sensor;
      Success : in out Boolean);

   overriding function Is_6500_9250
     (Self : MPU6500_Sensor) return Boolean is (True);

end BBF.Drivers.MPU.MPU6500;
