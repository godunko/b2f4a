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
      --  Transmit buffer empty

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

      --  Trasmit holding register ready

      if BBF.HPL.TWI.Is_Transmit_Holding_Register_Ready (Status) then
         --  Send STOP condition and last byte of the data.

         BBF.HPL.TWI.Send_Stop_Condition (Self.Controller);

         --  Disable interrupt

         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);
      end if;

      --  Transmission completed

      if BBF.HPL.TWI.Is_Transmission_Completed (Status) then
         --  Disable transfer and all interrupts.

         BBF.HPL.TWI.Disable_Transmission_Buffer (Self.Controller);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
         Self.Disable_Error_Interrupts;

         if Self.Current.Operation /= None then
            if BBF.HPL.TWI.Is_Overrun_Error (Status)
              or BBF.HPL.TWI.Is_Not_Acknowledge (Status)
              or BBF.HPL.TWI.Is_Arbitration_Lost (Status)
            then
               if Self.Current.On_Error /= null then
                  Self.Current.On_Error (Self.Current.Closure);
               end if;

            else
               if Self.Current.On_Success /= null then
                  Self.Current.On_Success (Self.Current.Closure);
               end if;
            end if;

            Self.Current := (Operation => None);
         end if;

         --  Dequeue next operation and start it when available.

         if Operation_Queues.Dequeue (Self.Queue, Self.Current) then
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

               Self.Enable_Error_Interrupts;
               BBF.HPL.TWI.Enable_Interrupt
                 (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
               BBF.HPL.TWI.Enable_Interrupt
                 (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
               BBF.HPL.TWI.Enable_Transmission_Buffer (Self.Controller);
            end if;
         end if;
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
            Closure    => Closure));

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
