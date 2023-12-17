------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                           Board Support Layer                            --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  I2C Bus Master on top of TWI controller

pragma Restrictions (No_Elaboration_Code);

with Ada.Interrupts;
with Interfaces;

private with BBF.ADT.Generic_MPMC_Bounded_Queues;
with BBF.BSL.SAM3_GPIO;
with BBF.HPL.PIO;
with BBF.HRI.TWI;
with BBF.I2C.Master;

package BBF.BSL.SAM3_I2C_Masters is

   type SAM3_I2C_Master_Controller
     (Controller   : not null access BBF.HRI.TWI.TWI_Peripheral;
      Peripheral   : BBF.HPL.Peripheral_Identifier;
      Interrupt    : Ada.Interrupts.Interrupt_ID;
      SCL          : not null access BBF.BSL.SAM3_GPIO.SAM3_GPIO_Pin'Class;
      SCL_Function : BBF.HPL.PIO.Peripheral_Function;
      SDA          : not null access BBF.BSL.SAM3_GPIO.SAM3_GPIO_Pin'Class;
      SDA_Function : BBF.HPL.PIO.Peripheral_Function) is
        limited new BBF.I2C.Master.I2C_Master_Controller
          with private with Preelaborable_Initialization;

   procedure Initialize (Self : in out SAM3_I2C_Master_Controller);

   overriding function Probe
    (Self    : in out SAM3_I2C_Master_Controller;
     Address : BBF.I2C.Device_Address) return Boolean;

   overriding procedure Write_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : BBF.I2C.Internal_Address_8;
     Data             : BBF.Unsigned_8;
     Success          : out Boolean);

   overriding procedure Write_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : BBF.I2C.Internal_Address_8;
     Data             : BBF.Unsigned_8_Array_16;
     Success          : out Boolean);

   overriding procedure Read_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : BBF.I2C.Internal_Address_8;
     Data             : out BBF.Unsigned_8;
     Success          : out Boolean);

   overriding procedure Read_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : BBF.I2C.Internal_Address_8;
     Data             : out BBF.Unsigned_8_Array_16;
     Success          : out Boolean);

private

   type Operation is (None, Read, Write);

   type Operation_Record
     (Operation : BBF.BSL.SAM3_I2C_Masters.Operation := None) is
   record
      case Operation is
         when None =>
            null;

         when Read | Write =>
            Device     : BBF.I2C.Device_Address;
            Register   : BBF.I2C.Internal_Address_8;
            Data       : System.Address;
            Length     : BBF.Unsigned_16;
            On_Success : BBF.Callback;
            On_Error   : BBF.Callback;
            Closure    : System.Address;
            Stop       : Boolean;
            --  STOP condition has been send
            Retry      : Natural;
            --  Retry counter to recover from Arbitration Lost error
      end case;
   end record;

   package Operation_Queues is
     new BBF.ADT.Generic_MPMC_Bounded_Queues (Operation_Record);

   protected type SAM3_TWI_Handler
     (Driver    : not null access SAM3_I2C_Master_Controller'Class;
      Interrupt : Ada.Interrupts.Interrupt_ID)
   is

   private

      procedure Interrupt_Handler with Attach_Handler => Interrupt;

   end SAM3_TWI_Handler;

   type SAM3_I2C_Master_Controller
     (Controller   : not null access BBF.HRI.TWI.TWI_Peripheral;
      Peripheral   : BBF.HPL.Peripheral_Identifier;
      Interrupt    : Ada.Interrupts.Interrupt_ID;
      SCL          : not null access BBF.BSL.SAM3_GPIO.SAM3_GPIO_Pin'Class;
      SCL_Function : BBF.HPL.PIO.Peripheral_Function;
      SDA          : not null access BBF.BSL.SAM3_GPIO.SAM3_GPIO_Pin'Class;
      SDA_Function : BBF.HPL.PIO.Peripheral_Function) is
   limited new BBF.I2C.Master.I2C_Master_Controller with record
      Queue   : Operation_Queues.Queue (16);
      Current : Operation_Record;
      Handler : SAM3_TWI_Handler
                  (SAM3_I2C_Master_Controller'Unchecked_Access, Interrupt);
   end record;

   overriding procedure Read_Asynchronous
     (Self       : in out SAM3_I2C_Master_Controller;
      Device     : BBF.I2C.Device_Address;
      Register   : BBF.I2C.Internal_Address_8;
      Data       : System.Address;
      Length     : BBF.Unsigned_16;
      On_Success : BBF.Callback;
      On_Error   : BBF.Callback;
      Closure    : System.Address;
      Success    : in out Boolean);

   overriding procedure Write_Asynchronous
     (Self       : in out SAM3_I2C_Master_Controller;
      Device     : BBF.I2C.Device_Address;
      Register   : BBF.I2C.Internal_Address_8;
      Data       : System.Address;
      Length     : BBF.Unsigned_16;
      On_Success : BBF.Callback;
      On_Error   : BBF.Callback;
      Closure    : System.Address;
      Success    : in out Boolean);

end BBF.BSL.SAM3_I2C_Masters;
