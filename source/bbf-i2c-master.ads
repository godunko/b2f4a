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

--  Master mode of I2C bus

pragma Restrictions (No_Elaboration_Code);

with Interfaces;
with System;

package BBF.I2C.Master is

   pragma Preelaborate;

   type I2C_Master_Controller is limited interface;

   not overriding procedure Read_Asynchronous
     (Self       : in out I2C_Master_Controller;
      Device     : BBF.I2C.Device_Address;
      Register   : BBF.I2C.Internal_Address_8;
      Data       : System.Address;
      Length     : BBF.Unsigned_16;
      On_Success : BBF.Callback;
      On_Error   : BBF.Callback;
      Closure    : System.Address;
      Success    : in out Boolean) is abstract;
   --  Initiates asynchronous read operation. Given buffer should be available
   --  till operation ends.
   --
   --  @param Self        I2C bus controller
   --  @param Device      Device address on the bus
   --  @param Register    Internal address of the device
   --  @param Data        Pointer to the buffer to be receive data
   --  @param Length      Length of the data
   --  @param On_Success
   --    Callback to report successful completion of the operation
   --  @param On_Error
   --    Callback to report error condition that stops operation
   --  @param Closure     Closure data for callbacks
   --  @param Success
   --    True when operation has been queued successfully, and False overwise.
   --    Callbacks are not called when subprogram sets parameter to False.

   not overriding procedure Write_Asynchronous
     (Self       : in out I2C_Master_Controller;
      Device     : BBF.I2C.Device_Address;
      Register   : BBF.I2C.Internal_Address_8;
      Data       : System.Address;
      Length     : BBF.Unsigned_16;
      On_Success : BBF.Callback;
      On_Error   : BBF.Callback;
      Closure    : System.Address;
      Success    : in out Boolean) is abstract;
   --  Initiates asynchronous write operation. Given buffer should be available
   --  till operation ends.
   --
   --  @param Self        I2C bus controller
   --  @param Device      Device address on the bus
   --  @param Register    Internal address of the device
   --  @param Data        Pointer to the data to be transmitted
   --  @param Length      Length of the data
   --  @param On_Success
   --    Callback to report successful completion of the operation
   --  @param On_Error
   --    Callback to report error condition that stops operation
   --  @param Closure     Closure data for callbacks
   --  @param Success
   --    True when operation has been queued successfully, and False overwise.
   --    Callbacks are not called when subprogram sets parameter to False.

   not overriding function Probe
     (Self    : in out I2C_Master_Controller;
      Address : BBF.I2C.Device_Address) return Boolean is abstract;
   --  Test if a chip answers a given I2C address.

   not overriding procedure Write_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : BBF.Unsigned_8;
      Success          : out Boolean) is abstract;
   --  Write multiple bytes to a I2C slave device.
   --
   --  This Subprogram will NOT return until all data has been written or error
   --  occurred.

   not overriding procedure Write_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : BBF.Unsigned_8_Array_16;
      Success          : out Boolean) is abstract;
   --  Write multiple bytes to a I2C slave device.
   --
   --  This Subprogram will NOT return until all data has been written or error
   --  occurred.

   not overriding procedure Read_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out BBF.Unsigned_8;
      Success          : out Boolean) is abstract;
   --  Read multiple bytes from a TWI compatible slave device.
   --
   --  This subprogram will NOT return until all data has been read or error
   --  occurs.

   not overriding procedure Read_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out BBF.Unsigned_8_Array_16;
      Success          : out Boolean) is abstract;
   --  Read multiple bytes from a TWI compatible slave device.
   --
   --  This subprogram will NOT return until all data has been read or error
   --  occurs.

end BBF.I2C.Master;
