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

--  API of PCA9685 Driver: 16-channel, 12-bit PWM Fm+ I2C-bus LED controller

with BBF.PWM;

package BBF.PCA9685 is

   pragma Pure;

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

   type PCA9685_Controller is limited interface;

   not overriding procedure On (Self : in out PCA9685_Controller) is abstract;
   --  Turn signals of all channels to ON state. No PWM generation.

   not overriding procedure Off (Self : in out PCA9685_Controller) is abstract;
   --  Turn signals of all channels to OFF state. No PWM generation.

end BBF.PCA9685;
