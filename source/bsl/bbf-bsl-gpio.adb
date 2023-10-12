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

package body BBF.BSL.GPIO is

   function Mask
    (Self : SAM3_GPIO_Pin'Class) return BBF.HPL.PIO.PIO_Pin_Array;

   ---------
   -- Get --
   ---------

   overriding function Get (Self : SAM3_GPIO_Pin) return Boolean is
      use type BBF.HPL.PIO.PIO_Pin_Array;

   begin
      return (BBF.HPL.PIO.Get (Self.Controller) and Self.Mask) = Self.Mask;
   end Get;

   ----------
   -- Mask --
   ----------

   function Mask
    (Self : SAM3_GPIO_Pin'Class) return BBF.HPL.PIO.PIO_Pin_Array is
   begin
      return Result : BBF.HPL.PIO.PIO_Pin_Array := (others => False) do
         Result (Self.Pin) := True;
      end return;
   end Mask;

   ---------
   -- Set --
   ---------

   overriding procedure Set (Self : SAM3_GPIO_Pin; To : Boolean) is
   begin
      case To is
         when True  => BBF.HPL.PIO.Set (Self.Controller, Self.Mask);
         when False => BBF.HPL.PIO.Clear (Self.Controller, Self.Mask);
      end case;
   end Set;

   -------------------
   -- Set_Direction --
   -------------------

   overriding procedure Set_Direction
    (Self : SAM3_GPIO_Pin; To : BBF.GPIO.Direction) is
   begin
      case To is
         when BBF.GPIO.Output =>
            BBF.HPL.PIO.Set_Output (Self.Controller, Self.Mask);

         when others =>
            raise Program_Error;
      end case;
   end Set_Direction;

   --------------------
   -- Set_Peripheral --
   --------------------

   procedure Set_Peripheral
    (Self : SAM3_GPIO_Pin'Class;
     To   : BBF.HPL.PIO.Peripheral_Function) is
   begin
      BBF.HPL.PIO.Set_Peripheral (Self.Controller, Self.Mask, To);
   end Set_Peripheral;

end BBF.BSL.GPIO;
