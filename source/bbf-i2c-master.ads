------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                        Hardware Abstraction Layer                        --
--                                                                          --
--                        Runtime Library Component                         --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2019, Vadim Godunko <vgodunko@gmail.com>                     --
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
--  Master mode of I2C bus

pragma Restrictions (No_Elaboration_Code);

with Interfaces;
with System;

package BBF.I2C.Master is

   pragma Preelaborate;

   type I2C_Master_Controller is limited interface;

   not overriding procedure Write_Asynchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : System.Address;
      Length           : Interfaces.Unsigned_16) is abstract;
   --  Write data to the given device asynchronously.

   not overriding function Probe
     (Self    : in out I2C_Master_Controller;
      Address : BBF.I2C.Device_Address) return Boolean is abstract;
   --  Test if a chip answers a given I2C address.

   not overriding procedure Write_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : Interfaces.Unsigned_8;
      Success          : out Boolean) is abstract;
   --  Write multiple bytes to a I2C slave device.
   --
   --  This Subprogram will NOT return until all data has been written or error
   --  occurred.

   not overriding procedure Write_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : BBF.I2C.Internal_Address_8;
      Data             : BBF.I2C.Unsigned_8_Array;
      Success          : out Boolean) is abstract;
   --  Write multiple bytes to a I2C slave device.
   --
   --  This Subprogram will NOT return until all data has been written or error
   --  occurred.

   not overriding procedure Read_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out Interfaces.Unsigned_8;
      Success          : out Boolean) is abstract;
   --  Read multiple bytes from a TWI compatible slave device.
   --
   --  This subprogram will NOT return until all data has been read or error
   --  occurs.

   not overriding procedure Read_Synchronous
     (Self             : in out I2C_Master_Controller;
      Address          : BBF.I2C.Device_Address;
      Internal_Address : Interfaces.Unsigned_8;
      Data             : out BBF.I2C.Unsigned_8_Array;
      Success          : out Boolean) is abstract;
   --  Read multiple bytes from a TWI compatible slave device.
   --
   --  This subprogram will NOT return until all data has been read or error
   --  occurs.

end BBF.I2C.Master;
