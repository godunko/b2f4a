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

with System.Storage_Elements;

with BBF.BSL.Clocks;
with BBF.HPL.NVIC;
with BBF.HPL.PMC;
with BBF.HPL.TWI;

package body BBF.BSL.I2C_Masters is

   procedure TWI0_Handler
     with Export,
          Convention    => C,
          External_Name => "TWI0_Handler";
   --  TWI0 interrupt handler

   procedure TWI1_Handler
     with Export,
          Convention    => C,
          External_Name => "TWI1_Handler";
   --  TWI1 interrupt handler

   type SAM3_I2C_Master_Controller_Access is
     access all SAM3_I2C_Master_Controller'Class;

   Controller :
     array (BBF.HPL.Peripheral_Identifier
            range BBF.HPL.Two_Wire_Interface_0 .. BBF.HPL.Two_Wire_Interface_1)
       of SAM3_I2C_Master_Controller_Access := (others => null);
   --  Controller objects to be used by interrupt handlers.

   procedure Enable_Error_Interrupts
     (Self : in out SAM3_I2C_Master_Controller'Class);

   procedure Disable_Error_Interrupts
     (Self : in out SAM3_I2C_Master_Controller'Class);

   procedure On_Interrupt (Self : in out SAM3_I2C_Master_Controller'Class);

   ------------------------------
   -- Disable_Error_Interrupts --
   ------------------------------

   procedure Disable_Error_Interrupts
     (Self : in out SAM3_I2C_Master_Controller'Class) is
   begin
      BBF.HPL.TWI.Disable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Overrun_Error);
      BBF.HPL.TWI.Disable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Not_Acknowledge);
      BBF.HPL.TWI.Disable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Arbitration_Lost);
   end Disable_Error_Interrupts;

   -----------------------------
   -- Enable_Error_Interrupts --
   -----------------------------

   procedure Enable_Error_Interrupts
     (Self : in out SAM3_I2C_Master_Controller'Class) is
   begin
      BBF.HPL.TWI.Enable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Overrun_Error);
      BBF.HPL.TWI.Enable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Not_Acknowledge);
      BBF.HPL.TWI.Enable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Arbitration_Lost);
   end Enable_Error_Interrupts;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Self : in out SAM3_I2C_Master_Controller) is
   begin
      --  Enable peripheral clock

      BBF.HPL.PMC.Enable_Peripheral_Clock (Self.Peripheral);

      --  Disable transfers and interrupts

      BBF.HPL.TWI.Disable_Receive_Buffer (Self.Controller);
      BBF.HPL.TWI.Disable_Transmission_Buffer (Self.Controller);
      BBF.HPL.TWI.Disable_Interrupts (Self.Controller);

      --  Configure PIO pins

      Self.SCL.Set_Peripheral (Self.SCL_Function);
      Self.SDA.Set_Peripheral (Self.SDA_Function);

      --  Initialize and configure TWI controller in master mode

      BBF.HPL.TWI.Initialize_Master
        (Self.Controller, BBF.BSL.Clocks.Main_Clock_Frequency, 384_000);

      --  Set controller to be used by interrupt handler.

      Controller (Self.Peripheral) := Self'Unchecked_Access;

      --  Enable NVIC interrupts

      BBF.HPL.NVIC.Enable_Interrupt (Self.Peripheral);
   end Initialize;

   ------------------
   -- On_Interrupt --
   ------------------

   procedure On_Interrupt (Self : in out SAM3_I2C_Master_Controller'Class) is

      use type Interfaces.Unsigned_16;

      Status : constant BBF.HPL.TWI.TWI_Status :=
        BBF.HPL.TWI.Get_Masked_Status (Self.Controller);

   begin

      ---------------------------
      --  Receive Buffer Full  --
      ---------------------------

      if BBF.HPL.TWI.Is_Receive_Buffer_Full (Status) then
         --  Disable transfer and interrupt.

         BBF.HPL.TWI.Disable_Receive_Buffer (Self.Controller);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Receive_Buffer_Full);

         --  Enable Receive_Holding_Register_Ready interrupt to send STOP
         --  condition.

         BBF.HPL.TWI.Enable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Receive_Holding_Register_Ready);
      end if;

      --------------------------------------
      --  Receive Holding Register Ready  --
      --------------------------------------

      if BBF.HPL.TWI.Is_Receive_Holding_Register_Ready (Status) then
         declare
            Data : BBF.I2C.Unsigned_8_Array (1 .. Integer (Self.Current.Length))
              with Address => Self.Current.Data;

         begin
            if Self.Current.Stop then
               --  Store last byte

               Data (Data'Last) :=
                 Interfaces.Unsigned_8 (Self.Controller.RHR.RXDATA);

               --  Disable interrupt and wait till transmission completed

               BBF.HPL.TWI.Disable_Interrupt
                 (Self.Controller, BBF.HPL.TWI.Receive_Holding_Register_Ready);

            else
               --  Store last but one byte

               Data (Data'Last - 1) :=
                 Interfaces.Unsigned_8 (Self.Controller.RHR.RXDATA);

               --  Send STOP condition.

               BBF.HPL.TWI.Send_Stop_Condition (Self.Controller);
               Self.Current.Stop := True;
            end if;
         end;
      end if;

      -----------------------------
      --  Transmit Buffer Empty  --
      -----------------------------

      if BBF.HPL.TWI.Is_Transmit_Buffer_Empty (Status) then
         --  Transfer almost completed, enable Transmit Holding Register Ready
         --  interrupt to send stop condition.

         BBF.HPL.TWI.Enable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);

         --  Disable transfer and interrupt.

         BBF.HPL.TWI.Disable_Transmission_Buffer (Self.Controller);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
      end if;

      --------------------------------------
      --  Trasmit Holding Register Ready  --
      --------------------------------------

      if BBF.HPL.TWI.Is_Transmit_Holding_Register_Ready (Status) then
         --  Send STOP condition and last byte of the data.

         BBF.HPL.TWI.Send_Stop_Condition (Self.Controller);

         --  Disable interrupt

         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);
      end if;

      ------------------------------
      --  Transmission Completed  --
      ------------------------------

      if BBF.HPL.TWI.Is_Transmission_Completed (Status) then
         --  Disable transfers and all interrupts.

         BBF.HPL.TWI.Disable_Receive_Buffer (Self.Controller);
         BBF.HPL.TWI.Disable_Transmission_Buffer (Self.Controller);

         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Receive_Buffer_Full);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Receive_Holding_Register_Ready);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
         Self.Disable_Error_Interrupts;

         if Self.Current.Operation /= None then
            if BBF.HPL.TWI.Is_Overrun_Error (Status)
              or BBF.HPL.TWI.Is_Not_Acknowledge (Status)
              or (BBF.HPL.TWI.Is_Arbitration_Lost (Status)
                    and Self.Current.Retry = 0)
            then
               if Self.Current.On_Error /= null then
                  Self.Current.On_Error (Self.Current.Closure);
               end if;

               Self.Current := (Operation => None);

            elsif BBF.HPL.TWI.Is_Not_Acknowledge (Status) then
               --  Arbitration lost, try to retry operation for few times.

               Self.Current.Retry := @ - 1;
               Self.Current.Stop  := False;

            else
               if Self.Current.On_Success /= null then
                  Self.Current.On_Success (Self.Current.Closure);
               end if;

               Self.Current := (Operation => None);
            end if;
         end if;

         --  When there is no operation in progress, attempt to dequeue next
         --  one

         if Self.Current.Operation = None then
            if not Operation_Queues.Dequeue (Self.Queue, Self.Current) then
               return;
            end if;
         end if;

         --  Initiate operation.

         case Self.Current.Operation is
            when Read =>
               if Self.Current.Length >= 2 then
                  --  Last two bytes are send by the interrupt handler on
                  --  Receive Holding Register Ready interrupt.

                  BBF.HPL.TWI.Set_Receive_Buffer
                    (Self.Controller,
                     Self.Current.Data,
                     Self.Current.Length - 2);
               end if;

               --  Set read mode, slave address and 3 internal address byte
               --  lengths

               Self.Controller.MMR := (others => <>);
               Self.Controller.MMR :=
                 (DADR   =>
                     BBF.HRI.TWI.TWI0_MMR_DADR_Field (Self.Current.Device),
                  MREAD  => True,
                  IADRSZ => BBF.HRI.TWI.Val_1_Byte,
                  others => <>);

               --  Set internal address for remote chip

               Self.Controller.IADR := (others => <>);
               Self.Controller.IADR :=
                 (IADR   =>
                     BBF.HRI.TWI.TWI0_IADR_IADR_Field (Self.Current.Register),
                  others => <>);

               --  Enable transfer and interrupts

               if Self.Current.Length >= 2 then
                  BBF.HPL.TWI.Enable_Receive_Buffer (Self.Controller);
                  BBF.HPL.TWI.Enable_Interrupt
                    (Self.Controller, BBF.HPL.TWI.Receive_Buffer_Full);

               else
                  BBF.HPL.TWI.Enable_Interrupt
                    (Self.Controller,
                     BBF.HPL.TWI.Receive_Holding_Register_Ready);
               end if;

               Self.Enable_Error_Interrupts;
               BBF.HPL.TWI.Enable_Interrupt
                 (Self.Controller, BBF.HPL.TWI.Transmission_Completed);

               --  Send a START condition

               if Self.Current.Length = 1 then
                  --  Send both START and STOP conditions.

                  Self.Controller.CR :=
                    (START => True, STOP => True, others => <>);
                  Self.Current.Stop  := True;

               else
                  --  Otherwise, send only START condition.

                  Self.Controller.CR := (START => True, others => <>);
               end if;

            when Write =>
               if Self.Current.Length = 1 then
                  raise Program_Error with "1 byte I2C write not implemented";

               else
                  BBF.HPL.TWI.Set_Transmission_Buffer
                    (Self.Controller, Self.Current.Data, Self.Current.Length);

                  --  Set write mode, slave address and 3 internal address byte
                  --  lengths

                  Self.Controller.MMR := (others => <>);
                  Self.Controller.MMR :=
                    (DADR   =>
                       BBF.HRI.TWI.TWI0_MMR_DADR_Field (Self.Current.Device),
                     MREAD  => False,
                     IADRSZ => BBF.HRI.TWI.Val_1_Byte,
                     others => <>);

                  --  Set internal address for remote chip

                  Self.Controller.IADR := (others => <>);
                  Self.Controller.IADR :=
                    (IADR   =>
                       BBF.HRI.TWI.TWI0_IADR_IADR_Field (Self.Current.Register),
                     others => <>);

                  --  Enable interrupts and transfer

                  BBF.HPL.TWI.Enable_Transmission_Buffer (Self.Controller);
                  Self.Enable_Error_Interrupts;
                  BBF.HPL.TWI.Enable_Interrupt
                    (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
                  BBF.HPL.TWI.Enable_Interrupt
                    (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
               end if;

            when None =>
               raise Program_Error;
         end case;
      end if;
   end On_Interrupt;

   -----------
   -- Probe --
   -----------

   overriding function Probe
    (Self    : in out SAM3_I2C_Master_Controller;
     Address : BBF.I2C.Device_Address) return Boolean is
   begin
      return BBF.HPL.TWI.Probe (Self.Controller, Address);
   end Probe;

   -----------------------
   -- Read_Asynchronous --
   -----------------------

   overriding procedure Read_Asynchronous
     (Self       : in out SAM3_I2C_Master_Controller;
      Device     : BBF.I2C.Device_Address;
      Register   : BBF.I2C.Internal_Address_8;
      Data       : System.Address;
      Length     : Interfaces.Unsigned_16;
      On_Success : BBF.Callback;
      On_Error   : BBF.Callback;
      Closure    : System.Address;
      Success    : in out Boolean) is
   begin
      if not Success then
         return;
      end if;

      --  Enqueue opetation

      Success :=
        Operation_Queues.Enqueue
          (Self.Queue,
           (Operation  => Read,
            Device     => Device,
            Register   => Register,
            Data       => Data,
            Length     => Length,
            On_Success => On_Success,
            On_Error   => On_Error,
            Closure    => Closure,
            Stop       => False,
            Retry      => 3));

      if not Success then
         return;
      end if;

      --  Enable Transmission_Completed interrupt to start operation if there
      --  is no active operation.

      BBF.HPL.TWI.Enable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
   end Read_Asynchronous;

   ----------------------
   -- Read_Synchronous --
   ----------------------

   overriding procedure Read_Synchronous
     (Self             : in out SAM3_I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out Interfaces.Unsigned_8;
      Success          : out Boolean) is
   begin
      BBF.HPL.TWI.Master_Read_Synchronous
       (Self.Controller, Address, Internal_Address, Data, Success);
   end Read_Synchronous;

   ----------------------
   -- Read_Synchronous --
   ----------------------

   overriding procedure Read_Synchronous
     (Self             : in out SAM3_I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out BBF.I2C.Unsigned_8_Array;
      Success          : out Boolean) is
   begin
      BBF.HPL.TWI.Master_Read_Synchronous
       (Self.Controller,
        Address,
        Internal_Address,
        BBF.HPL.TWI.Unsigned_8_Array (Data),
        Success);
   end Read_Synchronous;

   ------------------
   -- TWI0_Handler --
   ------------------

   procedure TWI0_Handler is
   begin
      Controller (BBF.HPL.Two_Wire_Interface_0).On_Interrupt;
   end TWI0_Handler;

   ------------------
   -- TWI1_Handler --
   ------------------

   procedure TWI1_Handler is
   begin
      Controller (BBF.HPL.Two_Wire_Interface_1).On_Interrupt;
   end TWI1_Handler;

   ------------------------
   -- Write_Asynchronous --
   ------------------------

   procedure Write_Asynchronous
     (Self       : in out SAM3_I2C_Master_Controller;
      Device     : BBF.I2C.Device_Address;
      Register   : BBF.I2C.Internal_Address_8;
      Data       : System.Address;
      Length     : Interfaces.Unsigned_16;
      On_Success : BBF.Callback;
      On_Error   : BBF.Callback;
      Closure    : System.Address;
      Success    : in out Boolean) is
   begin
      if not Success then
         return;
      end if;

      --  Enqueue opetation

      Success :=
        Operation_Queues.Enqueue
          (Self.Queue,
           (Operation  => Write,
            Device     => Device,
            Register   => Register,
            Data       => Data,
            Length     => Length,
            On_Success => On_Success,
            On_Error   => On_Error,
            Closure    => Closure,
            Stop       => False,
            Retry      => 3));

      if not Success then
         return;
      end if;

      --  Enable Transmission_Completed interrupt to start operation if there
      --  is no active operation.

      BBF.HPL.TWI.Enable_Interrupt
        (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
   end Write_Asynchronous;

   -----------------------
   -- Write_Synchronous --
   -----------------------

   overriding procedure Write_Synchronous
     (Self             : in out SAM3_I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : Interfaces.Unsigned_8;
      Success          : out Boolean) is
   begin
      BBF.HPL.TWI.Master_Write_Synchronous
       (Self.Controller, Address, Internal_Address, Data, Success);
   end Write_Synchronous;

   -----------------------
   -- Write_Synchronous --
   -----------------------

   overriding procedure Write_Synchronous
     (Self             : in out SAM3_I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : BBF.I2C.Unsigned_8_Array;
      Success          : out Boolean) is
   begin
      BBF.HPL.TWI.Master_Write_Synchronous
       (Self.Controller,
        Address,
        Internal_Address,
        BBF.HPL.TWI.Unsigned_8_Array (Data),
        Success);
   end Write_Synchronous;

end BBF.BSL.I2C_Masters;
