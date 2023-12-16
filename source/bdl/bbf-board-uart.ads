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

--  UART driver of Arduino Due/X board.

pragma Restrictions (No_Elaboration_Code);

private with Ada.Interrupts.Names;

private with BBF.BSL.SAM3_UART;
private with BBF.HPL.PIO;
private with BBF.HRI.UART;
with BBF.UART;

package BBF.Board.UART is

   type UART_Driver
     (Receive_Queue  : BBF.Unsigned_16;
      Transmit_Queue : BBF.Unsigned_16) is
        limited new BBF.UART.UART_Controller with private;

private

   type UART_Driver
     (Receive_Queue  : BBF.Unsigned_16;
      Transmit_Queue : BBF.Unsigned_16) is
        limited new BBF.BSL.SAM3_UART.SAM3_UART_Driver
                      (Controller     => BBF.HRI.UART.UART_Periph'Access,
                       Peripheral     =>
                         BBF.HPL.Universal_Asynchronous_Receiver_Transceiver,
                       Interrupt      => Ada.Interrupts.Names.UART_Interrupt,
                       RX             => PIOA.Pin_08'Access,
                       RX_Function    => BBF.HPL.PIO.A,
                       TX             => PIOA.Pin_09'Access,
                       TX_Function    => BBF.HPL.PIO.A,
                       Receive_Queue  => Receive_Queue,
                       Transmit_Queue => Transmit_Queue)
        with null record;

end BBF.Board.UART;
