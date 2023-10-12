------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                        Hardware Abstraction Layer                        --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  General Purpose Input-Output (GPIO)

pragma Restrictions (No_Elaboration_Code);

with BBF.GPIO;
with BBF.HPL.PIO;
with BBF.HRI.PIO;

package BBF.BSL.GPIO is

   pragma Preelaborate;

   type SAM3_PIO_Driver;

   type SAM3_GPIO_Pin
     (Driver : not null access SAM3_PIO_Driver;
    --  (Controller : not null access BBF.HRI.PIO.PIO_Peripheral;
     Pin     : BBF.HPL.PIO.PIO_Pin) is
       limited new BBF.GPIO.Pin with record
      null;
   end record;

   overriding procedure Set_Direction
    (Self : SAM3_GPIO_Pin; To : BBF.GPIO.Direction);

   overriding procedure Set (Self : SAM3_GPIO_Pin; To : Boolean);

   overriding function Get (Self : SAM3_GPIO_Pin) return Boolean;

   procedure Set_Peripheral
    (Self : SAM3_GPIO_Pin'Class;
     To   : BBF.HPL.PIO.Peripheral_Function);
   --  Configure pin to be used by given periperal function instead of GPIO.

   type SAM3_PIO_Driver
     (Controller : not null access BBF.HRI.PIO.PIO_Peripheral)
   is limited record
      Pin_00 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 0);
      Pin_01 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 1);
      Pin_02 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 2);
      Pin_03 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 3);
      Pin_04 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 4);
      Pin_05 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 5);
      Pin_06 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 6);
      Pin_07 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 7);
      Pin_08 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 8);
      Pin_09 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 9);

      Pin_10 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 10);
      Pin_11 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 11);
      Pin_12 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 12);
      Pin_13 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 13);
      Pin_14 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 14);
      Pin_15 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 15);
      Pin_16 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 16);
      Pin_17 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 17);
      Pin_18 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 18);
      Pin_19 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 19);

      Pin_20 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 20);
      Pin_21 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 21);
      Pin_22 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 22);
      Pin_23 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 23);
      Pin_24 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 24);
      Pin_25 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 25);
      Pin_26 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 26);
      Pin_27 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 27);
      Pin_28 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 28);
      Pin_29 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 29);

      Pin_30 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 30);
      Pin_31 : aliased SAM3_GPIO_Pin (SAM3_PIO_Driver'Unchecked_Access, 31);
   end record;

end BBF.BSL.GPIO;
