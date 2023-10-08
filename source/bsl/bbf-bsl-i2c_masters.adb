------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                           Board Support Layer                            --
--                                                                          --
--                        Runtime Library Component                         --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2019-2023, Vadim Godunko <vgodunko@gmail.com>                --
-- All rights reserved.                                                     --
--                                                                          --
-- Redistribution and use in source and binary forms, with or without       --
-- modification, are permitted provided that the following conditions       --
-- are met:                                                                 --
--                                                                          --
--  * Redistributions of source code must retain the above copyright        --
--    notice, this list of conditions and the following disclaimer.         --
--                                                                          --
--  * Redistributions in binary form must reproduce the above copyright     --
--    notice, this list of conditions and the following disclaimer in the   --
--    documentation and/or other materials provided with the distribution.  --
--                                                                          --
--  * Neither the name of the Vadim Godunko, IE nor the names of its        --
--    contributors may be used to endorse or promote products derived from  --
--    this software without specific prior written permission.              --
--                                                                          --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT     --
-- HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   --
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED --
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   --
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     --
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       --
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             --
--                                                                          --
------------------------------------------------------------------------------

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
       of SAM3_I2C_Master_Controller_Access;
   --  Controller objects to be used by interrupt handlers.

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
      Self   : SAM3_I2C_Master_Controller_Access :=
        Controller (BBF.HPL.Two_Wire_Interface_0);
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
         --  Transmission completed.
         --
         --  XXX error need to be checked.

         --  Disable transfer and (all?) interrupts.

         BBF.HPL.TWI.Disable_Transmission_Buffer (Self.Controller);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
      end if;
   end TWI0_Handler;

   ------------------
   -- TWI1_Handler --
   ------------------

   procedure TWI1_Handler is
   begin
      null;
   end TWI1_Handler;

   ------------------------
   -- Write_Asynchronous --
   ------------------------

   procedure Write_Asynchronous
     (Self             : in out SAM3_I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : System.Address;
      Length           : Interfaces.Unsigned_16)
   is
      use type Interfaces.Unsigned_16;

   begin
      --  XXX Check transfer is in progress!

      if Length = 1 then
         raise Program_Error with "1 byte I2C write not implemented";

      else
         BBF.HPL.TWI.Disable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Holding_Register_Ready);
         BBF.HPL.TWI.Set_Transmission_Buffer
           (Self.Controller, Data, Length);

         --  Set write mode, slave address and 3 internal address byte lengths

         Self.Controller.MMR := (others => <>);
         Self.Controller.MMR :=
           (DADR   => BBF.HRI.TWI.TWI0_MMR_DADR_Field (Address),
            MREAD  => False,
            IADRSZ => BBF.HRI.TWI.Val_1_Byte,
            others => <>);

         --  Set internal address for remote chip

         Self.Controller.IADR := (others => <>);
         Self.Controller.IADR :=
           (IADR   => BBF.HRI.TWI.TWI0_IADR_IADR_Field (Internal_Address),
            others => <>);

         --  Enable interrupts and transfer

         BBF.HPL.TWI.Enable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmit_Buffer_Empty);
         BBF.HPL.TWI.Enable_Interrupt
           (Self.Controller, BBF.HPL.TWI.Transmission_Completed);
         BBF.HPL.TWI.Enable_Transmission_Buffer (Self.Controller);
      end if;
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
