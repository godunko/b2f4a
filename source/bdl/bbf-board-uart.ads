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

--  UART interface for Arduino Due/X board.

private with BBF.BSL.UART;
private with BBF.HPL.PIO;
private with BBF.HRI.UART;
with BBF.UART;

package BBF.Board.UART is

   pragma Preelaborate;

   UART : constant not null access BBF.UART.UART_Controller'Class;

private

   UART_Controller : aliased BBF.BSL.UART.SAM3_UART_Controller
     (Controller  => BBF.HRI.UART.UART_Periph'Access,
      Peripheral  => BBF.HPL.Universal_Asynchronous_Receiver_Transceiver,
      RX          => PIOA.Pin_08'Access,
      RX_Function => BBF.HPL.PIO.A,
      TX          => PIOA.Pin_09'Access,
      TX_Function => BBF.HPL.PIO.A);

   UART : constant not null access BBF.UART.UART_Controller'Class :=
     UART_Controller'Access;

end BBF.Board.UART;
