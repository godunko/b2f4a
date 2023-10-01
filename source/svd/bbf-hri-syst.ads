pragma Style_Checks (Off);

--  This spec has been automatically generated from ATSAM3X8E.svd

pragma Restrictions (No_Elaboration_Code);

with System;

--  System timer, SysTick
package BBF.HRI.SYST is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   --  no description available
   type CTRL_CLKSOURCE_Field is
     (--  MCK/8
      MCK_8,
      --  MCK
      MCK)
     with Size => 1;
   for CTRL_CLKSOURCE_Field use
     (MCK_8 => 0,
      MCK => 1);

   --  SYST_CTRL_RESERVED array
   type SYST_CTRL_RESERVED_Field_Array is array (1 .. 13) of Boolean
     with Component_Size => 1, Size => 13;

   --  Type definition for SYST_CTRL_RESERVED
   type SYST_CTRL_RESERVED_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  RESERVED as a value
            Val : BBF.HRI.UInt13;
         when True =>
            --  RESERVED as an array
            Arr : SYST_CTRL_RESERVED_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 13;

   for SYST_CTRL_RESERVED_Field use record
      Val at 0 range 0 .. 12;
      Arr at 0 range 0 .. 12;
   end record;

   --  SYST_CTRL_RESERVED array
   type SYST_CTRL_RESERVED_Field_Array_1 is array (1 .. 15) of Boolean
     with Component_Size => 1, Size => 15;

   --  Type definition for SYST_CTRL_RESERVED
   type SYST_CTRL_RESERVED_Field_1
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  RESERVED as a value
            Val : BBF.HRI.UInt15;
         when True =>
            --  RESERVED as an array
            Arr : SYST_CTRL_RESERVED_Field_Array_1;
      end case;
   end record
     with Unchecked_Union, Size => 15;

   for SYST_CTRL_RESERVED_Field_1 use record
      Val at 0 range 0 .. 14;
      Arr at 0 range 0 .. 14;
   end record;

   --  SysTick Control and Status Register
   type SYST_CTRL_Register is record
      --  no description available
      ENABLE     : Boolean := False;
      --  no description available
      TICKINT    : Boolean := False;
      --  no description available
      CLKSOURCE  : CTRL_CLKSOURCE_Field := BBF.HRI.SYST.MCK;
      --  Read-only. no description available
      RESERVED   : SYST_CTRL_RESERVED_Field :=
                    (As_Array => False, Val => 16#0#);
      --  no description available
      COUNTFLAG  : Boolean := False;
      --  Read-only. no description available
      RESERVED_1 : SYST_CTRL_RESERVED_Field_1 :=
                    (As_Array => False, Val => 16#0#);
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for SYST_CTRL_Register use record
      ENABLE     at 0 range 0 .. 0;
      TICKINT    at 0 range 1 .. 1;
      CLKSOURCE  at 0 range 2 .. 2;
      RESERVED   at 0 range 3 .. 15;
      COUNTFLAG  at 0 range 16 .. 16;
      RESERVED_1 at 0 range 17 .. 31;
   end record;

   subtype SYST_LOAD_RELOAD_Field is BBF.HRI.UInt24;

   --  SYST_LOAD_RESERVED array
   type SYST_LOAD_RESERVED_Field_Array is array (1 .. 8) of Boolean
     with Component_Size => 1, Size => 8;

   --  Type definition for SYST_LOAD_RESERVED
   type SYST_LOAD_RESERVED_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  RESERVED as a value
            Val : BBF.HRI.Byte;
         when True =>
            --  RESERVED as an array
            Arr : SYST_LOAD_RESERVED_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 8;

   for SYST_LOAD_RESERVED_Field use record
      Val at 0 range 0 .. 7;
      Arr at 0 range 0 .. 7;
   end record;

   --  SysTick Reload Value Register
   type SYST_LOAD_Register is record
      --  Value to load into the SysTick Current Value Register when the
      --  counter reaches 0
      RELOAD   : SYST_LOAD_RELOAD_Field := 16#0#;
      --  Read-only. no description available
      RESERVED : SYST_LOAD_RESERVED_Field :=
                  (As_Array => False, Val => 16#0#);
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for SYST_LOAD_Register use record
      RELOAD   at 0 range 0 .. 23;
      RESERVED at 0 range 24 .. 31;
   end record;

   subtype SYST_VAL_CURRENT_Field is BBF.HRI.UInt24;

   --  SYST_VAL_RESERVED array
   type SYST_VAL_RESERVED_Field_Array is array (1 .. 8) of Boolean
     with Component_Size => 1, Size => 8;

   --  Type definition for SYST_VAL_RESERVED
   type SYST_VAL_RESERVED_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  RESERVED as a value
            Val : BBF.HRI.Byte;
         when True =>
            --  RESERVED as an array
            Arr : SYST_VAL_RESERVED_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 8;

   for SYST_VAL_RESERVED_Field use record
      Val at 0 range 0 .. 7;
      Arr at 0 range 0 .. 7;
   end record;

   --  SysTick Current Value Register
   type SYST_VAL_Register is record
      --  Current value at the time the register is accessed
      CURRENT  : SYST_VAL_CURRENT_Field := 16#0#;
      --  Read-only. no description available
      RESERVED : SYST_VAL_RESERVED_Field := (As_Array => False, Val => 16#0#);
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for SYST_VAL_Register use record
      CURRENT  at 0 range 0 .. 23;
      RESERVED at 0 range 24 .. 31;
   end record;

   subtype SYST_CALIB_TENMS_Field is BBF.HRI.UInt24;

   --  SYST_CALIB_RESERVED array
   type SYST_CALIB_RESERVED_Field_Array is array (1 .. 6) of Boolean
     with Component_Size => 1, Size => 6;

   --  Type definition for SYST_CALIB_RESERVED
   type SYST_CALIB_RESERVED_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  RESERVED as a value
            Val : BBF.HRI.UInt6;
         when True =>
            --  RESERVED as an array
            Arr : SYST_CALIB_RESERVED_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 6;

   for SYST_CALIB_RESERVED_Field use record
      Val at 0 range 0 .. 5;
      Arr at 0 range 0 .. 5;
   end record;

   --  no description available
   type CALIB_SKEW_Field is
     (--  10ms calibration value is exact
      Val_0,
      --  10ms calibration value is inexact, because of the clock frequency
      Val_1)
     with Size => 1;
   for CALIB_SKEW_Field use
     (Val_0 => 0,
      Val_1 => 1);

   --  no description available
   type CALIB_NOREF_Field is
     (--  The reference clock is provided
      Val_0,
      --  The reference clock is not provided
      Val_1)
     with Size => 1;
   for CALIB_NOREF_Field use
     (Val_0 => 0,
      Val_1 => 1);

   --  SysTick Calibration Value Register
   type SYST_CALIB_Register is record
      --  Read-only. Reload value to use for 10ms timing
      TENMS    : SYST_CALIB_TENMS_Field;
      --  Read-only. no description available
      RESERVED : SYST_CALIB_RESERVED_Field;
      --  Read-only. no description available
      SKEW     : CALIB_SKEW_Field;
      --  Read-only. no description available
      NOREF    : CALIB_NOREF_Field;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for SYST_CALIB_Register use record
      TENMS    at 0 range 0 .. 23;
      RESERVED at 0 range 24 .. 29;
      SKEW     at 0 range 30 .. 30;
      NOREF    at 0 range 31 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  System timer, SysTick
   type SYST_Peripheral is record
      --  SysTick Control and Status Register
      CTRL  : aliased SYST_CTRL_Register;
      --  SysTick Reload Value Register
      LOAD  : aliased SYST_LOAD_Register;
      --  SysTick Current Value Register
      VAL   : aliased SYST_VAL_Register;
      --  SysTick Calibration Value Register
      CALIB : aliased SYST_CALIB_Register;
   end record
     with Volatile;

   for SYST_Peripheral use record
      CTRL  at 16#0# range 0 .. 31;
      LOAD  at 16#4# range 0 .. 31;
      VAL   at 16#8# range 0 .. 31;
      CALIB at 16#C# range 0 .. 31;
   end record;

   --  System timer, SysTick
   SYST_Periph : aliased SYST_Peripheral
     with Import, Address => SYST_Base;

end BBF.HRI.SYST;
