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
      Transmission_Buffer_Empty,
      Receive_Buffer_Full);

   type UART_Status is private;

   type UART is access all BBF.HRI.UART.UART_Peripheral;

   function UART0 return UART;

   procedure Initialize
     (Base                   : UART;
      Master_Clock_Frequency : Interfaces.Unsigned_32;
      Baud_Rate              : Interfaces.Unsigned_32);
   --  Configure UART with the specified parameters.
   --
   --  Note: The PMC and PIOs must be configured first.

   procedure Write
     (Base : UART;
      Data : BBF.Unsigned_8);
   --  Write to UART Transmit Holding Register. Before writing user should
   --  check if transmitter is ready (or empty).

   function Read (Base : UART) return BBF.Unsigned_8;
   --  Read from UART Receive Holding Register. Before reading user should
   --  check if receiver is ready.

   procedure Enable_Interrupt
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) with Inline;
   --  Enable given interrupt

   procedure Disable_Interrupt
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) with Inline;
   --  Disable given interrupt

   function Is_Interrupt_Enabled
     (Base      : UART;
      Interrupt : UART_Interrupt_Kind) return Boolean with Inline;
   --  Return True when given interrupt is enabled.

   procedure Set_Receive_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : BBF.Unsigned_16) with Inline;
   --  Set buffer to receive data.

   procedure Set_Transmission_Buffer
     (Base   : UART;
      Buffer : System.Address;
      Length : BBF.Unsigned_16) with Inline;
   --  Set buffer to transmit data.

   procedure Set_Transmission_Buffer
     (Base        : UART;
      Buffer      : System.Address;
      Length      : BBF.Unsigned_16;
      Next_Buffer : System.Address;
      Next_Length : BBF.Unsigned_16) with Inline;
   --  Set two buffers to transmit data.

   procedure Enable_Receive_Buffer (Base : UART) with Inline;
   --  Enable use of receive buffer.

   procedure Disable_Receive_Buffer (Base : UART) with Inline;
   --  Disable use of receive buffer.

   procedure Enable_Transmission_Buffer (Base : UART) with Inline;
   --  Enable use of transmit buffer.

   procedure Disable_Transmission_Buffer (Base : UART) with Inline;
   --  Disable use of transmit buffer.

   function Get_Status (Base : UART) return UART_Status with Inline;
   --  Returns status of the controller. Controller's status is cleared by
   --  read operation.

   function Is_Receiver_Ready (Status : UART_Status) return Boolean
     with Inline;
   --  Check if data has been received and loaded in UART_RHR.

   function Is_Transmitter_Ready (Status : UART_Status) return Boolean
     with Inline;
   --  Check if data has been loaded in UART_THR and is waiting to be loaded in
   --  the Transmit Shift Register (TSR).

   function Is_Transmission_Buffer_Empty (Status : UART_Status) return Boolean
     with Inline;
   --  Checks if transmiter buffer is empty (both current and next chunks has
   --  been processed).

private

   type UART_Status is new BBF.HRI.UART.UART_SR_Register;

end BBF.HPL.UART;
