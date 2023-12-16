------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                           Hardware Proxy Layer                           --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with Ada.Unchecked_Conversion;

with System.Storage_Elements;

package body BBF.HPL.TWI is

   procedure Reset (Self : TWI);
   --  Reset TWI.

   procedure Enable_Master_Mode (Self : TWI);
   --  Enable TWI master mode.

   procedure Set_Speed
     (Self                 : TWI;
      Main_Clock_Frequency : Interfaces.Unsigned_32;
      Speed                : Interfaces.Unsigned_32;
      Success              : out Boolean);
   --  Set the I2C bus speed in conjunction with the clock frequency.

   -----------------------
   -- Disable_Interrupt --
   -----------------------

   procedure Disable_Interrupt
     (Self      : TWI;
      Interrupt : TWI_Interrupt)
   is
      Mask  : constant BBF.HRI.TWI.TWI0_IDR_Register :=
        (TXCOMP => Interrupt = Transmission_Completed,
         RXRDY  => Interrupt = Receive_Holding_Register_Ready,
         TXRDY  => Interrupt = Transmit_Holding_Register_Ready,
         SVACC  => Interrupt = Slave_Access,
         GACC   => Interrupt = General_Call_Access,
         OVRE   => Interrupt = Overrun_Error,
         NACK   => Interrupt = Not_Acknowledge,
         ARBLST => Interrupt = Arbitration_Lost,
         SCL_WS => Interrupt = Clock_Wait_State,
         EOSACC => Interrupt = End_Of_Slave_Access,
         ENDRX  => Interrupt = End_Of_Receive_Buffer,
         ENDTX  => Interrupt = End_Of_Transmit_Buffer,
         RXBUFF => Interrupt = Receive_Buffer_Full,
         TXBUFE => Interrupt = Transmit_Buffer_Empty,
         others => <>);
      Dummy : BBF.HRI.TWI.TWI0_SR_Register;

   begin
      Self.IDR := Mask;
      Dummy    := Self.SR;  --  Dummy read.
   end Disable_Interrupt;

   ------------------------
   -- Disable_Interrupts --
   ------------------------

   procedure Disable_Interrupts (Self : TWI) is
      Dummy : BBF.HRI.TWI.TWI0_SR_Register;

   begin
      Self.IDR :=
        (TXCOMP | RXRDY | TXRDY | SVACC | GACC | OVRE | NACK | ARBLST
           | SCL_WS | EOSACC | ENDRX | ENDTX | RXBUFF | TXBUFE => True,
         others => <>);
      Dummy    := Self.SR;  --  Dummy read of status register
   end Disable_Interrupts;

   ----------------------------
   -- Disable_Receive_Buffer --
   ----------------------------

   procedure Disable_Receive_Buffer (Self : TWI) is
   begin
      Self.PTCR := (RXTDIS => True, others => <>);
   end Disable_Receive_Buffer;

   ---------------------------------
   -- Disable_Transmission_Buffer --
   ---------------------------------

   procedure Disable_Transmission_Buffer (Self : TWI) is
   begin
      Self.PTCR := (TXTDIS => True, others => <>);
   end Disable_Transmission_Buffer;

   ----------------------
   -- Enable_Interrupt --
   ----------------------

   procedure Enable_Interrupt
     (Self      : TWI;
      Interrupt : TWI_Interrupt)
   is
      Mask : constant BBF.HRI.TWI.TWI0_IER_Register :=
        (TXCOMP => Interrupt = Transmission_Completed,
         RXRDY  => Interrupt = Receive_Holding_Register_Ready,
         TXRDY  => Interrupt = Transmit_Holding_Register_Ready,
         SVACC  => Interrupt = Slave_Access,
         GACC   => Interrupt = General_Call_Access,
         OVRE   => Interrupt = Overrun_Error,
         NACK   => Interrupt = Not_Acknowledge,
         ARBLST => Interrupt = Arbitration_Lost,
         SCL_WS => Interrupt = Clock_Wait_State,
         EOSACC => Interrupt = End_Of_Slave_Access,
         ENDRX  => Interrupt = End_Of_Receive_Buffer,
         ENDTX  => Interrupt = End_Of_Transmit_Buffer,
         RXBUFF => Interrupt = Receive_Buffer_Full,
         TXBUFE => Interrupt = Transmit_Buffer_Empty,
         others => <>);

   begin
      Self.IER := Mask;
   end Enable_Interrupt;

   ------------------------
   -- Enable_Master_Mode --
   ------------------------

   procedure Enable_Master_Mode (Self : TWI) is
   begin
      --  Set Master Disable bit and Slave Disable bit

      Self.CR := (MSDIS | SVDIS => True, others => <>);

      --  Set Master Enable bit

      Self.CR.MSEN := True;
   end Enable_Master_Mode;

   ---------------------------
   -- Enable_Receive_Buffer --
   ---------------------------

   procedure Enable_Receive_Buffer (Self : TWI) is
   begin
      Self.PTCR := (RXTEN => True, others => <>);
   end Enable_Receive_Buffer;

   --------------------------------
   -- Enable_Transmission_Buffer --
   --------------------------------

   procedure Enable_Transmission_Buffer (Self : TWI) is
   begin
      Self.PTCR := (TXTEN => True, others => <>);
   end Enable_Transmission_Buffer;

   -----------------------
   -- Get_Masked_Status --
   -----------------------

   function Get_Masked_Status (Self : TWI) return TWI_Status is

      use type BBF.HRI.UInt32;

      function To_UInt32 is
        new Ada.Unchecked_Conversion
             (BBF.HRI.TWI.TWI0_SR_Register, BBF.HRI.UInt32);
      function To_UInt32 is
        new Ada.Unchecked_Conversion
          (BBF.HRI.TWI.TWI0_IMR_Register, BBF.HRI.UInt32);
      function To_TWI_Status is
        new Ada.Unchecked_Conversion (BBF.HRI.UInt32, TWI_Status);

   begin
      return To_TWI_Status (To_UInt32 (Self.SR) and To_UInt32 (Self.IMR));
   end Get_Masked_Status;

   ----------------
   -- Get_Status --
   ----------------

   function Get_Status (Self : TWI) return TWI_Status is
   begin
      return TWI_Status (Self.SR);
   end Get_Status;

   -----------------------
   -- Initialize_Master --
   -----------------------

   procedure Initialize_Master
     (Self                 : TWI;
      Main_Clock_Frequency : Interfaces.Unsigned_32;
      Speed                : Interfaces.Unsigned_32)
   is
      Dummy_SR      : BBF.HRI.TWI.TWI0_SR_Register;
      Dummy_Boolean : Boolean;

   begin
      --  Disable TWI interrupts

      Disable_Interrupts (Self);

      --  Reset TWI peripheral

      Reset (Self);

      Enable_Master_Mode (Self);

      --  Select the speed
      Set_Speed (Self, Main_Clock_Frequency, Speed, Dummy_Boolean);

      --  XXX For SPI mode CR.QUICK must be set
   end Initialize_Master;

   -----------
   -- Probe --
   -----------

   function Probe
     (Self    : TWI;
      Address : BBF.I2C.Device_Address) return Boolean
   is
      SR : BBF.HRI.TWI.TWI0_SR_Register;

   begin
      --  XXX May reuse Master_Write_Synchronous without Internal_Address
      --  parameter, which is not implemented yet.

      --  Set write mode, slave address and 3 internal address byte lengths

      Self.MMR := (others => <>);
      Self.MMR :=
        (DADR   => BBF.HRI.TWI.TWI0_MMR_DADR_Field (Address),
         MREAD  => False,
         IADRSZ => BBF.HRI.TWI.None,
         others => <>);

      --  Set internal address for remote chip

      Self.IADR := (others => <>);
      Self.IADR := (IADR => 0, others => <>);

      loop
         SR := Self.SR;

         if SR.NACK then
            return False;
         end if;

         if SR.TXRDY then
            Self.THR := (TXDATA => 16#00#, others => <>);

            exit;
         end if;
      end loop;

      loop
         SR := Self.SR;

         if SR.NACK then
            return False;
         end if;

         if SR.TXRDY then
            exit;
         end if;
      end loop;

      Self.CR := (STOP => True, others => <>);

      while not Self.SR.TXCOMP loop
         null;
      end loop;

      return True;
   end Probe;

   -----------
   -- Reset --
   -----------

   procedure Reset (Self : TWI) is
      Dummy_Byte : BBF.HRI.Byte;

   begin
      Self.CR.SWRST := True;
      --  Set SWRST bit to reset TWI peripheral

      Dummy_Byte := Self.RHR.RXDATA;
   end Reset;

   -------------------------
   -- Send_Stop_Condition --
   -------------------------

   procedure Send_Stop_Condition (Self : TWI) is
   begin
      Self.CR := (STOP => True, others => <>);
   end Send_Stop_Condition;

   ------------------------
   -- Set_Receive_Buffer --
   ------------------------

   procedure Set_Receive_Buffer
     (Self   : TWI;
      Buffer : System.Address;
      Length : BBF.Unsigned_16) is
   begin
      Self.RPR :=
        BBF.HRI.UInt32 (System.Storage_Elements.To_Integer (Buffer));
      Self.RCR := (RXCTR => BBF.HRI.UInt16 (Length), others => <>);
   end Set_Receive_Buffer;

   -----------------------------
   -- Set_Transmission_Buffer --
   -----------------------------

   procedure Set_Transmission_Buffer
     (Self   : TWI;
      Buffer : System.Address;
      Length : BBF.Unsigned_16) is
   begin
      Self.TPR :=
        BBF.HRI.UInt32 (System.Storage_Elements.To_Integer (Buffer));
      Self.TCR := (TXCTR => BBF.HRI.UInt16 (Length), others => <>);
   end Set_Transmission_Buffer;

   ---------------
   -- Set_Speed --
   ---------------

   procedure Set_Speed
     (Self                 : TWI;
      Main_Clock_Frequency : Interfaces.Unsigned_32;
      Speed                : Interfaces.Unsigned_32;
      Success              : out Boolean)
   is
      use type Interfaces.Unsigned_32;

      Fast_Mode_Speed_Limit : constant := 400_000;
      Low_Level_Time_Limit  : constant := 384_000;

      CK_Div  : Interfaces.Unsigned_32 := 0;
      CL_Div  : Interfaces.Unsigned_32;
      CH_Div  : Interfaces.Unsigned_32;
      CLH_Div : Interfaces.Unsigned_32;

   begin
      if Speed > Fast_Mode_Speed_Limit then
         Success := False;

         return;
      end if;

      --  Low level time not less than 1.3us of I2C Fast Mode.

      if Speed > Low_Level_Time_Limit then
         --  Low level of time fixed for 1.3us.

         CL_Div := Main_Clock_Frequency / ((Low_Level_Time_Limit * 2) - 4);
         CH_Div := Main_Clock_Frequency / ((Speed + (Speed - Low_Level_Time_Limit)) * 2) - 4;

         --  CLDIV must fit in 8 bits, CKDIV must fit in 3 bits

         while CL_Div > 16#FF# and CK_Div < 16#07# loop
            --  Increase clock divider

            CK_Div := CK_Div + 1;

            --  Divide CLDIV value

            CL_Div := CL_Div / 2;
         end loop;

         --  CHDIV must fit in 8 bits, CKDIV must fit in 3 bits

         while CH_Div > 16#FF# and CK_Div < 16#07# loop
            --  Increase clock divider

            CK_Div := CK_Div + 1;

            --  Divide CHDIV value

            CH_Div := CH_Div / 2;
         end loop;

         --  Set clock waveform generator register

         Self.CWGR :=
           (CLDIV  => BBF.HRI.TWI.TWI0_CWGR_CLDIV_Field (CL_Div),
            CHDIV  => BBF.HRI.TWI.TWI0_CWGR_CHDIV_Field (CH_Div),
            CKDIV  => BBF.HRI.TWI.TWI0_CWGR_CKDIV_Field (CK_Div),
            others => <>);

      else
         CLH_Div := Main_Clock_Frequency / (Speed * 2) - 4;

         --  CLDIV and CHDIV must fit in 8 bits, CKDIV must fit in 3 bits

         while (CLH_Div > 16#FF# and CK_Div < 16#07#) loop
            --  Increase clock divider

            CK_Div := CK_Div + 1;

            --  Divide CLDIV and CHDIV values

            CLH_Div := CLH_Div / 2;
         end loop;

         --  Set clock waveform generator register

         Self.CWGR :=
           (CLDIV  => BBF.HRI.TWI.TWI0_CWGR_CLDIV_Field (CLH_Div),
            CHDIV  => BBF.HRI.TWI.TWI0_CWGR_CHDIV_Field (CLH_Div),
            CKDIV  => BBF.HRI.TWI.TWI0_CWGR_CKDIV_Field (CK_Div),
            others => <>);
      end if;

      Success := True;
   end Set_Speed;

   ----------
   -- TWI0 --
   ----------

   function TWI0 return TWI is
   begin
      return BBF.HRI.TWI.TWI0_Periph'Access;
   end TWI0;

   ----------
   -- TWI1 --
   ----------

   function TWI1 return TWI is
   begin
      return BBF.HRI.TWI.TWI0_Periph'Access;
   end TWI1;

   -----------------------------
   -- Master_Read_Synchronous --
   -----------------------------

   procedure Master_Read_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out BBF.Unsigned_8;
      Success          : out Boolean)
   is
      Buffer : BBF.Unsigned_8_Array_16 (1 .. 1)
        with Import  => True,
             Address => Data'Address;

   begin
      Master_Read_Synchronous (Self, Address, Internal_Address, Buffer, Success);
   end Master_Read_Synchronous;

   -----------------------------
   -- Master_Read_Synchronous --
   -----------------------------

   procedure Master_Read_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out BBF.Unsigned_8_Array_16;
      Success          : out Boolean)
   is
      SR : BBF.HRI.TWI.TWI0_SR_Register;

   begin
      if Data'Length = 0 then
         Success := False;

         return;
      end if;

      --  Set read mode, slave address and 3 internal address byte lengths

      Self.MMR := (others => <>);
      Self.MMR :=
        (DADR   => BBF.HRI.TWI.TWI0_MMR_DADR_Field (Address),
         MREAD  => True,
         IADRSZ => BBF.HRI.TWI.Val_1_Byte,
         others => <>);

      --  Set internal address for remote chip

      Self.IADR := (others => <>);
      Self.IADR :=
        (IADR   => BBF.HRI.TWI.TWI0_IADR_IADR_Field (Internal_Address),
         others => <>);

      --  Send a START condition

      Self.CR := (START => True, others => <>);

      for Index in Data'Range loop
         --  Sent STOP condition after receive of the last byte.

         if Index = Data'Last then
            Self.CR := (STOP => True, others => <>);
         end if;

         loop
            SR := Self.SR;

            if SR.NACK then
               Success := False;

               return;
            end if;

            --  XXX: timeout is not implemented

            exit when SR.RXRDY;
         end loop;

         Data (Index) := BBF.Unsigned_8 (Self.RHR.RXDATA);
      end loop;

      loop
         exit when Self.SR.TXCOMP;
      end loop;

      SR := Self.SR;

      Success := True;
   end Master_Read_Synchronous;

   ------------------------------
   -- Master_Write_Synchronous --
   ------------------------------

   procedure Master_Write_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : BBF.Unsigned_8;
      Success          : out Boolean)
   is
      Buffer : BBF.Unsigned_8_Array_16 (1 .. 1)
        with Import  => True,
             Address => Data'Address;

   begin
      Master_Write_Synchronous
       (Self, Address, Internal_Address, Buffer, Success);
   end Master_Write_Synchronous;

   ------------------------------
   -- Master_Write_Synchronous --
   ------------------------------

   procedure Master_Write_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : BBF.Unsigned_8_Array_16;
      Success          : out Boolean)
   is
      SR : BBF.HRI.TWI.TWI0_SR_Register;

   begin
      --  Check argument

      if Data'Length = 0 then
         Success := False;

         return;
      end if;

      --  Set write mode, slave address and 3 internal address byte lengths

      Self.MMR := (others => <>);
      Self.MMR :=
        (DADR   => BBF.HRI.TWI.TWI0_MMR_DADR_Field (Address),
         MREAD  => False,
         IADRSZ => BBF.HRI.TWI.Val_1_Byte,
         others => <>);

      --  Set internal address for remote chip

      Self.IADR := (others => <>);
      Self.IADR :=
        (IADR   => BBF.HRI.TWI.TWI0_IADR_IADR_Field (Internal_Address),
         others => <>);

      --  Send all bytes

      for Byte of Data loop
         loop
            SR := Self.SR;

            if SR.NACK then
               Success := False;

               return;
            end if;

            exit when SR.TXRDY;
         end loop;

         Self.THR :=
          (TXDATA => BBF.HRI.TWI.TWI0_THR_TXDATA_Field (Byte), others => <>);
      end loop;

      loop
         SR := Self.SR;

         if SR.NACK then
            Success := False;

            return;
         end if;

         exit when SR.TXRDY;
      end loop;

      Self.CR := (STOP => True, others => <>);

      loop
         exit when Self.SR.TXCOMP;
      end loop;

      Success := True;
   end Master_Write_Synchronous;

end BBF.HPL.TWI;
