------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                        Hardware Abstraction Layer                        --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Universal Asynchronous Receiver Transmitter

pragma Restrictions (No_Elaboration_Code);

package BBF.UART is

   pragma Pure;

   type UART_Controller is limited interface;

   procedure Initialize (Self : in out UART_Controller) is abstract;
   --  XXX Initialization is implementation dependend subprogram, must be 
   --  moved outside of the abstract API.

   procedure Receive_Asynchronous
     (Self : in out UART_Controller;
      Item : out BBF.Unsigned_8_Array_16;
      Size : out BBF.Unsigned_16) is abstract;
   --  Receive data asynchronously.

   procedure Transmit_Asynchronous
     (Self : in out UART_Controller;
      Item : BBF.Unsigned_8_Array_16) is abstract;
   --  Transmit data asynchronously.
   --
   --  XXX Should report size of buffered information?
   --  XXX Should have a flag to transmit whole block on nothing?

end BBF.UART;
