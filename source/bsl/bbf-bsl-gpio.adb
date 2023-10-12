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

package body BBF.BSL.GPIO is

   function Mask
    (Self : SAM3_GPIO_Pin'Class) return BBF.HPL.PIO.PIO_Pin_Array;

   ---------
   -- Get --
   ---------

   overriding function Get (Self : SAM3_GPIO_Pin) return Boolean is
      use type BBF.HPL.PIO.PIO_Pin_Array;

   begin
      return
        (BBF.HPL.PIO.Get (Self.Driver.Controller) and Self.Mask) = Self.Mask;
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
         when True  => BBF.HPL.PIO.Set (Self.Driver.Controller, Self.Mask);
         when False => BBF.HPL.PIO.Clear (Self.Driver.Controller, Self.Mask);
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
            BBF.HPL.PIO.Set_Output (Self.Driver.Controller, Self.Mask);

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
      BBF.HPL.PIO.Set_Peripheral (Self.Driver.Controller, Self.Mask, To);
   end Set_Peripheral;

end BBF.BSL.GPIO;
