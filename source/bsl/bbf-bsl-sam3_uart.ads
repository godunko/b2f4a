------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                           Board Support Layer                            --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023-2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Universal Asynchronous Receiver Transmitter (UART)

pragma Restrictions (No_Elaboration_Code);

with Ada.Synchronous_Task_Control;

with A0B.ARMv7M;
with A0B.ATSAM3X8E.PIO;

--  with BBF.BSL.SAM3_GPIO;
--  with BBF.HPL.PIO;
with BBF.HPL.UART;
with BBF.UART;

package BBF.BSL.SAM3_UART is

   --  type SAM3_UART_Driver is tagged;

   --  protected type SAM3_UART_Controller_Handler
   --    (Driver         : not null access SAM3_UART_Driver'Class;
   --     Interrupt      : A0B.ARMv7M.External_Interrupt_Number;
   --     Receive_Queue  : BBF.Unsigned_16;
   --     Transmit_Queue : BBF.Unsigned_16)
   --  is

   --     procedure Receive
   --       (Item : out BBF.Unsigned_8_Array_16;
   --        Size : out BBF.Unsigned_16);

   --     procedure Transmit (Item : BBF.Unsigned_8_Array_16);

   --  private


   --     --  procedure Interrupt_Handler with Attach_Handler => Interrupt;

   --  end SAM3_UART_Controller_Handler;

   type SAM3_UART_Driver
     (Controller     : not null BBF.HPL.UART.UART;
      Identifier     : A0B.ATSAM3X8E.Peripheral_Identifier;
      Interrupt      : A0B.ARMv7M.External_Interrupt_Number;
      RX             : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class;
      TX             : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class;
   --     RX             : not null access BBF.BSL.SAM3_GPIO.SAM3_GPIO_Pin'Class;
   --     RX_Function    : BBF.HPL.PIO.Peripheral_Function;
   --     TX             : not null access BBF.BSL.SAM3_GPIO.SAM3_GPIO_Pin'Class;
   --     TX_Function    : BBF.HPL.PIO.Peripheral_Function;
      Receive_Queue  : BBF.Unsigned_16;
      Transmit_Queue : BBF.Unsigned_16) is
     limited new BBF.UART.UART_Controller with
   record
      Receive : Ada.Synchronous_Task_Control.Suspension_Object;

      Receive_Buffer  : BBF.Unsigned_8_Array_16 (0 .. Receive_Queue);
      Receive_Head    : BBF.Unsigned_16 := 0;
      Receive_Tail    : BBF.Unsigned_16 := 0;
      Transmit_Buffer : BBF.Unsigned_8_Array_16 (0 .. Transmit_Queue);
      Transmit_Head   : BBF.Unsigned_16 := 0;
      Transmit_Tail   : BBF.Unsigned_16 := 0;
   --     Handler : SAM3_UART_Controller_Handler
   --                 (Driver         => SAM3_UART_Driver'Unchecked_Access,
   --                  Interrupt      => Interrupt,
   --                  Receive_Queue  => Receive_Queue,
   --                  Transmit_Queue => Transmit_Queue);
   end record;

   overriding procedure Initialize (Self : in out SAM3_UART_Driver);
   --  Initialize hardware:
   --   - setup peripheral clock
   --   - disable PDC data transfer
   --   - disable UART interrupts
   --   - configure PIO
   --   - configure UART
   --   - enable receiver interrupt

   overriding procedure Receive_Asynchronous
     (Self : in out SAM3_UART_Driver;
      Item : out BBF.Unsigned_8_Array_16;
      Size : out BBF.Unsigned_16);

   overriding procedure Transmit_Asynchronous
     (Self : in out SAM3_UART_Driver;
      Item : BBF.Unsigned_8_Array_16);

end BBF.BSL.SAM3_UART;
