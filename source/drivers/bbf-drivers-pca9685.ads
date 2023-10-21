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

--  Implementation of controller and channel drivers of PCA9685: 16-channel,
--  12-bit PWM Fm+ I2C-bus LED controller.

with Interfaces;

with BBF.I2C.Master;
with BBF.PCA9685;

package BBF.Drivers.PCA9685 is

   pragma Preelaborate;

   type Channel_Identifier is range 0 .. 15;

   package Registers is

      type LSB_Count is mod 2 ** 8;
      type MSB_Count is mod 2 ** 4;

      type LED_ON_L_Register is record
         Count : LSB_Count := 0;
      end record
        with Pack, Preelaborable_Initialization,
        Size => 8;

      type LED_ON_H_Register is record
         Count      : MSB_Count := 0;
         On         : Boolean   := False;
         Reserved_1 : Boolean   := False;
         Reserved_2 : Boolean   := False;
         Reserved_3 : Boolean   := False;
      end record
        with Pack, Preelaborable_Initialization,
        Size => 8;

      type LED_OFF_L_Register is record
         Count : LSB_Count := 0;
      end record
        with Pack, Preelaborable_Initialization,
        Size => 8;

      type LED_OFF_H_Register is record
         Count      : MSB_Count := 0;
         Off        : Boolean   := False;
         Reserved_1 : Boolean   := False;
         Reserved_2 : Boolean   := False;
         Reserved_3 : Boolean   := False;
      end record
        with Pack, Preelaborable_Initialization,
        Size => 8;

      type LEDXX_Register is record
         LED_ON_L  : LED_ON_L_Register  := (others => <>);
         LED_ON_H  : LED_ON_H_Register  := (others => <>);
         LED_OFF_L : LED_OFF_L_Register := (others => <>);
         LED_OFF_H : LED_OFF_H_Register := (others => <>);
      end record
        with Pack, Preelaborable_Initialization;

      type LED_Register_Buffer is array (Channel_Identifier) of LEDXX_Register
        with Preelaborable_Initialization;

   end Registers;

   type PCA9685_Controller_Driver is tagged;

   type PCA9685_Channel_Driver
     (Controller : not null access PCA9685_Controller_Driver'Class;
      Channel    : Channel_Identifier) is
         limited new BBF.PCA9685.PCA9685_Channel with null record;

   overriding procedure Set
     (Self  : in out PCA9685_Channel_Driver;
      On    : BBF.PCA9685.Value_Type;
      Off   : BBF.PCA9685.Value_Type);

   overriding procedure On (Self : in out PCA9685_Channel_Driver);

   overriding procedure Off (Self : in out PCA9685_Channel_Driver);

   type PCA9685_Controller_Driver
     (Bus    : not null access BBF.I2C.Master.I2C_Master_Controller'Class;
      Device : BBF.I2C.Device_Address)
        is limited new BBF.PCA9685.PCA9685_Controller with
   record
      Buffer      : Registers.LED_Register_Buffer;
      --  Buffer to prepare values to be send to controller's registers.

      Initialized : Boolean := False;
      --  Controller has been initialized.

      Channel_00  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 0);
      Channel_01  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 1);
      Channel_02  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 2);
      Channel_03  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 3);
      Channel_04  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 4);
      Channel_05  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 5);
      Channel_06  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 6);
      Channel_07  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 7);
      Channel_08  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 8);
      Channel_09  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 9);
      Channel_10  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 10);
      Channel_11  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 11);
      Channel_12  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 12);
      Channel_13  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 13);
      Channel_14  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 14);
      Channel_15  : aliased
        PCA9685_Channel_Driver (PCA9685_Controller_Driver'Unchecked_Access, 15);
   end record
     with Preelaborable_Initialization;

   procedure Initialize
     (Self    : in out PCA9685_Controller_Driver'Class;
      Success : in out Boolean);
   --  Do controller's probe, disable all channels, shutdown internal
   --  oscillator, reset output configuration to default, and disable
   --  listening of SUB* and ALLCALL addresses.
   --
   --  Before use of any channel, controller must be configured.

   procedure Configure
     (Self      : in out PCA9685_Controller_Driver'Class;
      Frequency : Interfaces.Unsigned_16;
      Success   : in out Boolean);
   --  Configure controller and enable internal oscillator.
   --
   --  @param Frequency
   --    Frequency of the PWM signal in Hz.

   overriding procedure On (Self : in out PCA9685_Controller_Driver);

   overriding procedure Off (Self : in out PCA9685_Controller_Driver);

end BBF.Drivers.PCA9685;
