------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                        Hardware Abstraction Layer                        --
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
--  Abstract interface for absolute orientation/motion sensors, including
--  accelerometers, gyroscopes, magnetometers with and without built-in
--  fusion algorithms.

pragma Restrictions (No_Elaboration_Code);

with BBF.Clocks;

package BBF.Motion is

   pragma Preelaborate;

   type Linear_Acceleration is new Float;
   --  Linear acceleration, m/s2.

   type Angular_Velocity is new Float;
   --  Angular velocity, radians/s.

   type Motion_Sensor is limited interface;

--   not overriding procedure Get_Acceleration
--    (Self      : in out Motion_Sensor;
--     X         : out Linear_Acceleration;
--     Y         : out Linear_Acceleration;
--     Z         : out Linear_Acceleration;
--     Timestamp : out BBF.Clocks.Time) is abstract;

--   not overriding procedure Get_Magnetic_Field_Strength
--    (Self      : in out Motion_Sensor;
--     X         : out Linear_Acceleration;
--     Y         : out Linear_Acceleration;
--     Z         : out Linear_Acceleration;
--     Timestamp : out BBF.Clocks.Time) is abstract;

--   not overriding procedure Get_Angular_Velocity
--    (Self      : in out Motion_Sensor;
--     X         : out Angular_Velocity;
--     Y         : out Angular_Velocity;
--     Z         : out Angular_Velocity;
--     Timestamp : out BBF.Clocks.Time) is abstract;

--   not overriding procedure Get_Linear_Acceleration
--    (Self      : in out Motion_Sensor;
--     X         : out Linear_Acceleration;
--     Y         : out Linear_Acceleration;
--     Z         : out Linear_Acceleration;
--     Timestamp : out BBF.Clocks.Time) is abstract;

--   not overriding procedure Get_Euler_Angles
--    (Self      : in out Motion_Sensor;
--     Heading   : out Float_32;
--     Roll      : out Float_32;
--     Pitch     : out Float_32;
--     Timestamp : out BBF.Clocks.Time) is abstract;

--   not overriding procedure Get_Quaternion
--    (Self      : in out Motion_Sensor;
--     W         : out Float_32;
--     X         : out Float_32;
--     Y         : out Float_32;
--     Z         : out Float_32;
--     Timestamp : out BBF.Clocks.Time) is abstract;

   not overriding procedure Get_Gravity_Vector
    (Self      : in out Motion_Sensor;
     X         : out Linear_Acceleration;
     Y         : out Linear_Acceleration;
     Z         : out Linear_Acceleration;
     Timestamp : out BBF.Clocks.Time) is abstract;

end BBF.Motion;
