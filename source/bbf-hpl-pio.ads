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
--  Parallel Input/Output Controller (PIO) API

pragma Restrictions (No_Elaboration_Code);

private with BBF.HRI.PIO;

package BBF.HPL.PIO is

   pragma Preelaborate;

   type PIO is private;

   type PIO_Pin is range 0 .. 31;

   type PIO_Pin_Array is array (PIO_Pin) of Boolean
     with Component_Size => 1, Size => 32;

   type Peripheral_Function is (A, B);

   function PIOA return PIO;
   function PIOB return PIO;
   function PIOC return PIO;
   function PIOD return PIO;

   procedure Set_Output
     (Base       : PIO;
      Mask       : PIO_Pin_Array;
      Default    : Boolean := True;
      Multidrive : Boolean := False);
      --  XXX: Pull_Up
   --  Configure one or more pin(s) of a PIO controller as outputs, with the
   --  given default value. Optionally, the multi-drive feature can be enabled
   --  on the pin(s).

   procedure Set_Peripheral
     (Base : PIO;
      Mask : PIO_Pin_Array;
      To   : Peripheral_Function);
   --  Configure IO of a PIO controller as being controlled by a specific
   --  peripheral.

   procedure Set (Base : PIO; Mask : PIO_Pin_Array);
   --  Set a high output level on all the PIOs defined in Mask. This has no
   --  immediate effects on PIOs that are not output, but the PIO controller
   --  will save the value if they are changed to outputs.

   procedure Clear (Base : PIO; Mask : PIO_Pin_Array);
   --  Set a low output level on all the PIOs defined in Mask. This has no
   --  immediate effects on PIOs that are not output, but the PIO controller
   --  will save the value if they are changed to outputs.

private

   type PIO is access all BBF.HRI.PIO.PIO_Peripheral;

end BBF.HPL.PIO;
