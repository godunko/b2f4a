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

with System.Storage_Elements;

package body BBF.HPL.UART is

   -----------------------
   -- Disable_Interrupt --
   -----------------------

   procedure Disable_Interrupt
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) is
   begin
      case Interrupt is
         when Receive_Ready =>
            Base.IDR := (RXRDY => True, others => <>);

         when Transmit_Ready =>
            Base.IDR := (TXRDY => True, others => <>);

         when End_Of_Receive_Transfer =>
            Base.IDR := (ENDRX => True, others => <>);

         when End_Of_Transmit_Transfer =>
            Base.IDR := (ENDTX => True, others => <>);

         when Overrun_Error =>
            Base.IDR := (OVRE => True, others => <>);

         when Framing_Error =>
            Base.IDR := (FRAME => True, others => <>);

         when Parity_Error =>
            Base.IDR := (PARE => True, others => <>);

         when Transmit_Empty =>
            Base.IDR := (TXEMPTY => True, others => <>);

         when Transmission_Buffer_Empty =>
            Base.IDR := (TXBUFE => True, others => <>);

         when Receive_Buffer_Full =>
            Base.IDR := (RXBUFF => True, others => <>);
      end case;
   end Disable_Interrupt;

   ----------------------------
   -- Disable_Receive_Buffer --
   ----------------------------

   procedure Disable_Receive_Buffer (Base : UART) is
   begin
      BBF.HRI.UART.UART_Periph.PTCR := (RXTDIS => True, others => <>);
   end Disable_Receive_Buffer;

   ---------------------------------
   -- Disable_Transmission_Buffer --
   ---------------------------------

   procedure Disable_Transmission_Buffer (Base : UART) is
   begin
      BBF.HRI.UART.UART_Periph.PTCR := (TXTDIS => True, others => <>);
   end Disable_Transmission_Buffer;

   ----------------------
   -- Enable_Interrupt --
   ----------------------

   procedure Enable_Interrupt
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) is
   begin
      case Interrupt is
         when Receive_Ready =>
            Base.IER := (RXRDY => True, others => <>);

         when Transmit_Ready =>
            Base.IER := (TXRDY => True, others => <>);

         when End_Of_Receive_Transfer =>
            Base.IER := (ENDRX => True, others => <>);

         when End_Of_Transmit_Transfer =>
            Base.IER := (ENDTX => True, others => <>);

         when Overrun_Error =>
            Base.IER := (OVRE => True, others => <>);

         when Framing_Error =>
            Base.IER := (FRAME => True, others => <>);

         when Parity_Error =>
            Base.IER := (PARE => True, others => <>);

         when Transmit_Empty =>
            Base.IER := (TXEMPTY => True, others => <>);

         when Transmission_Buffer_Empty =>
            Base.IER := (TXBUFE => True, others => <>);

         when Receive_Buffer_Full =>
            Base.IER := (RXBUFF => True, others => <>);
      end case;
   end Enable_Interrupt;

   ---------------------------
   -- Enable_Receive_Buffer --
   ---------------------------

   procedure Enable_Receive_Buffer (Base : UART) is
   begin
      BBF.HRI.UART.UART_Periph.PTCR := (RXTEN => True, others => <>);
   end Enable_Receive_Buffer;

   --------------------------------
   -- Enable_Transmission_Buffer --
   --------------------------------

   procedure Enable_Transmission_Buffer (Base : UART) is
   begin
      BBF.HRI.UART.UART_Periph.PTCR := (TXTEN => True, others => <>);
   end Enable_Transmission_Buffer;

   ----------------
   -- Get_Status --
   ----------------

   function Get_Status (Base : UART) return UART_Status is
   begin
      return UART_Status (Base.SR);
   end Get_Status;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Base                   : UART;
      Master_Clock_Frequency : Interfaces.Unsigned_32;
      Baud_Rate              : Interfaces.Unsigned_32)
   is
      use type Interfaces.Unsigned_32;

      Clock_Divisor : constant Interfaces.Unsigned_32 :=
        Master_Clock_Frequency / Baud_Rate / 16;
      --  Computed clock divisor for Baud Rate Generator Register.
      --  Value 16 is UART internal div factor for sampling

   begin
      --  Reset and disable receiver and transmitter

      Base.CR :=
        (RSTRX | RSTTX => True,
         RXDIS | TXDIS => True,
         others        => <>);

      --  Configure baudrate

      if Clock_Divisor not in 1 .. 65_535 then
         raise Program_Error;
      end if;

      Base.BRGR.CD := BBF.HRI.UInt16 (Clock_Divisor);

      --  Configure mode

      Base.MR :=
        (PAR    => BBF.HRI.UART.MARK,
         --  XXX: Parity mode should be configurable.
         CHMODE => BBF.HRI.UART.Normal,
         others => <>);

      --  Disable PDC channel

      Base.PTCR := (RXTDIS | TXTDIS => True, others => <>);

      --  Enable receiver and transmitter

      Base.CR :=
        (RXEN | TXEN => True,
         others      => <>);
   end Initialize;

   --------------------------
   -- Is_Interrupt_Enabled --
   --------------------------

   function Is_Interrupt_Enabled
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) return Boolean is
   begin
      case Interrupt is
         when Receive_Ready =>
            return Base.IMR.RXRDY;

         when Transmit_Ready =>
            return Base.IMR.TXRDY;

         when End_Of_Receive_Transfer =>
            return Base.IMR.ENDRX;

         when End_Of_Transmit_Transfer =>
            return Base.IMR.ENDTX;

         when Overrun_Error =>
            return Base.IMR.OVRE;

         when Framing_Error =>
            return Base.IMR.FRAME;

         when Parity_Error =>
            return Base.IMR.PARE;

         when Transmit_Empty =>
            return Base.IMR.TXEMPTY;

         when Transmission_Buffer_Empty =>
            return Base.IMR.TXBUFE;

         when Receive_Buffer_Full =>
            return Base.IMR.RXBUFF;
      end case;
   end Is_Interrupt_Enabled;

   -----------------------
   -- Is_Receiver_Ready --
   -----------------------

   function Is_Receiver_Ready (Status : UART_Status) return Boolean is
   begin
      return Status.RXRDY;
   end Is_Receiver_Ready;

   --------------------------
   -- Is_Transmitter_Ready --
   --------------------------

   function Is_Transmitter_Ready (Status : UART_Status) return Boolean is
   begin
      return Status.TXRDY;
   end Is_Transmitter_Ready;

   ----------------------------------
   -- Is_Transmission_Buffer_Empty --
   ----------------------------------

   function Is_Transmission_Buffer_Empty (Status : UART_Status) return Boolean is
   begin
      return Status.TXBUFE;
   end Is_Transmission_Buffer_Empty;

   ----------
   -- Read --
   ----------

   function Read (Base : UART) return BBF.Unsigned_8 is
   begin
      return BBF.Unsigned_8 (Base.RHR.RXCHR);
   end Read;

   ------------------------
   -- Set_Receive_Buffer --
   ------------------------

   procedure Set_Receive_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : BBF.Unsigned_16) is
   begin
      BBF.HRI.UART.UART_Periph.RPR :=
        BBF.HRI.UInt32 (System.Storage_Elements.To_Integer (Buffer));
      BBF.HRI.UART.UART_Periph.RCR :=
        (RXCTR => BBF.HRI.UInt16 (Length), others => <>);
   end Set_Receive_Buffer;

   -----------------------------
   -- Set_Transmission_Buffer --
   -----------------------------

   procedure Set_Transmission_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : BBF.Unsigned_16) is
   begin
      BBF.HRI.UART.UART_Periph.TPR :=
        BBF.HRI.UInt32 (System.Storage_Elements.To_Integer (Buffer));
      BBF.HRI.UART.UART_Periph.TCR :=
        (TXCTR => BBF.HRI.UInt16 (Length), others => <>);
   end Set_Transmission_Buffer;

   -----------------------------
   -- Set_Transmission_Buffer --
   -----------------------------

   procedure Set_Transmission_Buffer
     (Base        : UART;
      Buffer      : System.Address;
      Length      : BBF.Unsigned_16;
      Next_Buffer : System.Address;
      Next_Length : BBF.Unsigned_16) is
   begin
      BBF.HRI.UART.UART_Periph.TPR :=
        BBF.HRI.UInt32 (System.Storage_Elements.To_Integer (Buffer));
      BBF.HRI.UART.UART_Periph.TCR :=
        (TXCTR => BBF.HRI.UInt16 (Length), others => <>);
      BBF.HRI.UART.UART_Periph.TNPR :=
        BBF.HRI.UInt32 (System.Storage_Elements.To_Integer (Next_Buffer));
      BBF.HRI.UART.UART_Periph.TNCR :=
        (TXNCTR => BBF.HRI.UInt16 (Next_Length), others => <>);
   end Set_Transmission_Buffer;

   -----------
   -- UART0 --
   -----------

   function UART0 return UART is
   begin
      return BBF.HRI.UART.UART_Periph'Access;
   end UART0;

   -----------
   -- Write --
   -----------

   procedure Write
     (Base : UART;
      Data : BBF.Unsigned_8) is
   begin
      Base.THR.TXCHR := BBF.HRI.Byte (Data);
   end Write;

end BBF.HPL.UART;
