--  This spec has been automatically generated from SAM3X8E.svd

pragma Restrictions (No_Elaboration_Code);
pragma Ada_2012;
pragma Style_Checks (Off);

with System;

--  Power Management Controller
package BBF.HRI.PMC is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   --  PMC_SCER_PCK array
   type PMC_SCER_PCK_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_SCER_PCK
   type PMC_SCER_PCK_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCK as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCK as an array
            Arr : PMC_SCER_PCK_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_SCER_PCK_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  System Clock Enable Register
   type PMC_SCER_Register is record
      --  unspecified
      Reserved_0_4   : BBF.HRI.UInt5 := 16#0#;
      --  Write-only. Enable USB OTG Clock (48 MHz, USB_48M) for UTMI
      UOTGCLK        : Boolean := False;
      --  unspecified
      Reserved_6_7   : BBF.HRI.UInt2 := 16#0#;
      --  Write-only. Programmable Clock 0 Output Enable
      PCK            : PMC_SCER_PCK_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_11_31 : BBF.HRI.UInt21 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_SCER_Register use record
      Reserved_0_4   at 0 range 0 .. 4;
      UOTGCLK        at 0 range 5 .. 5;
      Reserved_6_7   at 0 range 6 .. 7;
      PCK            at 0 range 8 .. 10;
      Reserved_11_31 at 0 range 11 .. 31;
   end record;

   --  PMC_SCDR_PCK array
   type PMC_SCDR_PCK_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_SCDR_PCK
   type PMC_SCDR_PCK_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCK as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCK as an array
            Arr : PMC_SCDR_PCK_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_SCDR_PCK_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  System Clock Disable Register
   type PMC_SCDR_Register is record
      --  unspecified
      Reserved_0_4   : BBF.HRI.UInt5 := 16#0#;
      --  Write-only. Disable USB OTG Clock (48 MHz, USB_48M) for UTMI
      UOTGCLK        : Boolean := False;
      --  unspecified
      Reserved_6_7   : BBF.HRI.UInt2 := 16#0#;
      --  Write-only. Programmable Clock 0 Output Disable
      PCK            : PMC_SCDR_PCK_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_11_31 : BBF.HRI.UInt21 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_SCDR_Register use record
      Reserved_0_4   at 0 range 0 .. 4;
      UOTGCLK        at 0 range 5 .. 5;
      Reserved_6_7   at 0 range 6 .. 7;
      PCK            at 0 range 8 .. 10;
      Reserved_11_31 at 0 range 11 .. 31;
   end record;

   --  PMC_SCSR_PCK array
   type PMC_SCSR_PCK_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_SCSR_PCK
   type PMC_SCSR_PCK_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCK as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCK as an array
            Arr : PMC_SCSR_PCK_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_SCSR_PCK_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  System Clock Status Register
   type PMC_SCSR_Register is record
      --  unspecified
      Reserved_0_4   : BBF.HRI.UInt5;
      --  Read-only. USB OTG Clock (48 MHz, USB_48M) Clock Status
      UOTGCLK        : Boolean;
      --  unspecified
      Reserved_6_7   : BBF.HRI.UInt2;
      --  Read-only. Programmable Clock 0 Output Status
      PCK            : PMC_SCSR_PCK_Field;
      --  unspecified
      Reserved_11_31 : BBF.HRI.UInt21;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_SCSR_Register use record
      Reserved_0_4   at 0 range 0 .. 4;
      UOTGCLK        at 0 range 5 .. 5;
      Reserved_6_7   at 0 range 6 .. 7;
      PCK            at 0 range 8 .. 10;
      Reserved_11_31 at 0 range 11 .. 31;
   end record;

   --  PMC_PCER0_PID array
   type PMC_PCER0_PID_Field_Array is array (2 .. 31) of Boolean
     with Component_Size => 1, Size => 30;

   --  Type definition for PMC_PCER0_PID
   type PMC_PCER0_PID_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PID as a value
            Val : BBF.HRI.UInt30;
         when True =>
            --  PID as an array
            Arr : PMC_PCER0_PID_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 30;

   for PMC_PCER0_PID_Field use record
      Val at 0 range 0 .. 29;
      Arr at 0 range 0 .. 29;
   end record;

   --  Peripheral Clock Enable Register 0
   type PMC_PCER0_Register is record
      --  unspecified
      Reserved_0_1 : BBF.HRI.UInt2 := 16#0#;
      --  Write-only. Peripheral Clock 2 Enable
      PID          : PMC_PCER0_PID_Field := (As_Array => False, Val => 16#0#);
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCER0_Register use record
      Reserved_0_1 at 0 range 0 .. 1;
      PID          at 0 range 2 .. 31;
   end record;

   --  PMC_PCDR0_PID array
   type PMC_PCDR0_PID_Field_Array is array (2 .. 31) of Boolean
     with Component_Size => 1, Size => 30;

   --  Type definition for PMC_PCDR0_PID
   type PMC_PCDR0_PID_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PID as a value
            Val : BBF.HRI.UInt30;
         when True =>
            --  PID as an array
            Arr : PMC_PCDR0_PID_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 30;

   for PMC_PCDR0_PID_Field use record
      Val at 0 range 0 .. 29;
      Arr at 0 range 0 .. 29;
   end record;

   --  Peripheral Clock Disable Register 0
   type PMC_PCDR0_Register is record
      --  unspecified
      Reserved_0_1 : BBF.HRI.UInt2 := 16#0#;
      --  Write-only. Peripheral Clock 2 Disable
      PID          : PMC_PCDR0_PID_Field := (As_Array => False, Val => 16#0#);
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCDR0_Register use record
      Reserved_0_1 at 0 range 0 .. 1;
      PID          at 0 range 2 .. 31;
   end record;

   --  PMC_PCSR0_PID array
   type PMC_PCSR0_PID_Field_Array is array (2 .. 31) of Boolean
     with Component_Size => 1, Size => 30;

   --  Type definition for PMC_PCSR0_PID
   type PMC_PCSR0_PID_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PID as a value
            Val : BBF.HRI.UInt30;
         when True =>
            --  PID as an array
            Arr : PMC_PCSR0_PID_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 30;

   for PMC_PCSR0_PID_Field use record
      Val at 0 range 0 .. 29;
      Arr at 0 range 0 .. 29;
   end record;

   --  Peripheral Clock Status Register 0
   type PMC_PCSR0_Register is record
      --  unspecified
      Reserved_0_1 : BBF.HRI.UInt2;
      --  Read-only. Peripheral Clock 2 Status
      PID          : PMC_PCSR0_PID_Field;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCSR0_Register use record
      Reserved_0_1 at 0 range 0 .. 1;
      PID          at 0 range 2 .. 31;
   end record;

   subtype CKGR_UCKR_UPLLCOUNT_Field is BBF.HRI.UInt4;

   --  UTMI Clock Register
   type CKGR_UCKR_Register is record
      --  unspecified
      Reserved_0_15  : BBF.HRI.UInt16 := 16#800#;
      --  UTMI PLL Enable
      UPLLEN         : Boolean := False;
      --  unspecified
      Reserved_17_19 : BBF.HRI.UInt3 := 16#0#;
      --  UTMI PLL Start-up Time
      UPLLCOUNT      : CKGR_UCKR_UPLLCOUNT_Field := 16#2#;
      --  unspecified
      Reserved_24_31 : BBF.HRI.Byte := 16#10#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CKGR_UCKR_Register use record
      Reserved_0_15  at 0 range 0 .. 15;
      UPLLEN         at 0 range 16 .. 16;
      Reserved_17_19 at 0 range 17 .. 19;
      UPLLCOUNT      at 0 range 20 .. 23;
      Reserved_24_31 at 0 range 24 .. 31;
   end record;

   --  Main On-Chip RC Oscillator Frequency Selection
   type CKGR_MOR_MOSCRCF_Field is
     (--  The Fast RC Oscillator Frequency is at 4 MHz (default)
      Val_4_Mhz,
      --  The Fast RC Oscillator Frequency is at 8 MHz
      Val_8_Mhz,
      --  The Fast RC Oscillator Frequency is at 12 MHz
      Val_12_Mhz)
     with Size => 3;
   for CKGR_MOR_MOSCRCF_Field use
     (Val_4_Mhz => 0,
      Val_8_Mhz => 1,
      Val_12_Mhz => 2);

   subtype CKGR_MOR_MOSCXTST_Field is BBF.HRI.Byte;
   subtype CKGR_MOR_KEY_Field is BBF.HRI.Byte;

   --  Main Oscillator Register
   type CKGR_MOR_Register is record
      --  Main Crystal Oscillator Enable
      MOSCXTEN       : Boolean := True;
      --  Main Crystal Oscillator Bypass
      MOSCXTBY       : Boolean := False;
      --  unspecified
      Reserved_2_2   : BBF.HRI.Bit := 16#0#;
      --  Main On-Chip RC Oscillator Enable
      MOSCRCEN       : Boolean := False;
      --  Main On-Chip RC Oscillator Frequency Selection
      MOSCRCF        : CKGR_MOR_MOSCRCF_Field := BBF.HRI.PMC.Val_4_Mhz;
      --  unspecified
      Reserved_7_7   : BBF.HRI.Bit := 16#0#;
      --  Main Crystal Oscillator Start-up Time
      MOSCXTST       : CKGR_MOR_MOSCXTST_Field := 16#0#;
      --  Password
      KEY            : CKGR_MOR_KEY_Field := 16#0#;
      --  Main Oscillator Selection
      MOSCSEL        : Boolean := False;
      --  Clock Failure Detector Enable
      CFDEN          : Boolean := False;
      --  unspecified
      Reserved_26_31 : BBF.HRI.UInt6 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CKGR_MOR_Register use record
      MOSCXTEN       at 0 range 0 .. 0;
      MOSCXTBY       at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      MOSCRCEN       at 0 range 3 .. 3;
      MOSCRCF        at 0 range 4 .. 6;
      Reserved_7_7   at 0 range 7 .. 7;
      MOSCXTST       at 0 range 8 .. 15;
      KEY            at 0 range 16 .. 23;
      MOSCSEL        at 0 range 24 .. 24;
      CFDEN          at 0 range 25 .. 25;
      Reserved_26_31 at 0 range 26 .. 31;
   end record;

   subtype CKGR_MCFR_MAINF_Field is BBF.HRI.UInt16;

   --  Main Clock Frequency Register
   type CKGR_MCFR_Register is record
      --  Read-only. Main Clock Frequency
      MAINF          : CKGR_MCFR_MAINF_Field;
      --  Read-only. Main Clock Ready
      MAINFRDY       : Boolean;
      --  unspecified
      Reserved_17_31 : BBF.HRI.UInt15;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CKGR_MCFR_Register use record
      MAINF          at 0 range 0 .. 15;
      MAINFRDY       at 0 range 16 .. 16;
      Reserved_17_31 at 0 range 17 .. 31;
   end record;

   subtype CKGR_PLLAR_DIVA_Field is BBF.HRI.Byte;
   subtype CKGR_PLLAR_PLLACOUNT_Field is BBF.HRI.UInt6;
   subtype CKGR_PLLAR_MULA_Field is BBF.HRI.UInt11;

   --  PLLA Register
   type CKGR_PLLAR_Register is record
      --  Divider
      DIVA           : CKGR_PLLAR_DIVA_Field := 16#0#;
      --  PLLA Counter
      PLLACOUNT      : CKGR_PLLAR_PLLACOUNT_Field := 16#3F#;
      --  unspecified
      Reserved_14_15 : BBF.HRI.UInt2 := 16#0#;
      --  PLLA Multiplier
      MULA           : CKGR_PLLAR_MULA_Field := 16#0#;
      --  unspecified
      Reserved_27_28 : BBF.HRI.UInt2 := 16#0#;
      --  Must Be Set to 1
      ONE            : Boolean := False;
      --  unspecified
      Reserved_30_31 : BBF.HRI.UInt2 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CKGR_PLLAR_Register use record
      DIVA           at 0 range 0 .. 7;
      PLLACOUNT      at 0 range 8 .. 13;
      Reserved_14_15 at 0 range 14 .. 15;
      MULA           at 0 range 16 .. 26;
      Reserved_27_28 at 0 range 27 .. 28;
      ONE            at 0 range 29 .. 29;
      Reserved_30_31 at 0 range 30 .. 31;
   end record;

   --  Master Clock Source Selection
   type PMC_MCKR_CSS_Field is
     (--  Slow Clock is selected
      Slow_Clk,
      --  Main Clock is selected
      Main_Clk,
      --  PLLA Clock is selected
      Plla_Clk,
      --  UPLL Clock is selected
      Upll_Clk)
     with Size => 2;
   for PMC_MCKR_CSS_Field use
     (Slow_Clk => 0,
      Main_Clk => 1,
      Plla_Clk => 2,
      Upll_Clk => 3);

   --  Processor Clock Prescaler
   type PMC_MCKR_PRES_Field is
     (--  Selected clock
      Clk_1,
      --  Selected clock divided by 2
      Clk_2,
      --  Selected clock divided by 4
      Clk_4,
      --  Selected clock divided by 8
      Clk_8,
      --  Selected clock divided by 16
      Clk_16,
      --  Selected clock divided by 32
      Clk_32,
      --  Selected clock divided by 64
      Clk_64,
      --  Selected clock divided by 3
      Clk_3)
     with Size => 3;
   for PMC_MCKR_PRES_Field use
     (Clk_1 => 0,
      Clk_2 => 1,
      Clk_4 => 2,
      Clk_8 => 3,
      Clk_16 => 4,
      Clk_32 => 5,
      Clk_64 => 6,
      Clk_3 => 7);

   --  Master Clock Register
   type PMC_MCKR_Register is record
      --  Master Clock Source Selection
      CSS            : PMC_MCKR_CSS_Field := BBF.HRI.PMC.Main_Clk;
      --  unspecified
      Reserved_2_3   : BBF.HRI.UInt2 := 16#0#;
      --  Processor Clock Prescaler
      PRES           : PMC_MCKR_PRES_Field := BBF.HRI.PMC.Clk_1;
      --  unspecified
      Reserved_7_11  : BBF.HRI.UInt5 := 16#0#;
      --  PLLA Divisor by 2
      PLLADIV2       : Boolean := False;
      UPLLDIV2       : Boolean := False;
      --  unspecified
      Reserved_14_31 : BBF.HRI.UInt18 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_MCKR_Register use record
      CSS            at 0 range 0 .. 1;
      Reserved_2_3   at 0 range 2 .. 3;
      PRES           at 0 range 4 .. 6;
      Reserved_7_11  at 0 range 7 .. 11;
      PLLADIV2       at 0 range 12 .. 12;
      UPLLDIV2       at 0 range 13 .. 13;
      Reserved_14_31 at 0 range 14 .. 31;
   end record;

   subtype PMC_USB_USBDIV_Field is BBF.HRI.UInt4;

   --  USB Clock Register
   type PMC_USB_Register is record
      --  USB Input Clock Selection
      USBS           : Boolean := False;
      --  unspecified
      Reserved_1_7   : BBF.HRI.UInt7 := 16#0#;
      --  Divider for USB Clock.
      USBDIV         : PMC_USB_USBDIV_Field := 16#0#;
      --  unspecified
      Reserved_12_31 : BBF.HRI.UInt20 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_USB_Register use record
      USBS           at 0 range 0 .. 0;
      Reserved_1_7   at 0 range 1 .. 7;
      USBDIV         at 0 range 8 .. 11;
      Reserved_12_31 at 0 range 12 .. 31;
   end record;

   --  Master Clock Source Selection
   type PMC_PCK_CSS_Field is
     (--  Slow Clock is selected
      Slow_Clk,
      --  Main Clock is selected
      Main_Clk,
      --  PLLA Clock is selected
      Plla_Clk,
      --  UPLL Clock is selected
      Upll_Clk,
      --  Master Clock is selected
      Mck)
     with Size => 3;
   for PMC_PCK_CSS_Field use
     (Slow_Clk => 0,
      Main_Clk => 1,
      Plla_Clk => 2,
      Upll_Clk => 3,
      Mck => 4);

   --  Programmable Clock Prescaler
   type PMC_PCK_PRES_Field is
     (--  Selected clock
      Clk_1,
      --  Selected clock divided by 2
      Clk_2,
      --  Selected clock divided by 4
      Clk_4,
      --  Selected clock divided by 8
      Clk_8,
      --  Selected clock divided by 16
      Clk_16,
      --  Selected clock divided by 32
      Clk_32,
      --  Selected clock divided by 64
      Clk_64)
     with Size => 3;
   for PMC_PCK_PRES_Field use
     (Clk_1 => 0,
      Clk_2 => 1,
      Clk_4 => 2,
      Clk_8 => 3,
      Clk_16 => 4,
      Clk_32 => 5,
      Clk_64 => 6);

   --  Programmable Clock 0 Register
   type PMC_PCK_Register is record
      --  Master Clock Source Selection
      CSS           : PMC_PCK_CSS_Field := BBF.HRI.PMC.Slow_Clk;
      --  unspecified
      Reserved_3_3  : BBF.HRI.Bit := 16#0#;
      --  Programmable Clock Prescaler
      PRES          : PMC_PCK_PRES_Field := BBF.HRI.PMC.Clk_1;
      --  unspecified
      Reserved_7_31 : BBF.HRI.UInt25 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCK_Register use record
      CSS           at 0 range 0 .. 2;
      Reserved_3_3  at 0 range 3 .. 3;
      PRES          at 0 range 4 .. 6;
      Reserved_7_31 at 0 range 7 .. 31;
   end record;

   --  Programmable Clock 0 Register
   type PMC_PCK_Registers is array (0 .. 2) of PMC_PCK_Register;

   --  PMC_IER_PCKRDY array
   type PMC_IER_PCKRDY_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_IER_PCKRDY
   type PMC_IER_PCKRDY_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCKRDY as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCKRDY as an array
            Arr : PMC_IER_PCKRDY_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_IER_PCKRDY_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  Interrupt Enable Register
   type PMC_IER_Register is record
      --  Write-only. Main Crystal Oscillator Status Interrupt Enable
      MOSCXTS        : Boolean := False;
      --  Write-only. PLLA Lock Interrupt Enable
      LOCKA          : Boolean := False;
      --  unspecified
      Reserved_2_2   : BBF.HRI.Bit := 16#0#;
      --  Write-only. Master Clock Ready Interrupt Enable
      MCKRDY         : Boolean := False;
      --  unspecified
      Reserved_4_5   : BBF.HRI.UInt2 := 16#0#;
      --  Write-only. UTMI PLL Lock Interrupt Enable
      LOCKU          : Boolean := False;
      --  unspecified
      Reserved_7_7   : BBF.HRI.Bit := 16#0#;
      --  Write-only. Programmable Clock Ready 0 Interrupt Enable
      PCKRDY         : PMC_IER_PCKRDY_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_11_15 : BBF.HRI.UInt5 := 16#0#;
      --  Write-only. Main Oscillator Selection Status Interrupt Enable
      MOSCSELS       : Boolean := False;
      --  Write-only. Main On-Chip RC Status Interrupt Enable
      MOSCRCS        : Boolean := False;
      --  Write-only. Clock Failure Detector Event Interrupt Enable
      CFDEV          : Boolean := False;
      --  unspecified
      Reserved_19_31 : BBF.HRI.UInt13 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_IER_Register use record
      MOSCXTS        at 0 range 0 .. 0;
      LOCKA          at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      MCKRDY         at 0 range 3 .. 3;
      Reserved_4_5   at 0 range 4 .. 5;
      LOCKU          at 0 range 6 .. 6;
      Reserved_7_7   at 0 range 7 .. 7;
      PCKRDY         at 0 range 8 .. 10;
      Reserved_11_15 at 0 range 11 .. 15;
      MOSCSELS       at 0 range 16 .. 16;
      MOSCRCS        at 0 range 17 .. 17;
      CFDEV          at 0 range 18 .. 18;
      Reserved_19_31 at 0 range 19 .. 31;
   end record;

   --  PMC_IDR_PCKRDY array
   type PMC_IDR_PCKRDY_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_IDR_PCKRDY
   type PMC_IDR_PCKRDY_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCKRDY as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCKRDY as an array
            Arr : PMC_IDR_PCKRDY_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_IDR_PCKRDY_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  Interrupt Disable Register
   type PMC_IDR_Register is record
      --  Write-only. Main Crystal Oscillator Status Interrupt Disable
      MOSCXTS        : Boolean := False;
      --  Write-only. PLLA Lock Interrupt Disable
      LOCKA          : Boolean := False;
      --  unspecified
      Reserved_2_2   : BBF.HRI.Bit := 16#0#;
      --  Write-only. Master Clock Ready Interrupt Disable
      MCKRDY         : Boolean := False;
      --  unspecified
      Reserved_4_5   : BBF.HRI.UInt2 := 16#0#;
      --  Write-only. UTMI PLL Lock Interrupt Disable
      LOCKU          : Boolean := False;
      --  unspecified
      Reserved_7_7   : BBF.HRI.Bit := 16#0#;
      --  Write-only. Programmable Clock Ready 0 Interrupt Disable
      PCKRDY         : PMC_IDR_PCKRDY_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_11_15 : BBF.HRI.UInt5 := 16#0#;
      --  Write-only. Main Oscillator Selection Status Interrupt Disable
      MOSCSELS       : Boolean := False;
      --  Write-only. Main On-Chip RC Status Interrupt Disable
      MOSCRCS        : Boolean := False;
      --  Write-only. Clock Failure Detector Event Interrupt Disable
      CFDEV          : Boolean := False;
      --  unspecified
      Reserved_19_31 : BBF.HRI.UInt13 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_IDR_Register use record
      MOSCXTS        at 0 range 0 .. 0;
      LOCKA          at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      MCKRDY         at 0 range 3 .. 3;
      Reserved_4_5   at 0 range 4 .. 5;
      LOCKU          at 0 range 6 .. 6;
      Reserved_7_7   at 0 range 7 .. 7;
      PCKRDY         at 0 range 8 .. 10;
      Reserved_11_15 at 0 range 11 .. 15;
      MOSCSELS       at 0 range 16 .. 16;
      MOSCRCS        at 0 range 17 .. 17;
      CFDEV          at 0 range 18 .. 18;
      Reserved_19_31 at 0 range 19 .. 31;
   end record;

   --  PMC_SR_PCKRDY array
   type PMC_SR_PCKRDY_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_SR_PCKRDY
   type PMC_SR_PCKRDY_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCKRDY as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCKRDY as an array
            Arr : PMC_SR_PCKRDY_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_SR_PCKRDY_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  Status Register
   type PMC_SR_Register is record
      --  Read-only. Main XTAL Oscillator Status
      MOSCXTS        : Boolean;
      --  Read-only. PLLA Lock Status
      LOCKA          : Boolean;
      --  unspecified
      Reserved_2_2   : BBF.HRI.Bit;
      --  Read-only. Master Clock Status
      MCKRDY         : Boolean;
      --  unspecified
      Reserved_4_5   : BBF.HRI.UInt2;
      --  Read-only. UTMI PLL Lock Status
      LOCKU          : Boolean;
      --  Read-only. Slow Clock Oscillator Selection
      OSCSELS        : Boolean;
      --  Read-only. Programmable Clock Ready Status
      PCKRDY         : PMC_SR_PCKRDY_Field;
      --  unspecified
      Reserved_11_15 : BBF.HRI.UInt5;
      --  Read-only. Main Oscillator Selection Status
      MOSCSELS       : Boolean;
      --  Read-only. Main On-Chip RC Oscillator Status
      MOSCRCS        : Boolean;
      --  Read-only. Clock Failure Detector Event
      CFDEV          : Boolean;
      --  Read-only. Clock Failure Detector Status
      CFDS           : Boolean;
      --  Read-only. Clock Failure Detector Fault Output Status
      FOS            : Boolean;
      --  unspecified
      Reserved_21_31 : BBF.HRI.UInt11;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_SR_Register use record
      MOSCXTS        at 0 range 0 .. 0;
      LOCKA          at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      MCKRDY         at 0 range 3 .. 3;
      Reserved_4_5   at 0 range 4 .. 5;
      LOCKU          at 0 range 6 .. 6;
      OSCSELS        at 0 range 7 .. 7;
      PCKRDY         at 0 range 8 .. 10;
      Reserved_11_15 at 0 range 11 .. 15;
      MOSCSELS       at 0 range 16 .. 16;
      MOSCRCS        at 0 range 17 .. 17;
      CFDEV          at 0 range 18 .. 18;
      CFDS           at 0 range 19 .. 19;
      FOS            at 0 range 20 .. 20;
      Reserved_21_31 at 0 range 21 .. 31;
   end record;

   --  PMC_IMR_PCKRDY array
   type PMC_IMR_PCKRDY_Field_Array is array (0 .. 2) of Boolean
     with Component_Size => 1, Size => 3;

   --  Type definition for PMC_IMR_PCKRDY
   type PMC_IMR_PCKRDY_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PCKRDY as a value
            Val : BBF.HRI.UInt3;
         when True =>
            --  PCKRDY as an array
            Arr : PMC_IMR_PCKRDY_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 3;

   for PMC_IMR_PCKRDY_Field use record
      Val at 0 range 0 .. 2;
      Arr at 0 range 0 .. 2;
   end record;

   --  Interrupt Mask Register
   type PMC_IMR_Register is record
      --  Read-only. Main Crystal Oscillator Status Interrupt Mask
      MOSCXTS        : Boolean;
      --  Read-only. PLLA Lock Interrupt Mask
      LOCKA          : Boolean;
      --  unspecified
      Reserved_2_2   : BBF.HRI.Bit;
      --  Read-only. Master Clock Ready Interrupt Mask
      MCKRDY         : Boolean;
      --  unspecified
      Reserved_4_5   : BBF.HRI.UInt2;
      --  Read-only. UTMI PLL Lock Interrupt Mask
      LOCKU          : Boolean;
      --  unspecified
      Reserved_7_7   : BBF.HRI.Bit;
      --  Read-only. Programmable Clock Ready 0 Interrupt Mask
      PCKRDY         : PMC_IMR_PCKRDY_Field;
      --  unspecified
      Reserved_11_15 : BBF.HRI.UInt5;
      --  Read-only. Main Oscillator Selection Status Interrupt Mask
      MOSCSELS       : Boolean;
      --  Read-only. Main On-Chip RC Status Interrupt Mask
      MOSCRCS        : Boolean;
      --  Read-only. Clock Failure Detector Event Interrupt Mask
      CFDEV          : Boolean;
      --  unspecified
      Reserved_19_31 : BBF.HRI.UInt13;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_IMR_Register use record
      MOSCXTS        at 0 range 0 .. 0;
      LOCKA          at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      MCKRDY         at 0 range 3 .. 3;
      Reserved_4_5   at 0 range 4 .. 5;
      LOCKU          at 0 range 6 .. 6;
      Reserved_7_7   at 0 range 7 .. 7;
      PCKRDY         at 0 range 8 .. 10;
      Reserved_11_15 at 0 range 11 .. 15;
      MOSCSELS       at 0 range 16 .. 16;
      MOSCRCS        at 0 range 17 .. 17;
      CFDEV          at 0 range 18 .. 18;
      Reserved_19_31 at 0 range 19 .. 31;
   end record;

   --  PMC_FSMR_FSTT array
   type PMC_FSMR_FSTT_Field_Array is array (0 .. 15) of Boolean
     with Component_Size => 1, Size => 16;

   --  Type definition for PMC_FSMR_FSTT
   type PMC_FSMR_FSTT_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  FSTT as a value
            Val : BBF.HRI.UInt16;
         when True =>
            --  FSTT as an array
            Arr : PMC_FSMR_FSTT_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 16;

   for PMC_FSMR_FSTT_Field use record
      Val at 0 range 0 .. 15;
      Arr at 0 range 0 .. 15;
   end record;

   --  Fast Startup Mode Register
   type PMC_FSMR_Register is record
      --  Fast Startup Input Enable 0
      FSTT           : PMC_FSMR_FSTT_Field :=
                        (As_Array => False, Val => 16#0#);
      --  RTT Alarm Enable
      RTTAL          : Boolean := False;
      --  RTC Alarm Enable
      RTCAL          : Boolean := False;
      --  USB Alarm Enable
      USBAL          : Boolean := False;
      --  unspecified
      Reserved_19_19 : BBF.HRI.Bit := 16#0#;
      --  Low Power Mode
      LPM            : Boolean := False;
      --  unspecified
      Reserved_21_31 : BBF.HRI.UInt11 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_FSMR_Register use record
      FSTT           at 0 range 0 .. 15;
      RTTAL          at 0 range 16 .. 16;
      RTCAL          at 0 range 17 .. 17;
      USBAL          at 0 range 18 .. 18;
      Reserved_19_19 at 0 range 19 .. 19;
      LPM            at 0 range 20 .. 20;
      Reserved_21_31 at 0 range 21 .. 31;
   end record;

   --  PMC_FSPR_FSTP array
   type PMC_FSPR_FSTP_Field_Array is array (0 .. 15) of Boolean
     with Component_Size => 1, Size => 16;

   --  Type definition for PMC_FSPR_FSTP
   type PMC_FSPR_FSTP_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  FSTP as a value
            Val : BBF.HRI.UInt16;
         when True =>
            --  FSTP as an array
            Arr : PMC_FSPR_FSTP_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 16;

   for PMC_FSPR_FSTP_Field use record
      Val at 0 range 0 .. 15;
      Arr at 0 range 0 .. 15;
   end record;

   --  Fast Startup Polarity Register
   type PMC_FSPR_Register is record
      --  Fast Startup Input Polarityx
      FSTP           : PMC_FSPR_FSTP_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_16_31 : BBF.HRI.UInt16 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_FSPR_Register use record
      FSTP           at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   --  Fault Output Clear Register
   type PMC_FOCR_Register is record
      --  Write-only. Fault Output Clear
      FOCLR         : Boolean := False;
      --  unspecified
      Reserved_1_31 : BBF.HRI.UInt31 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_FOCR_Register use record
      FOCLR         at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype PMC_WPMR_WPKEY_Field is BBF.HRI.UInt24;

   --  Write Protect Mode Register
   type PMC_WPMR_Register is record
      --  Write Protect Enable
      WPEN         : Boolean := False;
      --  unspecified
      Reserved_1_7 : BBF.HRI.UInt7 := 16#0#;
      --  Write Protect KEY
      WPKEY        : PMC_WPMR_WPKEY_Field := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_WPMR_Register use record
      WPEN         at 0 range 0 .. 0;
      Reserved_1_7 at 0 range 1 .. 7;
      WPKEY        at 0 range 8 .. 31;
   end record;

   subtype PMC_WPSR_WPVSRC_Field is BBF.HRI.UInt16;

   --  Write Protect Status Register
   type PMC_WPSR_Register is record
      --  Read-only. Write Protect Violation Status
      WPVS           : Boolean;
      --  unspecified
      Reserved_1_7   : BBF.HRI.UInt7;
      --  Read-only. Write Protect Violation Source
      WPVSRC         : PMC_WPSR_WPVSRC_Field;
      --  unspecified
      Reserved_24_31 : BBF.HRI.Byte;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_WPSR_Register use record
      WPVS           at 0 range 0 .. 0;
      Reserved_1_7   at 0 range 1 .. 7;
      WPVSRC         at 0 range 8 .. 23;
      Reserved_24_31 at 0 range 24 .. 31;
   end record;

   --  PMC_PCER1_PID array
   type PMC_PCER1_PID_Field_Array is array (32 .. 44) of Boolean
     with Component_Size => 1, Size => 13;

   --  Type definition for PMC_PCER1_PID
   type PMC_PCER1_PID_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PID as a value
            Val : BBF.HRI.UInt13;
         when True =>
            --  PID as an array
            Arr : PMC_PCER1_PID_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 13;

   for PMC_PCER1_PID_Field use record
      Val at 0 range 0 .. 12;
      Arr at 0 range 0 .. 12;
   end record;

   --  Peripheral Clock Enable Register 1
   type PMC_PCER1_Register is record
      --  Write-only. Peripheral Clock 32 Enable
      PID            : PMC_PCER1_PID_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_13_31 : BBF.HRI.UInt19 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCER1_Register use record
      PID            at 0 range 0 .. 12;
      Reserved_13_31 at 0 range 13 .. 31;
   end record;

   --  PMC_PCDR1_PID array
   type PMC_PCDR1_PID_Field_Array is array (32 .. 44) of Boolean
     with Component_Size => 1, Size => 13;

   --  Type definition for PMC_PCDR1_PID
   type PMC_PCDR1_PID_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PID as a value
            Val : BBF.HRI.UInt13;
         when True =>
            --  PID as an array
            Arr : PMC_PCDR1_PID_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 13;

   for PMC_PCDR1_PID_Field use record
      Val at 0 range 0 .. 12;
      Arr at 0 range 0 .. 12;
   end record;

   --  Peripheral Clock Disable Register 1
   type PMC_PCDR1_Register is record
      --  Write-only. Peripheral Clock 32 Disable
      PID            : PMC_PCDR1_PID_Field :=
                        (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_13_31 : BBF.HRI.UInt19 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCDR1_Register use record
      PID            at 0 range 0 .. 12;
      Reserved_13_31 at 0 range 13 .. 31;
   end record;

   --  PMC_PCSR1_PID array
   type PMC_PCSR1_PID_Field_Array is array (32 .. 44) of Boolean
     with Component_Size => 1, Size => 13;

   --  Type definition for PMC_PCSR1_PID
   type PMC_PCSR1_PID_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  PID as a value
            Val : BBF.HRI.UInt13;
         when True =>
            --  PID as an array
            Arr : PMC_PCSR1_PID_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 13;

   for PMC_PCSR1_PID_Field use record
      Val at 0 range 0 .. 12;
      Arr at 0 range 0 .. 12;
   end record;

   --  Peripheral Clock Status Register 1
   type PMC_PCSR1_Register is record
      --  Read-only. Peripheral Clock 32 Status
      PID            : PMC_PCSR1_PID_Field;
      --  unspecified
      Reserved_13_31 : BBF.HRI.UInt19;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCSR1_Register use record
      PID            at 0 range 0 .. 12;
      Reserved_13_31 at 0 range 13 .. 31;
   end record;

   subtype PMC_PCR_PID_Field is BBF.HRI.UInt6;

   --  Divisor Value
   type PMC_PCR_DIV_Field is
     (--  Peripheral clock is MCK
      Periph_Div_Mck,
      --  Peripheral clock is MCK/2
      Periph_Div2_Mck,
      --  Peripheral clock is MCK/4
      Periph_Div4_Mck)
     with Size => 2;
   for PMC_PCR_DIV_Field use
     (Periph_Div_Mck => 0,
      Periph_Div2_Mck => 1,
      Periph_Div4_Mck => 2);

   --  Peripheral Control Register
   type PMC_PCR_Register is record
      --  Peripheral ID
      PID            : PMC_PCR_PID_Field := 16#0#;
      --  unspecified
      Reserved_6_11  : BBF.HRI.UInt6 := 16#0#;
      --  Command
      CMD            : Boolean := False;
      --  unspecified
      Reserved_13_15 : BBF.HRI.UInt3 := 16#0#;
      --  Divisor Value
      DIV            : PMC_PCR_DIV_Field := BBF.HRI.PMC.Periph_Div_Mck;
      --  unspecified
      Reserved_18_27 : BBF.HRI.UInt10 := 16#0#;
      --  Enable
      EN             : Boolean := False;
      --  unspecified
      Reserved_29_31 : BBF.HRI.UInt3 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for PMC_PCR_Register use record
      PID            at 0 range 0 .. 5;
      Reserved_6_11  at 0 range 6 .. 11;
      CMD            at 0 range 12 .. 12;
      Reserved_13_15 at 0 range 13 .. 15;
      DIV            at 0 range 16 .. 17;
      Reserved_18_27 at 0 range 18 .. 27;
      EN             at 0 range 28 .. 28;
      Reserved_29_31 at 0 range 29 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Power Management Controller
   type PMC_Peripheral is record
      --  System Clock Enable Register
      PMC_SCER   : aliased PMC_SCER_Register;
      --  System Clock Disable Register
      PMC_SCDR   : aliased PMC_SCDR_Register;
      --  System Clock Status Register
      PMC_SCSR   : aliased PMC_SCSR_Register;
      --  Peripheral Clock Enable Register 0
      PMC_PCER0  : aliased PMC_PCER0_Register;
      --  Peripheral Clock Disable Register 0
      PMC_PCDR0  : aliased PMC_PCDR0_Register;
      --  Peripheral Clock Status Register 0
      PMC_PCSR0  : aliased PMC_PCSR0_Register;
      --  UTMI Clock Register
      CKGR_UCKR  : aliased CKGR_UCKR_Register;
      --  Main Oscillator Register
      CKGR_MOR   : aliased CKGR_MOR_Register;
      --  Main Clock Frequency Register
      CKGR_MCFR  : aliased CKGR_MCFR_Register;
      --  PLLA Register
      CKGR_PLLAR : aliased CKGR_PLLAR_Register;
      --  Master Clock Register
      PMC_MCKR   : aliased PMC_MCKR_Register;
      --  USB Clock Register
      PMC_USB    : aliased PMC_USB_Register;
      --  Programmable Clock 0 Register
      PMC_PCK    : aliased PMC_PCK_Registers;
      --  Interrupt Enable Register
      PMC_IER    : aliased PMC_IER_Register;
      --  Interrupt Disable Register
      PMC_IDR    : aliased PMC_IDR_Register;
      --  Status Register
      PMC_SR     : aliased PMC_SR_Register;
      --  Interrupt Mask Register
      PMC_IMR    : aliased PMC_IMR_Register;
      --  Fast Startup Mode Register
      PMC_FSMR   : aliased PMC_FSMR_Register;
      --  Fast Startup Polarity Register
      PMC_FSPR   : aliased PMC_FSPR_Register;
      --  Fault Output Clear Register
      PMC_FOCR   : aliased PMC_FOCR_Register;
      --  Write Protect Mode Register
      PMC_WPMR   : aliased PMC_WPMR_Register;
      --  Write Protect Status Register
      PMC_WPSR   : aliased PMC_WPSR_Register;
      --  Peripheral Clock Enable Register 1
      PMC_PCER1  : aliased PMC_PCER1_Register;
      --  Peripheral Clock Disable Register 1
      PMC_PCDR1  : aliased PMC_PCDR1_Register;
      --  Peripheral Clock Status Register 1
      PMC_PCSR1  : aliased PMC_PCSR1_Register;
      --  Peripheral Control Register
      PMC_PCR    : aliased PMC_PCR_Register;
   end record
     with Volatile;

   for PMC_Peripheral use record
      PMC_SCER   at 16#0# range 0 .. 31;
      PMC_SCDR   at 16#4# range 0 .. 31;
      PMC_SCSR   at 16#8# range 0 .. 31;
      PMC_PCER0  at 16#10# range 0 .. 31;
      PMC_PCDR0  at 16#14# range 0 .. 31;
      PMC_PCSR0  at 16#18# range 0 .. 31;
      CKGR_UCKR  at 16#1C# range 0 .. 31;
      CKGR_MOR   at 16#20# range 0 .. 31;
      CKGR_MCFR  at 16#24# range 0 .. 31;
      CKGR_PLLAR at 16#28# range 0 .. 31;
      PMC_MCKR   at 16#30# range 0 .. 31;
      PMC_USB    at 16#38# range 0 .. 31;
      PMC_PCK    at 16#40# range 0 .. 95;
      PMC_IER    at 16#60# range 0 .. 31;
      PMC_IDR    at 16#64# range 0 .. 31;
      PMC_SR     at 16#68# range 0 .. 31;
      PMC_IMR    at 16#6C# range 0 .. 31;
      PMC_FSMR   at 16#70# range 0 .. 31;
      PMC_FSPR   at 16#74# range 0 .. 31;
      PMC_FOCR   at 16#78# range 0 .. 31;
      PMC_WPMR   at 16#E4# range 0 .. 31;
      PMC_WPSR   at 16#E8# range 0 .. 31;
      PMC_PCER1  at 16#100# range 0 .. 31;
      PMC_PCDR1  at 16#104# range 0 .. 31;
      PMC_PCSR1  at 16#108# range 0 .. 31;
      PMC_PCR    at 16#10C# range 0 .. 31;
   end record;

   --  Power Management Controller
   PMC_Periph : aliased PMC_Peripheral
     with Import, Address => PMC_Base;

end BBF.HRI.PMC;
