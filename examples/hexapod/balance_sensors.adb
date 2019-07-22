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

pragma Restrictions (No_Elaboration_Code);

with Ada.Numerics.Elementary_Functions;

package body Balance_Sensors is

   function Sqrt (V : Float) return Float
     renames Ada.Numerics.Elementary_Functions.Sqrt;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self : in out Balance_Sensor; X, Y, Z : Linear_Acceleration)
   is
      Length : Float := Sqrt (Float (X) ** 2 + Float (Y) ** 2);
   begin
      Self.X0 := Float (X) / Length;
      Self.Y0 := Float (Y) / Length;
      Self.G := Sqrt (Float (X) ** 2 + Float (Y) ** 2 + Float (Z) ** 2);
   end Initialize;

   ------------
   -- Update --
   ------------

   procedure Update
     (Self    : Balance_Sensor;
      X, Y, Z : Linear_Acceleration;  --  Вектор V
      Output  : out Deviation)
   is
      pragma Unreferenced (Z);
      PX : constant Float := -Self.Y0;
      PY : constant Float := Self.X0;
      -- Vp - Горизонтальный вектор перпендикулярный V0 = (X0, Y0)
      PV : constant Float := PX * Float (X) + PY * Float (Y);
      --  Скалярное произведение V на Vp
      QX : constant Float := Float (X) - PX * PV;
      QY : constant Float := Float (Y) - PX * PV;
      --  Вычитаем из V его проекцию на перпендикуляр получаем Vq лежащий в
      --  плоскости проходящей через V0 и (0, 0, 1)
      Q_Length : constant Float := Sqrt (QX ** 2 + QY ** 2);
      --  Длинна проекции вектора Vq на плоскость прох. через V0 и (0, 0, 1)
      Angle : Float;
   begin

      --  Output := Deviation (Q_Length / Self.G);  --  cos угла между Vq и G

      Angle := Ada.Numerics.Elementary_Functions.Arcsin (Q_Length / Self.G);
      Output := Deviation ((Angle) / (Ada.Numerics.Pi / 2.0));

      --  Если V0 и V в разные стороны то меняем знак
      if Self.X0 * Float (X) + Self.Y0 * Float (Y) < 0.0 then
         Output := -Output;
      end if;

   end Update;

end Balance_Sensors;
