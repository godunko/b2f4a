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

--  I2C Bus Master on top of TWI controller

pragma Restrictions (No_Elaboration_Code);

with Interfaces;
with System;

private with BBF.ADT.Generic_MPMC_Bounded_Queues;
with BBF.BSL.GPIO;
with BBF.HPL.PIO;
with BBF.HRI.TWI;
with BBF.I2C.Master;

package BBF.BSL.I2C_Masters is

   pragma Preelaborate;

   type SAM3_I2C_Master_Controller
     (Controller   : not null access BBF.HRI.TWI.TWI_Peripheral;
      Peripheral   : BBF.HPL.Peripheral_Identifier;
      SCL          : not null access BBF.BSL.GPIO.SAM3_GPIO_Pin'Class;
      SCL_Function : BBF.HPL.PIO.Peripheral_Function;
      SDA          : not null access BBF.BSL.GPIO.SAM3_GPIO_Pin'Class;
      SDA_Function : BBF.HPL.PIO.Peripheral_Function) is
        limited new BBF.I2C.Master.I2C_Master_Controller with private;

   procedure Initialize (Self : in out SAM3_I2C_Master_Controller);

   overriding procedure Write_Asynchronous
     (Self             : in out SAM3_I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : System.Address;
      Length           : Interfaces.Unsigned_16);
   --  XXX Callbacks!

   overriding function Probe
    (Self    : in out SAM3_I2C_Master_Controller;
     Address : BBF.I2C.Device_Address) return Boolean;

   overriding procedure Write_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : BBF.I2C.Internal_Address_8;
     Data             : Interfaces.Unsigned_8;
     Success          : out Boolean);

   overriding procedure Write_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : BBF.I2C.Internal_Address_8;
     Data             : BBF.I2C.Unsigned_8_Array;
     Success          : out Boolean);

   overriding procedure Read_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : Interfaces.Unsigned_8;
     Data             : out Interfaces.Unsigned_8;
     Success          : out Boolean);

   overriding procedure Read_Synchronous
    (Self             : in out SAM3_I2C_Master_Controller;
     Address          : BBF.I2C.Device_Address;
     Internal_Address : Interfaces.Unsigned_8;
     Data             : out BBF.I2C.Unsigned_8_Array;
     Success          : out Boolean);

private

   type Operation_Record is record
      Device   : BBF.I2C.Device_Address;
      Register : BBF.I2C.Internal_Address_8;
      Data     : System.Address;
      Length   : Interfaces.Unsigned_16;
   end record;

   package Operation_Queues is
     new BBF.ADT.Generic_MPMC_Bounded_Queues (Operation_Record);

   type SAM3_I2C_Master_Controller
     (Controller   : not null access BBF.HRI.TWI.TWI_Peripheral;
      Peripheral   : BBF.HPL.Peripheral_Identifier;
      SCL          : not null access BBF.BSL.GPIO.SAM3_GPIO_Pin'Class;
      SCL_Function : BBF.HPL.PIO.Peripheral_Function;
      SDA          : not null access BBF.BSL.GPIO.SAM3_GPIO_Pin'Class;
      SDA_Function : BBF.HPL.PIO.Peripheral_Function) is
   limited new BBF.I2C.Master.I2C_Master_Controller with record
      Queue   : Operation_Queues.Queue (16);
      Current : Operation_Record;
   end record;

end BBF.BSL.I2C_Masters;
