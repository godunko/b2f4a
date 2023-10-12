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

--  I2C interfaces for Arduino Due/X board

private with BBF.BSL.I2C_Masters;
private with BBF.HPL.PIO;
private with BBF.HRI.TWI;
with BBF.I2C.Master;

package BBF.Board.I2C is

   I2C0 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class;
   I2C1 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class;

   procedure Initialize_I2C_0;
   procedure Initialize_I2C_1;

private

   TWI0_I2C : aliased BBF.BSL.I2C_Masters.SAM3_I2C_Master_Controller
     (Controller   => BBF.HRI.TWI.TWI0_Periph'Access,
      Peripheral   => BBF.HPL.Two_Wire_Interface_0,
      SCL          => PIOA.Pin_18'Access,
      SCL_Function => BBF.HPL.PIO.A,
      SDA          => PIOA.Pin_17'Access,
      SDA_Function => BBF.HPL.PIO.A);
   TWI1_I2C : aliased BBF.BSL.I2C_Masters.SAM3_I2C_Master_Controller
     (Controller   => BBF.HRI.TWI.TWI1_Periph'Access,
      Peripheral   => BBF.HPL.Two_Wire_Interface_1,
      SCL          => PIOB.Pin_13'Access,
      SCL_Function => BBF.HPL.PIO.A,
      SDA          => PIOB.Pin_12'Access,
      SDA_Function => BBF.HPL.PIO.A);

   I2C0 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class
     := TWI0_I2C'Access;
   I2C1 : constant not null access BBF.I2C.Master.I2C_Master_Controller'Class
     := TWI1_I2C'Access;

end BBF.Board.I2C;
