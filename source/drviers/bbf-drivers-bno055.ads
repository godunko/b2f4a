------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                        Runtime Library Component                         --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2019, Vadim Godunko <vgodunko@gmail.com>                     --
-- All rights reserved.                                                     --
--                                                                          --
-- Redistribution and use in source and binary forms, with or without       --
-- modification, are permitted provided that the following conditions       --
-- are met:                                                                 --
--                                                                          --
--  * Redistributions of source code must retain the above copyright        --
--    notice, this list of conditions and the following disclaimer.         --
--                                                                          --
--  * Redistributions in binary form must reproduce the above copyright     --
--    notice, this list of conditions and the following disclaimer in the   --
--    documentation and/or other materials provided with the distribution.  --
--                                                                          --
--  * Neither the name of the Vadim Godunko, IE nor the names of its        --
--    contributors may be used to endorse or promote products derived from  --
--    this software without specific prior written permission.              --
--                                                                          --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT     --
-- HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   --
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED --
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   --
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     --
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       --
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             --
--                                                                          --
------------------------------------------------------------------------------
--  Driver for BNO055: Intelligent 9-axis absolute orientation sensor

with BBF.Clocks;
with BBF.I2C.Master;
with BBF.Motion;

package BBF.Drivers.BNO055 is

   pragma Preelaborate;

   type Operation_Mode is
    (Configuration,
     Accelerometer_Only,
     Magnetometer_Only,
     Gyroscope_Only,
     Accelerometer_Magnetometer,
     Accelerometer_Gyroscope,
     Magnetometer_Gyroscope,
     Accelerometer_Magnetometer_Gyroscope,
     Inertial_Measurement_Unit,
     Compass,
     Magnetometer_For_Gyroscope,
     NDOF_FMC_Off,
     NDOF)
       with Size => 4;
   for Operation_Mode use
    (Configuration                        => 2#0000#,
     Accelerometer_Only                   => 2#0001#,
     Magnetometer_Only                    => 2#0010#,
     Gyroscope_Only                       => 2#0011#,
     Accelerometer_Magnetometer           => 2#0100#,
     Accelerometer_Gyroscope              => 2#0101#,
     Magnetometer_Gyroscope               => 2#0110#,
     Accelerometer_Magnetometer_Gyroscope => 2#0111#,
     Inertial_Measurement_Unit            => 2#1000#,
     Compass                              => 2#1001#,
     Magnetometer_For_Gyroscope           => 2#1010#,
     NDOF_FMC_Off                         => 2#1011#,
     NDOF                                 => 2#1100#);

   type BNO055_Sensor
    (Controller          :
       not null access BBF.I2C.Master.I2C_Master_Controller'Class;
     Clock               :
       not null access BBF.Clocks.Real_Time_Clock_Controller'Class;
     Alternative_Address : Boolean)
       is limited new BBF.Motion.Motion_Sensor with null record;

   procedure Initialize
    (Self : in out BNO055_Sensor'Class;
     Mode : Operation_Mode);
   --  Initialize sensor and configure it.

--   overriding procedure Get_Angular_Velocity
--    (Self      : in out BNO055_Sensor;
--     X         : out Angular_Velocity;
--     Y         : out Angular_Velocity;
--     Z         : out Angular_Velocity;
--     Timestamp : out BBF.Clocks.Time);

   overriding procedure Get_Gravity_Vector
    (Self      : in out BNO055_Sensor;
     X         : out BBF.Motion.Linear_Acceleration;
     Y         : out BBF.Motion.Linear_Acceleration;
     Z         : out BBF.Motion.Linear_Acceleration;
     Timestamp : out BBF.Clocks.Time);

end BBF.Drivers.BNO055;
