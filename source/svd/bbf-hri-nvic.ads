pragma Style_Checks (Off);

--  This spec has been automatically generated from ATSAM3X8E.svd

pragma Restrictions (No_Elaboration_Code);

with System;

package BBF.HRI.NVIC is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   --  IPR_IPR_N array element
   subtype IPR_IPR_N_Element is BBF.HRI.Byte;

   --  IPR_IPR_N array
   type IPR_IPR_N_Field_Array is array (0 .. 3) of IPR_IPR_N_Element
     with Component_Size => 8, Size => 32;

   --  Interrupt Priority Register
   type IPR_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  IPR_N as a value
            Val : BBF.HRI.UInt32;
         when True =>
            --  IPR_N as an array
            Arr : IPR_IPR_N_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for IPR_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   subtype STIR_INTID_Field is BBF.HRI.UInt9;

   --  Software Triggered Interrupt Register
   type STIR_Register is record
      --  Write-only. interrupt to be triggered
      INTID         : STIR_INTID_Field := 16#0#;
      --  unspecified
      Reserved_9_31 : BBF.HRI.UInt23 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for STIR_Register use record
      INTID         at 0 range 0 .. 8;
      Reserved_9_31 at 0 range 9 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Nested Vectored Interrupt Controller
   type NVIC_Peripheral is record
      --  Interrupt Set-Enable Register
      ISER0 : aliased BBF.HRI.UInt32;
      --  Interrupt Set-Enable Register
      ISER1 : aliased BBF.HRI.UInt32;
      --  Interrupt Clear-Enable Register
      ICER0 : aliased BBF.HRI.UInt32;
      --  Interrupt Clear-Enable Register
      ICER1 : aliased BBF.HRI.UInt32;
      --  Interrupt Set-Pending Register
      ISPR0 : aliased BBF.HRI.UInt32;
      --  Interrupt Set-Pending Register
      ISPR1 : aliased BBF.HRI.UInt32;
      --  Interrupt Clear-Pending Register
      ICPR0 : aliased BBF.HRI.UInt32;
      --  Interrupt Clear-Pending Register
      ICPR1 : aliased BBF.HRI.UInt32;
      --  Interrupt Active Bit Register
      IABR0 : aliased BBF.HRI.UInt32;
      --  Interrupt Active Bit Register
      IABR1 : aliased BBF.HRI.UInt32;
      --  Interrupt Priority Register
      IPR0  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR1  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR2  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR3  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR4  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR5  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR6  : aliased IPR_Register;
      --  Interrupt Priority Register
      IPR7  : aliased IPR_Register;
      --  Software Triggered Interrupt Register
      STIR  : aliased STIR_Register;
   end record
     with Volatile;

   for NVIC_Peripheral use record
      ISER0 at 16#100# range 0 .. 31;
      ISER1 at 16#104# range 0 .. 31;
      ICER0 at 16#180# range 0 .. 31;
      ICER1 at 16#184# range 0 .. 31;
      ISPR0 at 16#200# range 0 .. 31;
      ISPR1 at 16#204# range 0 .. 31;
      ICPR0 at 16#280# range 0 .. 31;
      ICPR1 at 16#284# range 0 .. 31;
      IABR0 at 16#300# range 0 .. 31;
      IABR1 at 16#304# range 0 .. 31;
      IPR0  at 16#400# range 0 .. 31;
      IPR1  at 16#404# range 0 .. 31;
      IPR2  at 16#408# range 0 .. 31;
      IPR3  at 16#40C# range 0 .. 31;
      IPR4  at 16#410# range 0 .. 31;
      IPR5  at 16#414# range 0 .. 31;
      IPR6  at 16#418# range 0 .. 31;
      IPR7  at 16#41C# range 0 .. 31;
      STIR  at 16#F00# range 0 .. 31;
   end record;

   --  Nested Vectored Interrupt Controller
   NVIC_Periph : aliased NVIC_Peripheral
     with Import, Address => NVIC_Base;

end BBF.HRI.NVIC;
