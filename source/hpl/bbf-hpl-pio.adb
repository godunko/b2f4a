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

package body BBF.HPL.PIO is

   -----------
   -- Clear --
   -----------

   procedure Clear (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.CODR :=
        (As_Array => True,
         Arr      => BBF.HRI.PIO.PIOA_CODR_P_Field_Array (Mask));
   end Clear;

   -----------------------
   -- Disable_Interrupt --
   -----------------------

   procedure Disable_Interrupt (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.IDR.Arr := BBF.HRI.PIO.PIOA_IDR_P_Field_Array (Mask);
   end Disable_Interrupt;

   ----------------------
   -- Enable_Interrupt --
   ----------------------

   procedure Enable_Interrupt (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.IER.Arr := BBF.HRI.PIO.PIOA_IER_P_Field_Array (Mask);
   end Enable_Interrupt;

   ---------
   -- Get --
   ---------

   function Get (Base : PIO) return PIO_Pin_Array is
   begin
      return PIO_Pin_Array (Base.PDSR.Arr);
   end Get;

   --------------------------
   -- Get_And_Clear_Status --
   --------------------------

   function Get_And_Clear_Status (Base : PIO) return Status is
   begin
      return Status (Base.ISR.Arr);
   end Get_And_Clear_Status;

   ----------
   -- PIOA --
   ----------

   function PIOA return PIO is
   begin
      return BBF.HRI.PIO.PIOA_Periph'Access;
   end PIOA;

   ----------
   -- PIOB --
   ----------

   function PIOB return PIO is
   begin
      return BBF.HRI.PIO.PIOB_Periph'Access;
   end PIOB;

   ----------
   -- PIOC --
   ----------

   function PIOC return PIO is
   begin
      return BBF.HRI.PIO.PIOC_Periph'Access;
   end PIOC;

   ----------
   -- PIOD --
   ----------

   function PIOD return PIO is
   begin
      return BBF.HRI.PIO.PIOD_Periph'Access;
   end PIOD;

   ---------
   -- Set --
   ---------

   procedure Set (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.SODR :=
        (As_Array => True,
         Arr      => BBF.HRI.PIO.PIOA_SODR_P_Field_Array (Mask));
   end Set;

   --------------
   -- Set_Edge --
   --------------

   procedure Set_Edge (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.ESR.Arr := BBF.HRI.PIO.PIOA_ESR_P_Field_Array (Mask);
   end Set_Edge;

   ---------------------
   -- Set_Falling_Low --
   ---------------------

   procedure Set_Falling_Low (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.FELLSR.Arr := BBF.HRI.PIO.PIOA_FELLSR_P_Field_Array (Mask);
   end Set_Falling_Low;

   ---------------
   -- Set_Level --
   ---------------

   procedure Set_Level (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.LSR.Arr := BBF.HRI.PIO.PIOA_LSR_P_Field_Array (Mask);
   end Set_Level;

   ----------------
   -- Set_Output --
   ----------------

   procedure Set_Output
     (Base       : PIO;
      Mask       : PIO_Pin_Array;
      Default    : Boolean := True;
      Multidrive : Boolean := False) is
   begin
      --  Enable multi-drive if necessary

      if Multidrive then
         Base.MDER :=
           (As_Array => True,
            Arr      => BBF.HRI.PIO.PIOA_MDER_P_Field_Array (Mask));

      else
         Base.MDDR :=
           (As_Array => True,
            Arr      => BBF.HRI.PIO.PIOA_MDDR_P_Field_Array (Mask));
      end if;

      --  Set default value

      if Default then
         Set (Base, Mask);

      else
         Clear (Base, Mask);
      end if;

      --  Configure as output and enable control of PIO

      Base.OER.Arr := BBF.HRI.PIO.PIOA_OER_P_Field_Array (Mask);
      Base.PER.Arr := BBF.HRI.PIO.PIOA_PER_P_Field_Array (Mask);
   end Set_Output;

   --------------------
   -- Set_Peripheral --
   --------------------

   procedure Set_Peripheral
     (Base : PIO;
      Mask : PIO_Pin_Array;
      To   : Peripheral_Function)
   is
      use type BBF.HRI.PIO.PIOA_ABSR_P_Field_Array;

   begin
      --  Disable interrupts on the pin(s)

      Base.IDR.Arr := BBF.HRI.PIO.PIOA_IDR_P_Field_Array (Mask);

      --  Set peripheral function

      case To is
         when A =>
            Base.ABSR.Arr :=
              Base.ABSR.Arr and not BBF.HRI.PIO.PIOA_ABSR_P_Field_Array (Mask);

         when B =>
            Base.ABSR.Arr :=
              Base.ABSR.Arr or BBF.HRI.PIO.PIOA_ABSR_P_Field_Array (Mask);
      end case;

      --  Remove the pins from under the control of PIO

      Base.PDR.Arr := BBF.HRI.PIO.PIOA_PDR_P_Field_Array (Mask);
   end Set_Peripheral;

   ---------------------
   -- Set_Rising_High --
   ---------------------

   procedure Set_Rising_High (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.REHLSR.Arr := BBF.HRI.PIO.PIOA_REHLSR_P_Field_Array (Mask);
   end Set_Rising_High;

end BBF.HPL.PIO;
