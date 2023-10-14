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

package body BBF.Drivers.MPU.MPU6500.MPU9250 is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self    : in out MPU9250_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean) is
   begin
      Self.Internal_Initialize (Delays, MPU9250_WHOAMI, Success);

      --  XXX Initialize compass
   end Initialize;

end BBF.Drivers.MPU.MPU6500.MPU9250;
