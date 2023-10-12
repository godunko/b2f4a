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

--  Parallel Input/Output Controller (PIO) API

pragma Restrictions (No_Elaboration_Code);

with BBF.HRI.PIO;

package BBF.HPL.PIO is

   pragma Preelaborate;

   type PIO is access all BBF.HRI.PIO.PIO_Peripheral;

   type PIO_Pin is range 0 .. 31;

   type PIO_Pin_Array is array (PIO_Pin) of Boolean
     with Component_Size => 1, Size => 32;

   type Peripheral_Function is (A, B);

   type Status is private;
   --  Interrupt status

   function PIOA return PIO;
   function PIOB return PIO;
   function PIOC return PIO;
   function PIOD return PIO;

   procedure Set_Output
     (Base       : PIO;
      Mask       : PIO_Pin_Array;
      Default    : Boolean := True;
      Multidrive : Boolean := False);
      --  XXX: Pull_Up
   --  Configure one or more pin(s) of a PIO controller as outputs, with the
   --  given default value. Optionally, the multi-drive feature can be enabled
   --  on the pin(s).

   procedure Set_Peripheral
     (Base : PIO;
      Mask : PIO_Pin_Array;
      To   : Peripheral_Function);
   --  Configure IO of a PIO controller as being controlled by a specific
   --  peripheral.

   procedure Set_Edge (Base : PIO; Mask : PIO_Pin_Array) with Inline;
   --  Configure given pins to report interrupts on signal edge.

   procedure Set_Level (Base : PIO; Mask : PIO_Pin_Array) with Inline;
   --  Configure given pins to report interrupts on signal level.

   procedure Set_Falling_Low (Base : PIO; Mask : PIO_Pin_Array) with Inline;
   --  Configure given pins to report interrupts on falling edge/low level.

   procedure Set_Rising_High (Base : PIO; Mask : PIO_Pin_Array) with Inline;
   --  Configure given pins to report interrupts on rising edge/high level.

   procedure Enable_Interrupt (Base : PIO; Mask : PIO_Pin_Array) with Inline;
   --  Enable interrupt generation by given pins.

   procedure Disable_Interrupt (Base : PIO; Mask : PIO_Pin_Array) with Inline;
   --  Enable interrupt generation by given pins.

   procedure Set (Base : PIO; Mask : PIO_Pin_Array);
   --  Set a high output level on all the PIOs defined in Mask. This has no
   --  immediate effects on PIOs that are not output, but the PIO controller
   --  will save the value if they are changed to outputs.

   function Get (Base : PIO) return PIO_Pin_Array;

   procedure Clear (Base : PIO; Mask : PIO_Pin_Array);
   --  Set a low output level on all the PIOs defined in Mask. This has no
   --  immediate effects on PIOs that are not output, but the PIO controller
   --  will save the value if they are changed to outputs.

   function Get_And_Clear_Status (Base : PIO) return Status with Inline;
   --  Returns interrupt status. Note, interrupt handler should read status
   --  once and process all reported events.

   function Is_Detected (Self : Status; Pin : PIO_Pin) return Boolean
     with Inline;
   --  Returns True when signal change on the given pin has been detected.

private

   type Status is new PIO_Pin_Array;

   function Is_Detected (Self : Status; Pin : PIO_Pin) return Boolean is
     (Self (Pin));

end BBF.HPL.PIO;
