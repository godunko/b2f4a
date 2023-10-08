------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                           Hardware Proxy Layer                           --
--                                                                          --
--                        Runtime Library Component                         --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2019-2023, Vadim Godunko <vgodunko@gmail.com>                --
-- All rights reserved.                                                     --
--                                                                          --
-- Redistribution and use in source and binary forms, with or without       --
-- modification, are permitted provided that the following conditions       --
-- are met:                                                                 --
--                                                                          --
--  * Redistributions of source code must retain the above copyright        --
--    notice, this list of conditions and the following disclaimer.         --
--                                                                          --
--  * Redistributions in binary form must reproduce the above copyright     --
--    notice, this list of conditions and the following disclaimer in the   --
--    documentation and/or other materials provided with the distribution.  --
--                                                                          --
--  * Neither the name of the Vadim Godunko, IE nor the names of its        --
--    contributors may be used to endorse or promote products derived from  --
--    this software without specific prior written permission.              --
--                                                                          --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT     --
-- HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   --
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED --
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   --
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     --
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       --
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             --
--                                                                          --
------------------------------------------------------------------------------

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

   -----------------------
   -- Is_Receiver_Ready --
   -----------------------

   function Is_Receiver_Ready (Base : UART) return Boolean is
   begin
      return Base.SR.RXRDY;
   end Is_Receiver_Ready;

   --------------------------
   -- Is_Transmitter_Ready --
   --------------------------

   function Is_Transmitter_Ready (Base : UART) return Boolean is
   begin
      return Base.SR.TXRDY;
   end Is_Transmitter_Ready;

   ----------------------------------
   -- Is_Transmission_Buffer_Empty --
   ----------------------------------

   function Is_Transmission_Buffer_Empty (Base : UART) return Boolean is
   begin
      return Base.SR.TXBUFE;
   end Is_Transmission_Buffer_Empty;

   ----------
   -- Read --
   ----------

   procedure Read
     (Base    : UART;
      Data    : out Interfaces.Unsigned_8;
      Success : out Boolean) is
   begin
      if not Is_Receiver_Ready (Base) then
         Success := False;

      else
         Data := Interfaces.Unsigned_8 (Base.RHR.RXCHR);
         Success := True;
      end if;
   end Read;

   ------------------------
   -- Set_Receive_Buffer --
   ------------------------

   procedure Set_Receive_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : Interfaces.Unsigned_16) is
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
      Length : Interfaces.Unsigned_16) is
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
      Length      : Interfaces.Unsigned_16;
      Next_Buffer : System.Address;
      Next_Length : Interfaces.Unsigned_16) is
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
     (Base    : UART;
      Data    : Interfaces.Unsigned_8;
      Success : out Boolean) is
   begin
      if not Is_Transmitter_Ready (Base) then
         Success := False;

      else
         Base.THR.TXCHR := BBF.HRI.Byte (Data);
         Success := True;
      end if;
   end Write;

end BBF.HPL.UART;
