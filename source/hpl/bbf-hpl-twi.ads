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

--  Two-wire Interface (TWI)

pragma Restrictions (No_Elaboration_Code);

with BBF.HRI.TWI;
with BBF.I2C;

package BBF.HPL.TWI is

   pragma Preelaborate;

   type TWI_Interrupt is
     (Transmission_Completed,
      Receive_Holding_Register_Ready,
      Transmit_Holding_Register_Ready,
      Slave_Access,
      General_Call_Access,
      Overrun_Error,
      Not_Acknowledge,
      Arbitration_Lost,
      Clock_Wait_State,
      End_Of_Slave_Access,
      End_Of_Receive_Buffer,
      End_Of_Transmit_Buffer,
      Receive_Buffer_Full,
      Transmit_Buffer_Empty);

   type TWI_Status is private;
   --  Holder of the value of the SR register. Read operation of the SR changes
   --  controller status and next read operation might return modified value.
   --  All controller's status check operations use this type as argument to
   --  force proper usage (caller read SR once and analyze it).

   type TWI is access all BBF.HRI.TWI.TWI_Peripheral;

   function TWI0 return TWI;
   function TWI1 return TWI;

   type Unsigned_8_Array is array (Positive range <>) of Interfaces.Unsigned_8;

   procedure Initialize_Master
     (Self                 : TWI;
      Main_Clock_Frequency : Interfaces.Unsigned_32;
      Speed                : Interfaces.Unsigned_32);
   --  Initialize TWI master mode.

   procedure Enable_Interrupt
     (Self      : TWI;
      Interrupt : TWI_Interrupt) with Inline;
   --  Enable given interrupt

   procedure Disable_Interrupt
     (Self      : TWI;
      Interrupt : TWI_Interrupt) with Inline;
   --  Disable given interrupt

   procedure Disable_Interrupts (Self : TWI) with Inline;
   -- Disable all interrupts

   procedure Set_Receive_Buffer
     (Self   : TWI;
      Buffer : System.Address;
      Length : Interfaces.Unsigned_16) with Inline;
   --  Set buffer to receive data.

   procedure Set_Transmission_Buffer
     (Self   : TWI;
      Buffer : System.Address;
      Length : Interfaces.Unsigned_16) with Inline;
   --  Set buffer to transmit data.

   procedure Enable_Receive_Buffer (Self : TWI) with Inline;
   --  Enable use of receive buffer.

   procedure Disable_Receive_Buffer (Self : TWI) with Inline;
   --  Disable use of receive buffer.

   procedure Enable_Transmission_Buffer (Self : TWI) with Inline;
   --  Enable use of transmit buffer.

   procedure Disable_Transmission_Buffer (Self : TWI) with Inline;
   --  Disable use of transmit buffer.

   procedure Send_Stop_Condition (Self : TWI) with Inline;
   --  Send STOP condition after sending of current byte

   function Get_Status (Self : TWI) return TWI_Status with Inline;
   --  Reads current status of the controller and returns it.

   function Get_Masked_Status (Self : TWI) return TWI_Status with Inline;
   --  Reads current status of the controller, apply interrupt mask and returns
   --  result. Useful inside interrupt handlers.

   function Is_Transmission_Completed (Status : TWI_Status) return Boolean
     with Inline;

   function Is_Receive_Holding_Register_Ready
     (Status : TWI_Status) return Boolean with Inline;

   function Is_Transmit_Holding_Register_Ready
     (Status : TWI_Status) return Boolean with Inline;

   function Is_Overrun_Error (Status : TWI_Status) return Boolean
     with Inline;

   function Is_Not_Acknowledge (Status : TWI_Status) return Boolean
     with Inline;

   function Is_Arbitration_Lost (Status : TWI_Status) return Boolean
     with Inline;

   function Is_End_Of_Receive_Buffer (Status : TWI_Status) return Boolean
     with Inline;

   function Is_Receive_Buffer_Full (Status : TWI_Status) return Boolean
     with Inline;

   function Is_Transmit_Buffer_Empty (Status : TWI_Status) return Boolean
     with Inline;

   -----------------------------------
   --  Obsolete subprograms section --
   -----------------------------------

   function Probe
     (Self    : TWI;
      Address : BBF.I2C.Device_Address) return Boolean;
   --  Test if a chip answers a given I2C address.

   procedure Master_Write_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : Interfaces.Unsigned_8;
      Success          : out Boolean);
   --  Write multiple bytes to a TWI compatible slave device.
   --
   --  This Subprogram will NOT return until all data has been written or error
   --  occurred.

   procedure Master_Write_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : Unsigned_8_Array;
      Success          : out Boolean);
   --  Write multiple bytes to a TWI compatible slave device.
   --
   --  This Subprogram will NOT return until all data has been written or error
   --  occurred.

   procedure Master_Read_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out Interfaces.Unsigned_8;
      Success          : out Boolean);
   --  Read multiple bytes from a TWI compatible slave device.
   --
   --  This subprogram will NOT return until all data has been read or error
   --  occurs.

   procedure Master_Read_Synchronous
     (Self             : TWI;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out Unsigned_8_Array;
      Success          : out Boolean);
   --  Read multiple bytes from a TWI compatible slave device.
   --
   --  This subprogram will NOT return until all data has been read or error
   --  occurs.

private

   type TWI_Status is new BBF.HRI.TWI.TWI0_SR_Register;

   function Is_Arbitration_Lost (Status : TWI_Status) return Boolean is
     (Status.ARBLST);
   function Is_End_Of_Receive_Buffer (Status : TWI_Status) return Boolean is
     (Status.ENDRX);
   function Is_Not_Acknowledge (Status : TWI_Status) return Boolean is
     (Status.NACK);
   function Is_Overrun_Error (Status : TWI_Status) return Boolean is
     (Status.OVRE);
   function Is_Receive_Buffer_Full (Status : TWI_Status) return Boolean is
     (Status.RXBUFF);
   function Is_Receive_Holding_Register_Ready
     (Status : TWI_Status) return Boolean is (Status.RXRDY);
   function Is_Transmission_Completed (Status : TWI_Status) return Boolean is
     (Status.TXCOMP);
   function Is_Transmit_Holding_Register_Ready
     (Status : TWI_Status) return Boolean is (Status.TXRDY);
   function Is_Transmit_Buffer_Empty (Status : TWI_Status) return Boolean is
     (Status.TXBUFE);

end BBF.HPL.TWI;
