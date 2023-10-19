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

--  Driver for PCA9685: 16-channel, 12-bit PWM Fm+ I2C-bus LED controller

with Interfaces;

with BBF.I2C.Master;
with BBF.PWM;

package BBF.Drivers.PCA9685 is

   pragma Preelaborate;

   type Channel_Identifier is range 0 .. 15;

   type Value_Type is mod 2**12;

   type PCA9685_Controller
     (Bus : not null access BBF.I2C.Master.I2C_Master_Controller'Class)
        is tagged limited private
          with Preelaborable_Initialization;

   procedure Initialize
     (Self    : in out PCA9685_Controller'Class;
      Success : in out Boolean);
   --  Do controller's probe, disable all channels, shutdown internal
   --  oscillator, reset output configuration to default, and disable
   --  listening of SUB* and ALLCALL addresses.
   --
   --  Before use of any channel, controller must be configured.

   procedure Configure
     (Self      : in out PCA9685_Controller'Class;
      Frequency : Interfaces.Unsigned_16;
      Success   : in out Boolean);
   --  Configure controller and enable internal oscillator.
   --
   --  @param Frequency
   --    Frequency of the PWM signal in Hz.

   procedure Set_Something
     (Self    : in out PCA9685_Controller'Class;
      Channel : Channel_Identifier;
      Value   : Value_Type);

   type PCA9685_Channel is limited new BBF.PWM.Channel with null record;

private

   type LSB_Count is mod 2 ** 8;
   type MSB_Count is mod 2 ** 4;

   type LED_ON_L_Register is record
      Count : LSB_Count := 0;
   end record
     with Pack,
          Size => 8;

   type LED_ON_H_Register is record
      Count      : MSB_Count := 0;
      On         : Boolean   := False;
      Reserved_1 : Boolean   := False;
      Reserved_2 : Boolean   := False;
      Reserved_3 : Boolean   := False;
   end record
     with Pack,
          Size => 8;

   type LED_OFF_L_Register is record
      Count : LSB_Count := 0;
   end record
     with Pack,
          Size => 8;

   type LED_OFF_H_Register is record
      Count      : MSB_Count := 0;
      Off        : Boolean   := False;
      Reserved_1 : Boolean   := False;
      Reserved_2 : Boolean   := False;
      Reserved_3 : Boolean   := False;
   end record
     with Pack,
          Size => 8;

   type LEDXX_Register is record
      LED_ON_L  : LED_ON_L_Register;
      LED_ON_H  : LED_ON_H_Register;
      LED_OFF_L : LED_OFF_L_Register;
      LED_OFF_H : LED_OFF_H_Register;
   end record
     with Pack;

   type LED_Register_Buffer is array (Channel_Identifier) of LEDXX_Register;

   type PCA9685_Controller
     (Bus : not null access BBF.I2C.Master.I2C_Master_Controller'Class)
        is tagged limited
   record
      Buffer      : LED_Register_Buffer := (others => <>);
      --  Buffer to prepare values to be send to controller's registers.

      Initialized : Boolean := False;
      --  Controller has been initialized.
   end record;

end BBF.Drivers.PCA9685;
