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

--  Universal Asynchronous Receiver Transceiver (UART)

pragma Restrictions (No_Elaboration_Code);

with System;

with BBF.HRI.UART;

package BBF.HPL.UART is

   pragma Preelaborate;

   type UART_Interrupt_Kind is
     (Receive_Ready,
      Transmit_Ready,
      End_Of_Receive_Transfer,
      End_Of_Transmit_Transfer,
      Overrun_Error,
      Framing_Error,
      Parity_Error,
      Transmit_Empty,
      Buffer_Empty,
      Buffer_Full);

   type UART is access all BBF.HRI.UART.UART_Peripheral;

   function UART0 return UART;

   procedure Initialize
     (Base                   : UART;
      Master_Clock_Frequency : Interfaces.Unsigned_32;
      Baud_Rate              : Interfaces.Unsigned_32);
   --  Configure UART with the specified parameters.
   --
   --  Note: The PMC and PIOs must be configured first.

   function Is_Transmitter_Ready (Base : UART) return Boolean;
   --  Check if data has been loaded in UART_THR and is waiting to be loaded in
   --  the Transmit Shift Register (TSR).

   function Is_Receiver_Ready (Base : UART) return Boolean;
   --  Check if data has been received and loaded in UART_RHR.

   procedure Write
     (Base    : UART;
      Data    : Interfaces.Unsigned_8;
      Success : out Boolean);
   --  Write to UART Transmit Holding Register. Before writing user should
   --  check if transmitter is ready (or empty).

   procedure Read
     (Base    : UART;
      Data    : out Interfaces.Unsigned_8;
      Success : out Boolean);
   --  Read from UART Receive Holding Register. Before reading user should
   --  check if receiver is ready.

   procedure Enable_Interrupt
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) with Inline;
   --  Enable given interrupt

   procedure Set_Receive_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : Interfaces.Unsigned_16) with Inline;
   --  Set buffer to receive data.

   procedure Set_Transmit_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : Interfaces.Unsigned_16) with Inline;
   --  Set buffer to transmit data.

   procedure Enable_Receive_Buffer (Base : UART) with Inline;
   --  Enable use of receive buffer.

   procedure Enable_Transmit_Buffer (Base : UART) with Inline;
   --  Enable use of transmit buffer.

end BBF.HPL.UART;
