------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                           Board Support Layer                            --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with BBF.HPL.PMC;

package body BBF.BSL.SAM3_UART is

   CHIP_FREQ_CPU_MAX : constant := 84_000_000;
   --  XXX Should be computed based on current settings of the chip

   ----------------
   -- Initialize --
   ----------------

   overriding procedure Initialize (Self : in out SAM3_UART_Driver) is
   begin
      --  Set initial state of the suspension object.

      Ada.Synchronous_Task_Control.Set_False (Self.Receive);

      --  Enable peripheral clock

      BBF.HPL.PMC.Enable_Peripheral_Clock (Self.Peripheral);

      --  Configure PIO function

      Self.RX.Set_Peripheral (Self.RX_Function);
      Self.TX.Set_Peripheral (Self.TX_Function);

      --  Configure UART.

      BBF.HPL.UART.Initialize (Self.Controller, CHIP_FREQ_CPU_MAX, 115_200);

      --  Enable receiver interrupt

      BBF.HPL.UART.Enable_Interrupt
        (Self.Controller, BBF.HPL.UART.Receive_Ready);
   end Initialize;

   --------------------------
   -- Receive_Asynchronous --
   --------------------------

   overriding procedure Receive_Asynchronous
     (Self : in out SAM3_UART_Driver;
      Item : out BBF.Unsigned_8_Array_16;
      Size : out BBF.Unsigned_16) is
   begin
      Self.Handler.Receive (Item, Size);
   end Receive_Asynchronous;

   ----------------------------------
   -- SAM3_UART_Controller_Handler --
   ----------------------------------

   protected body SAM3_UART_Controller_Handler is

      -----------------------
      -- Interrupt_Handler --
      -----------------------

      procedure Interrupt_Handler is
         Status   : constant BBF.HPL.UART.UART_Status :=
           BBF.HPL.UART.Get_Status (Driver.Controller);

         Length_C : Unsigned_16 := 0;
         Length_N : Unsigned_16 := 0;

      begin
         if BBF.HPL.UART.Is_Interrupt_Enabled
              (Driver.Controller, BBF.HPL.UART.Receive_Ready)
           and then BBF.HPL.UART.Is_Receiver_Ready (Status)
         then
            --  Store data from the UART buffer into the buffer.

            --  XXX Only single element buffer is supported.

            Receive_Buffer (Receive_Head) :=
              BBF.HPL.UART.Read (Driver.Controller);

            --  Unlock receiver task if any.

            Ada.Synchronous_Task_Control.Set_True (Driver.Receive);
         end if;

         if BBF.HPL.UART.Is_Interrupt_Enabled
              (Driver.Controller, BBF.HPL.UART.Transmission_Buffer_Empty)
           and then BBF.HPL.UART.Is_Transmission_Buffer_Empty (Status)
         then
            --  Disable interrupts and transmitter's PDC channel.

            BBF.HPL.UART.Disable_Interrupt
              (Driver.Controller, BBF.HPL.UART.Transmission_Buffer_Empty);
            BBF.HPL.UART.Disable_Transmission_Buffer (Driver.Controller);

            --  Compute size of packages to be transmitted

            if Transmit_Tail < Transmit_Head then
               --  No buffer wrapping, transmit data with single chunk.

               Length_C := Transmit_Head - Transmit_Tail;

            elsif Transmit_Tail > Transmit_Head then
               --  Buffer data is wrapped, use two chunks.

               Length_C := Transmit_Buffer'Last - Transmit_Tail + 1;
               Length_N := Transmit_Head - Transmit_Buffer'First;
            end if;

            --  Initiate transmission when buffer is not empty.

            if Length_C /= 0 then
               --  Configure PDC to transfer buffers.

               BBF.HPL.UART.Set_Transmission_Buffer
                 (Base        => Driver.Controller,
                  Buffer      => Transmit_Buffer (Transmit_Tail)'Address,
                  Length      => Length_C,
                  Next_Buffer =>
                    Transmit_Buffer (Transmit_Buffer'First)'Address,
                  Next_Length => Length_N);

               --  Enable interrupt and PDC.

               BBF.HPL.UART.Enable_Interrupt
                 (Driver.Controller, BBF.HPL.UART.Transmission_Buffer_Empty);
               BBF.HPL.UART.Enable_Transmission_Buffer (Driver.Controller);

               --  Move tail to head.

               Transmit_Tail := Transmit_Head;
            end if;
         end if;
      end Interrupt_Handler;

      -------------
      -- Receive --
      -------------

      procedure Receive
        (Item : out BBF.Unsigned_8_Array_16;
         Size : out BBF.Unsigned_16) is
      begin
         if Ada.Synchronous_Task_Control.Current_State (Driver.Receive) then
            --  Copy data.
            --
            --  XXX Only single element buffer is supported.

            Item (Item'First) := Receive_Buffer (Receive_Buffer'First);
            Size              := 1;

            --  Lock receiver task on future access.

            Ada.Synchronous_Task_Control.Set_False (Driver.Receive);

         else
            Size := 0;
         end if;
      end Receive;

      --------------
      -- Transmit --
      --------------

      procedure Transmit (Item : BBF.Unsigned_8_Array_16) is
      begin
         if Item'Length = 0 then
            return;
         end if;

         for B of Item loop
            --  Store bytes in the buffer.

            Transmit_Buffer (Transmit_Head) := B;
            Transmit_Head := (@ + 1) mod Transmit_Buffer'Length;

            --  Enable transmitter buffer empty interrupt. Future processing
            --  will be done in the interrupt handler.

            BBF.HPL.UART.Enable_Interrupt
              (Driver.Controller, BBF.HPL.UART.Transmission_Buffer_Empty);
         end loop;
      end Transmit;

   end SAM3_UART_Controller_Handler;

   ---------------------------
   -- Transmit_Asynchronous --
   ---------------------------

   overriding procedure Transmit_Asynchronous
     (Self : in out SAM3_UART_Driver;
      Item : BBF.Unsigned_8_Array_16) is
   begin
      Self.Handler.Transmit (Item);
   end Transmit_Asynchronous;

end BBF.BSL.SAM3_UART;