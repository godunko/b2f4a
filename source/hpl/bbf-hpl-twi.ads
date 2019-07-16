------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
--                                                                          --
--                           Hardware Proxy Layer                           --
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
--  Two-wire Interface (TWI)

pragma Restrictions (No_Elaboration_Code);

with Interfaces;

with BBF.HRI.TWI;
with BBF.I2C;

package BBF.HPL.TWI is

   pragma Preelaborate;

   type TWI is access all BBF.HRI.TWI.TWI_Peripheral;

   function TWI0 return TWI;
   function TWI1 return TWI;

   type Unsigned_8_Array is array (Positive range <>) of Interfaces.Unsigned_8;

   procedure Initialize_Master
     (Self                 : TWI;
      Main_Clock_Frequency : Interfaces.Unsigned_32;
      Speed                : Interfaces.Unsigned_32);
   --  Initialize TWI master mode.

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

end BBF.HPL.TWI;
