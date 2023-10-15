------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Digital Motion Processor (DMP) Firmware 6.12 support for
--  MPU-6000/MPU-6050/MPU-6500/MPU-9150/MPU-9250 family.

pragma Restrictions (No_Elaboration_Code);

package BBF.Drivers.MPU.DMP612 is

   pragma Preelaborate;

   DMP_Sample_Rate : constant := 200;

   procedure Upload_Firmware
     (Self    : in out Abstract_MPU_Sensor'Class;
      Success : in out Boolean);

private

end BBF.Drivers.MPU.DMP612;
