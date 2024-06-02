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

with A0B.ARMv7M.NVIC_Utilities; use A0B.ARMv7M.NVIC_Utilities;
with A0B.ATSAM3X8E.SVD.PMC;     use A0B.ATSAM3X8E.SVD.PMC;

with BBF.HPL.PMC;

package body BBF.BSL.SAM3_UART is

   CHIP_FREQ_CPU_MAX : constant := 84_000_000;
   --  XXX Should be computed based on current settings of the chip

   procedure UART_Handler
     with Export, Convention => C, External_Name => "UART_Handler";

   UART : access SAM3_UART_Driver'Class;

   ----------------
   -- Initialize --
   ----------------

   overriding procedure Initialize (Self : in out SAM3_UART_Driver) is
   begin
      UART := Self'Unchecked_Access;

      --  Set initial state of the suspension object.

      Ada.Synchronous_Task_Control.Set_False (Self.Receive);

      --  Enable peripheral clock

      PMC_Periph.PMC_PCER0.PID.Arr (Integer (Self.Identifier)) := True;

      --  Configure PIO function

      Self.RX.Configure_Alternative_Function (A0B.ATSAM3X8E.URXD);
      Self.TX.Configure_Alternative_Function (A0B.ATSAM3X8E.UTXD);

      --  Configure UART.

      BBF.HPL.UART.Initialize (Self.Controller, CHIP_FREQ_CPU_MAX, 115_200);

      --  Enable receiver interrupt

      BBF.HPL.UART.Enable_Interrupt
        (Self.Controller, BBF.HPL.UART.Receive_Ready);

      --  Enable NVIC interrupts

      Clear_Pending (Self.Interrupt);
      Enable_Interrupt (Self.Interrupt);
   end Initialize;

   --------------------------
   -- Receive_Asynchronous --
   --------------------------

   overriding procedure Receive_Asynchronous
     (Self : in out SAM3_UART_Driver;
      Item : out BBF.Unsigned_8_Array_16;
      Size : out BBF.Unsigned_16) is
   begin
      if Ada.Synchronous_Task_Control.Current_State (Self.Receive) then
         --  Copy data.
         --
         --  XXX Only single element buffer is supported.

         Item (Item'First) := Self.Receive_Buffer (Self.Receive_Buffer'First);
         Size              := 1;

         --  Lock receiver task on future access.

         Ada.Synchronous_Task_Control.Set_False (Self.Receive);

      else
         Size := 0;
      end if;
   end Receive_Asynchronous;

   ----------------------------------
   -- SAM3_UART_Controller_Handler --
   ----------------------------------

   --  protected body SAM3_UART_Controller_Handler is
   --
   --     -----------------------
   --     -- Interrupt_Handler --
   --     -----------------------
   --
   --     procedure Interrupt_Handler is
   --     end Interrupt_Handler;
   --
   --     -------------
   --     -- Receive --
   --     -------------
   --
   --     procedure Receive
   --       (Item : out BBF.Unsigned_8_Array_16;
   --        Size : out BBF.Unsigned_16) is
   --     begin
   --     end Receive;
   --
   --     --------------
   --     -- Transmit --
   --     --------------
   --
   --     procedure Transmit (Item : BBF.Unsigned_8_Array_16) is
   --     begin
   --     end Transmit;
   --
   --  end SAM3_UART_Controller_Handler;

   ---------------------------
   -- Transmit_Asynchronous --
   ---------------------------

   overriding procedure Transmit_Asynchronous
     (Self : in out SAM3_UART_Driver;
      Item : BBF.Unsigned_8_Array_16) is
   begin
      if Item'Length = 0 then
         return;
      end if;

      for B of Item loop
         --  Store bytes in the buffer.

         Self.Transmit_Buffer (Self.Transmit_Head) := B;
         Self.Transmit_Head := (@ + 1) mod Self.Transmit_Buffer'Length;

         --  Enable transmitter buffer empty interrupt. Future processing
         --  will be done in the interrupt handler.

         BBF.HPL.UART.Enable_Interrupt
           (Self.Controller, BBF.HPL.UART.Transmission_Buffer_Empty);
      end loop;
   end Transmit_Asynchronous;

   ------------------
   -- On_Interrupt --
   ------------------

   procedure On_Interrupt (Self : in out SAM3_UART_Driver'Class) is
      Status   : constant BBF.HPL.UART.UART_Status :=
        BBF.HPL.UART.Get_Status (UART.Controller);

      Length_C : Unsigned_16 := 0;
      Length_N : Unsigned_16 := 0;

   begin
      if BBF.HPL.UART.Is_Interrupt_Enabled
        (Self.Controller, BBF.HPL.UART.Receive_Ready)
        and then BBF.HPL.UART.Is_Receiver_Ready (Status)
      then
         --  Store data from the UART buffer into the buffer.

         --  XXX Only single element buffer is supported.

         Self.Receive_Buffer (Self.Receive_Head) :=
           BBF.HPL.UART.Read (Self.Controller);

         --  Unlock receiver task if any.

         Ada.Synchronous_Task_Control.Set_True (Self.Receive);
      end if;

      if BBF.HPL.UART.Is_Interrupt_Enabled
        (Self.Controller, BBF.HPL.UART.Transmission_Buffer_Empty)
        and then BBF.HPL.UART.Is_Transmission_Buffer_Empty (Status)
      then
         --  Disable interrupts and transmitter's PDC channel.

         BBF.HPL.UART.Disable_Interrupt
           (Self.Controller, BBF.HPL.UART.Transmission_Buffer_Empty);
         BBF.HPL.UART.Disable_Transmission_Buffer (Self.Controller);

         --  Compute size of packages to be transmitted

         if Self.Transmit_Tail < Self.Transmit_Head then
            --  No buffer wrapping, transmit data with single chunk.

            Length_C := Self.Transmit_Head - Self.Transmit_Tail;

         elsif Self.Transmit_Tail > Self.Transmit_Head then
            --  Buffer data is wrapped, use two chunks.

            Length_C := Self.Transmit_Buffer'Last - Self.Transmit_Tail + 1;
            Length_N := Self.Transmit_Head - Self.Transmit_Buffer'First;
         end if;

         --  Initiate transmission when buffer is not empty.

         if Length_C /= 0 then
            --  Configure PDC to transfer buffers.

            BBF.HPL.UART.Set_Transmission_Buffer
              (Base        => Self.Controller,
               Buffer      =>
                 Self.Transmit_Buffer (Self.Transmit_Tail)'Address,
               Length      => Length_C,
               Next_Buffer =>
                 Self.Transmit_Buffer (Self.Transmit_Buffer'First)'Address,
               Next_Length => Length_N);

            --  Enable interrupt and PDC.

            BBF.HPL.UART.Enable_Interrupt
              (Self.Controller, BBF.HPL.UART.Transmission_Buffer_Empty);
            BBF.HPL.UART.Enable_Transmission_Buffer (Self.Controller);

            --  Move tail to head.

            Self.Transmit_Tail := Self.Transmit_Head;
         end if;
      end if;
   end On_Interrupt;

   ------------------
   -- UART_Handler --
   ------------------

   procedure UART_Handler is
   begin
      UART.On_Interrupt;
   end UART_Handler;

end BBF.BSL.SAM3_UART;
