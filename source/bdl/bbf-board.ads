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

--  This version of the package provides definitions for Arduino Due/X board.

with BBF.Clocks;
with BBF.Delays;
with BBF.GPIO;
private with BBF.HPL;
private with BBF.HRI.PIO;
private with BBF.HRI.SYSC;
private with BBF.HRI.SYST;
private with BBF.BSL.Clocks;
private with BBF.BSL.Delays;
private with BBF.BSL.GPIO;
with BBF.BSL.SAM;

package BBF.Board is

   pragma Preelaborate;

   Pin_SCL1   : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_SDA1   : constant not null access BBF.BSL.SAM.Pin'Class;

   Pin_0_RX0  : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_1_TD0  : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_13_LED : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_20_SDA : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_21_SCL : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_23     : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_50     : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_52     : constant not null access BBF.BSL.SAM.Pin'Class;
   Pin_53     : constant not null access BBF.BSL.SAM.Pin'Class;

   Delay_Controller :
     constant not null access BBF.Delays.Delay_Controller'Class;

   procedure Initialize_Delay_Controller;

   Real_Time_Clock_Controller :
     constant not null access BBF.Clocks.Real_Time_Clock_Controller'Class;

   procedure Initialize_Real_Time_Clock_Controller;

private

   PIOA : aliased BBF.BSL.GPIO.SAM3_PIO_Driver
     (Controller => BBF.HRI.PIO.PIOA_Periph'Access,
      Peripheral => BBF.HPL.Parallel_IO_Controller_A);
   PIOB : aliased BBF.BSL.GPIO.SAM3_PIO_Driver
     (Controller => BBF.HRI.PIO.PIOB_Periph'Access,
      Peripheral => BBF.HPL.Parallel_IO_Controller_B);
   PIOC : aliased BBF.BSL.GPIO.SAM3_PIO_Driver
     (Controller => BBF.HRI.PIO.PIOC_Periph'Access,
      Peripheral => BBF.HPL.Parallel_IO_Controller_C);
   PIOD : aliased BBF.BSL.GPIO.SAM3_PIO_Driver
     (Controller => BBF.HRI.PIO.PIOD_Periph'Access,
      Peripheral => BBF.HPL.Parallel_IO_Controller_D);

   Delay_Instance : aliased BBF.BSL.Delays.SAM_SYSTICK_Controller
     := (Controller => BBF.HRI.SYST.SYST_Periph'Access);

   Clock_Instance : aliased BBF.BSL.Clocks.SAM_RTT_Clock_Controller
     := (Controller => BBF.HRI.SYSC.RTT_Periph'Access);

   Pin_SCL1   : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOA.Pin_18'Access;
   Pin_SDA1   : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOA.Pin_17'Access;

   Pin_0_RX0  : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOA.Pin_08'Access;
   Pin_1_TD0  : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOA.Pin_09'Access;

   Pin_13_LED : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOB.Pin_27'Access;

   Pin_20_SDA : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOB.Pin_12'Access;
   Pin_21_SCL : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOB.Pin_13'Access;
   Pin_23     : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOA.Pin_14'Access;
   Pin_50     : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOC.Pin_13'Access;
   Pin_52     : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOB.Pin_21'Access;
   Pin_53     : constant not null access BBF.BSL.SAM.Pin'Class
     := PIOB.Pin_14'Access;

   Delay_Controller :
     constant not null access BBF.Delays.Delay_Controller'Class
       := Delay_Instance'Access;

   Real_Time_Clock_Controller :
     constant not null access BBF.Clocks.Real_Time_Clock_Controller'Class
       := Clock_Instance'Access;

end BBF.Board;
