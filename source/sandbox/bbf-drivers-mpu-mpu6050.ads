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

--   MPU-6050: The Motion Processing Unit

pragma Restrictions (No_Elaboration_Code);

package BBF.Drivers.MPU.MPU6050 is

   pragma Preelaborate;

   type Sensor_Data is record
      Acceleration_X : Gravitational_Acceleration;
      Acceleration_Y : Gravitational_Acceleration;
      Acceleration_Z : Gravitational_Acceleration;
      Velocity_U     : Angular_Velosity;
      Velocity_V     : Angular_Velosity;
      Velocity_W     : Angular_Velosity;
      Temperature    : MPU.Temperature;
   end record;

   type MPU6050_Sensor is
     new Abstract_MPU_Sensor with private with Preelaborable_Initialization;

   not overriding procedure Initialize
     (Self    : in out MPU6050_Sensor;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      Success : in out Boolean);

   procedure Get
     (Self      : MPU6050_Sensor'Class;
      Data      : out Sensor_Data;
      Timestamp : out BBF.Clocks.Time);

private

   type MPU6050_Sensor is new Abstract_MPU_Sensor with null record;

   overriding function Is_6500_9250
     (Self : MPU6050_Sensor) return Boolean is (False);

   overriding function To_Temperature
     (Self : MPU6050_Sensor;
      Raw  : Interfaces.Integer_16) return Temperature;

end BBF.Drivers.MPU.MPU6050;
