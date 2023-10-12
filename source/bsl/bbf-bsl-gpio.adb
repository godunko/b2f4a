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

with BBF.HPL.NVIC;
with BBF.HPL.PMC;

package body BBF.BSL.GPIO is

   function Mask
    (Self : SAM3_GPIO_Pin'Class) return BBF.HPL.PIO.PIO_Pin_Array;

   procedure On_Interrupt (Self : in out SAM3_PIO_Driver);
   --  Handle hardware interrupt.

   procedure PIOA_Handler
     with Export,
          Convention    => C,
          External_Name => "PIOA_Handler";
   --  PIOA interrupt handler

   procedure PIOB_Handler
     with Export,
          Convention    => C,
          External_Name => "PIOB_Handler";
   --  PIOB interrupt handler

   procedure PIOC_Handler
     with Export,
          Convention    => C,
          External_Name => "PIOC_Handler";
   --  PIOC interrupt handler

   procedure PIOD_Handler
     with Export,
          Convention    => C,
          External_Name => "PIOD_Handler";
   --  PIOD interrupt handler

   type SAM3_PIO_Driver_Access is access all SAM3_PIO_Driver;

   Driver :
     array (BBF.HPL.Peripheral_Identifier
              range BBF.HPL.Parallel_IO_Controller_A
                      .. BBF.HPL.Parallel_IO_Controller_D)
       of SAM3_PIO_Driver_Access := (others => null);
   --  Driver objects to be used by interrupt handlers.

   ---------------
   -- Configure --
   ---------------

   overriding procedure Configure
     (Self : in out SAM3_GPIO_Pin;
      Mode : BBF.External_Interrupts.Interrupt_Mode) is
   begin
      case Mode is
         when BBF.External_Interrupts.Rising_Edge =>
            BBF.HPL.PIO.Set_Edge (Self.Driver.Controller, Self.Mask);
            BBF.HPL.PIO.Set_Rising_High (Self.Driver.Controller, Self.Mask);

         when BBF.External_Interrupts.Falling_Edge =>
            BBF.HPL.PIO.Set_Edge (Self.Driver.Controller, Self.Mask);
            BBF.HPL.PIO.Set_Falling_Low (Self.Driver.Controller, Self.Mask);

         when BBF.External_Interrupts.Low_Level =>
            BBF.HPL.PIO.Set_Level (Self.Driver.Controller, Self.Mask);
            BBF.HPL.PIO.Set_Falling_Low (Self.Driver.Controller, Self.Mask);

         when BBF.External_Interrupts.High_Level =>
            BBF.HPL.PIO.Set_Level (Self.Driver.Controller, Self.Mask);
            BBF.HPL.PIO.Set_Rising_High (Self.Driver.Controller, Self.Mask);
      end case;
   end Configure;

   -----------------------
   -- Disable_Interrupt --
   -----------------------

   overriding procedure Disable_Interrupt (Self : in out SAM3_GPIO_Pin) is
   begin
      BBF.HPL.PIO.Disable_Interrupt (Self.Driver.Controller, Self.Mask);
   end Disable_Interrupt;

   ----------------------
   -- Enable_Interrupt --
   ----------------------

   overriding procedure Enable_Interrupt (Self : in out SAM3_GPIO_Pin) is
   begin
      BBF.HPL.PIO.Enable_Interrupt (Self.Driver.Controller, Self.Mask);
   end Enable_Interrupt;

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

   ------------------
   -- On_Interrupt --
   ------------------

   procedure On_Interrupt (Self : in out SAM3_PIO_Driver) is
      Status : constant BBF.HPL.PIO.Status :=
        BBF.HPL.PIO.Get_And_Clear_Status (Self.Controller);

   begin
      for Pin in BBF.HPL.PIO.PIO_Pin'Range loop
         if BBF.HPL.PIO.Is_Detected (Status, Pin) then
            if Self.Callback (Pin).Handler /= null then
               Self.Callback (Pin).Handler (Self.Callback (Pin).Closure);
            end if;
         end if;
      end loop;
   end On_Interrupt;

   ------------------
   -- PIOA_Handler --
   ------------------

   procedure PIOA_Handler is
   begin
      On_Interrupt (Driver (BBF.HPL.Parallel_IO_Controller_A).all);
   end PIOA_Handler;

   ------------------
   -- PIOB_Handler --
   ------------------

   procedure PIOB_Handler is
   begin
      On_Interrupt (Driver (BBF.HPL.Parallel_IO_Controller_B).all);
   end PIOB_Handler;

   ------------------
   -- PIOC_Handler --
   ------------------

   procedure PIOC_Handler is
   begin
      On_Interrupt (Driver (BBF.HPL.Parallel_IO_Controller_C).all);
   end PIOC_Handler;

   ------------------
   -- PIOD_Handler --
   ------------------

   procedure PIOD_Handler is
   begin
      On_Interrupt (Driver (BBF.HPL.Parallel_IO_Controller_D).all);
   end PIOD_Handler;

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

   -----------------
   -- Set_Handler --
   -----------------

   overriding procedure Set_Handler
     (Self    : in out SAM3_GPIO_Pin;
      Handler : BBF.Callback;
      Closure : System.Address) is
   begin
      --  Enable peripheral clock, it is needed for some kind of interrupts.
      --
      --  XXX Need to be reviewed.

      BBF.HPL.PMC.Enable_Peripheral_Clock (Self.Driver.Peripheral);

      --  Connect hardware interrupt handler with PIO driver.

      if Driver (Self.Driver.Peripheral) = null then
         Driver (Self.Driver.Peripheral) := Self.Driver;
      end if;

      --  Store handler and closure.

      Self.Driver.Callback (Self.Pin).Closure := Closure;
      Self.Driver.Callback (Self.Pin).Handler := Handler;

      --  Enable interrupts from the peripheral

      BBF.HPL.NVIC.Enable_Interrupt (Self.Driver.Peripheral);
   end Set_Handler;

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
