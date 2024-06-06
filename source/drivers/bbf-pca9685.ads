------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023-2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  API of PCA9685 Driver: 16-channel, 12-bit PWM Fm+ I2C-bus LED controller

with BBF.PWM;

package BBF.PCA9685 is

   pragma Pure;

   type Tick_Duration_Type is
     delta 0.000_000_001 digits 10 range 0.0 .. 1.0;

   type Value_Type is mod 2**12;

   type PCA9685_Channel is limited interface and BBF.PWM.Channel;

   not overriding procedure Set
     (Self : in out PCA9685_Channel;
      On   : Value_Type;
      Off  : Value_Type) is abstract;
   --  Sets On and Off ticks

   not overriding procedure On (Self : in out PCA9685_Channel) is abstract;
   --  Turn signal to ON state. No PWM generation.

   not overriding procedure Off (Self : in out PCA9685_Channel) is abstract;
   --  Turn signal to OFF state. No PWM generation.

   not overriding function Tick_Duration
     (Self : PCA9685_Channel) return Tick_Duration_Type is abstract;
   --  Duration of the tick of the PWM. Single PWN cycle has 4_096 ticks.

   type PCA9685_Controller is limited interface;

   not overriding procedure On (Self : in out PCA9685_Controller) is abstract;
   --  Turn signals of all channels to ON state. No PWM generation.

   not overriding procedure Off (Self : in out PCA9685_Controller) is abstract;
   --  Turn signals of all channels to OFF state. No PWM generation.

   not overriding procedure Start_Transaction
     (Self : in out PCA9685_Controller) is abstract;
   --  Start transactional change of the group of the channels.

   not overriding procedure Commit_Transaction
     (Self : in out PCA9685_Controller) is abstract;
   --  Commit transactional change of the group of the channels.

   not overriding function Tick_Duration
     (Self : PCA9685_Controller) return Tick_Duration_Type is abstract;
   --  Duration of the tick of the PWM. Single PWN cycle has 4_096 ticks.

end BBF.PCA9685;
