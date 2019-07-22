------------------------------------------------------------------------------
--                                                                          --
--                       Bare-Board Framework for Ada                       --
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

package body PID_Controllers is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self         : in out PID_Controller;
      Proportional : Float;   --  proportional,
      Integral     : Float;   --  integral,
      Derivative   : Float;   --  derivative
      Min_Integral : Float;   --  Minimal integral value
      Max_Integral : Float) is
   begin
      Self :=
        (Integral => 0.0,
         Last_Error => 0.0,
         K_P => Proportional,
         K_I => Integral,
         K_D => Derivative,
         Min => Min_Integral,
         Max => Max_Integral);
   end Initialize;

   ------------
   -- Update --
   ------------

   procedure Update
     (Self         : in out PID_Controller;
      Error        : Float;
      Elapsed_Time : Float;
      Output       : out Float)
   is
      Integral   : Float;
      Derivative : Float;
   begin
      Output := Self.K_P * Error;

      if Self.K_I /= 0.0 then
         Integral := Float'Max (Self.Min,
             Float'Min (Self.Max, Self.Integral + Error * Elapsed_Time));

         Self.Integral := Integral;
         Output := Output + Self.K_I * Integral;
      end if;

      if Self.K_D /= 0.0 then
         Derivative := (Error - Self.Last_Error) / Elapsed_Time;
         Self.Last_Error := Error;
         Output := Output + Self.K_D * Derivative;
      end if;

   end Update;

end PID_Controllers;
