------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                        Hardware Abstraction Layer                        --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  UART driver of Arduino Due/X board.

pragma Restrictions (No_Elaboration_Code);

private with A0B.ATSAM3X8E.PIO.PIOA;

private with BBF.BSL.SAM3_UART;
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
                       Identifier     =>
                         A0B.ATSAM3X8E
                           .Universal_Asynchronous_Receiver_Transceiver,
                       Interrupt      =>
                         A0B.ATSAM3X8E
                           .Universal_Asynchronous_Receiver_Transceiver,
                       RX             => A0B.ATSAM3X8E.PIO.PIOA.PA8'Access,
                       TX             => A0B.ATSAM3X8E.PIO.PIOA.PA9'Access,
                       Receive_Queue  => Receive_Queue,
                       Transmit_Queue => Transmit_Queue)
        with null record;

end BBF.Board.UART;
