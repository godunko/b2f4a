------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2019-2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

with System.Address_To_Access_Conversions;

with BBF.Board;
with BBF.External_Interrupts;
with BBF.HPL.PMC;
with BBF.GPIO;

with Hexapod.Console;
with BBF.BSL.I2C_Masters;

package body BBF.Drivers.MPU is

   ACCEL_XOUT_H_Address : constant BBF.I2C.Internal_Address_8 := 16#3B#;
   TEMP_OUT_H_Address   : constant BBF.I2C.Internal_Address_8 := 16#41#;
   GYRO_XOUT_H_Address  : constant BBF.I2C.Internal_Address_8 := 16#43#;
   WHO_AM_I_Address     : constant BBF.I2C.Internal_Address_8 := 16#75#;

   --  type Acceleration is delta 0.000_01 range -16.0 .. 16.0;
   --  type Gravitational_Acceleration is delta 1.0 / 2 ** 15 range -16.0 .. 16.0;
   type Gravitational_Acceleration is delta 1.0 / 16_384 range -16.0 .. 16.0;

   type Rotation_Velosity is delta 1.0 / 131_072 range -2_000.0 .. 2_000.0;

   Enabled : Boolean := False;
   Flag    : Boolean := False with Volatile;
   Fail_Read_Counter : Natural := 0;
   Success_Read_Counter : Natural := 0;
   Enqueue_Read_Counter : Natural := 0;

--     type Abstract_MPU_Sensor_Access is
--       access all Abstract_MPU_Sensor'Class;

   package Conversions is
     new System.Address_To_Access_Conversions
           (Object => Abstract_MPU_Sensor'Class);

   procedure On_Read (Closure : System.Address);

   procedure On_Error (Closure : System.Address);

   function Get_Flag return Boolean is
   begin
      return Result : constant Boolean := Flag do
         Flag := False;
      end return;
   end Get_Flag;

   Reported : Boolean := False;
   Fill_Step : Boolean := False;

   procedure Handler (Closure : System.Address) is
      use type Interfaces.Integer_8;

      Self    : constant Conversions.Object_Pointer :=
        Conversions.To_Pointer (Closure);
      --  Self    : Abstract_MPU_Sensor'Class
      --    with Import, Convention => Ada, Address => Closure;
      Success : Boolean := True;

   begin
      if Fill_Step then
         Self.Data := ((0, 0, 0, 0, 0, 0), (0, 0), (0, 0, 0, 0, 0, 0));

      else
         Self.Data :=
           ((-1, 255, -1, 255, -1, 255), (-1, 255), (-1, 255, -1, 255, -1, 255));
      end if;

      Fill_Step := not @;

      Self.Bus.Read_Asynchronous
        (Device     => Self.Device,
         Register   => ACCEL_XOUT_H_Address,
         Data       => Self.Data'Address,
         Length     => 14,
         On_Success => On_Read'Access,
         On_Error   => On_Error'Access,
         Closure    => Closure,
         Success    => Success);

      if not Success then
         Enqueue_Read_Counter := @ + 1;

         if not Reported then
            Reported := True;

            Hexapod.Console.Put_Line
              ("Async read enqueue failed, operation "
               & Natural'Image (Enqueue_Read_Counter)
               & " completed "
               & Natural'Image
                   (Success_Read_Counter + Fail_Read_Counter));

            --  Hexapod.Console.Put_Line
            --    (Interfaces.Integer_8'Image (Self.Data.ACCEL.ACCEL_XOUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.ACCEL.ACCEL_XOUT_L)
            --     & Interfaces.Integer_8'Image (Self.Data.ACCEL.ACCEL_YOUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.ACCEL.ACCEL_YOUT_L)
            --     & Interfaces.Integer_8'Image (Self.Data.ACCEL.ACCEL_ZOUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.ACCEL.ACCEL_ZOUT_L)
            --     & "   "
            --     & Interfaces.Integer_8'Image (Self.Data.TEMP.TEMP_OUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.TEMP.TEMP_OUT_L)
            --     & "   "
            --     & Interfaces.Integer_8'Image (Self.Data.GYRO.GYRO_XOUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.GYRO.GYRO_XOUT_L)
            --     & Interfaces.Integer_8'Image (Self.Data.GYRO.GYRO_YOUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.GYRO.GYRO_YOUT_L)
            --     & Interfaces.Integer_8'Image (Self.Data.GYRO.GYRO_ZOUT_H)
            --     & Interfaces.Unsigned_8'Image (Self.Data.GYRO.GYRO_ZOUT_L));
         end if;
         --  raise Program_Error;
      end if;
   end Handler;

   procedure On_Error (Closure : System.Address) is
   begin
      Fail_Read_Counter := @ + 1;
      Hexapod.Console.Put_Line
        ("I2C    ERROR: "
         & Integer'Image (Fail_Read_Counter)
         & "   ENQUEUE: "
         & Integer'Image (Enqueue_Read_Counter)
         & "   DONE: "
         & Integer'Image (Success_Read_Counter)
        );
      --  Hexapod.Console.Put_Line
      --    ("ERROR : "
      --     & Interfaces.Unsigned_32'Image (S)
      --     & "   SUCCESSFUL READS: "
      --     & Integer'Image (Success_Read_Counter));
   end On_Error;

   procedure On_Read (Closure : System.Address) is
      Self : constant Conversions.Object_Pointer :=
        Conversions.To_Pointer (Closure);

   begin
      Flag := True;
      Success_Read_Counter := @ + 1;
      --  Hexapod.Console.Put_Line
      --    ("DONE, STATUS: "
      --     & Interfaces.Unsigned_32'Image (S)
      --     & "   FAIL: "
      --     & Integer'Image (Fail_Read_Counter)
      --     & "   SUCCESS: "
      --     & Integer'Image (Success_Read_Counter)
      --     & "   TOTAL: "
      --     & Integer'Image (Enqueue_Read_Counter)
      --    );
      --  Hexapod.Console.Put_Line
      --    (Interfaces.Integer_8'Image (Self.Data.ACCEL.ACCEL_XOUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.ACCEL.ACCEL_XOUT_L)
      --     & Interfaces.Integer_8'Image (Self.Data.ACCEL.ACCEL_YOUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.ACCEL.ACCEL_YOUT_L)
      --     & Interfaces.Integer_8'Image (Self.Data.ACCEL.ACCEL_ZOUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.ACCEL.ACCEL_ZOUT_L)
      --     & "   "
      --     & Interfaces.Integer_8'Image (Self.Data.TEMP.TEMP_OUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.TEMP.TEMP_OUT_L)
      --     & "   "
      --     & Interfaces.Integer_8'Image (Self.Data.GYRO.GYRO_XOUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.GYRO.GYRO_XOUT_L)
      --     & Interfaces.Integer_8'Image (Self.Data.GYRO.GYRO_YOUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.GYRO.GYRO_YOUT_L)
      --     & Interfaces.Integer_8'Image (Self.Data.GYRO.GYRO_ZOUT_H)
      --     & Interfaces.Unsigned_8'Image (Self.Data.GYRO.GYRO_ZOUT_L));
   end On_Read;

   procedure Enable (Self : in out Abstract_MPU_Sensor'Class) is
      Success : Boolean := True;

   begin
      if Enabled then
         return;
      end if;

      Enabled := True;

      Self.Internal_Enable_Interrupts (Success);

      --  BBF.External_Interrupts.Configure
      --    (BBF.Board.Pin_50.all,
      --     BBF.External_Interrupts.Falling_Edge);
      --  BBF.External_Interrupts.Pin'Class
      --    (BBF.Board.Pin_50.all).Configure (BBF.External_Interrupts.Falling_Edge);
      BBF.Board.Pin_50.Configure (BBF.External_Interrupts.Falling_Edge);
      BBF.Board.Pin_50.Set_Handler (Handler'Access, Self'Address);
      BBF.Board.Pin_50.Enable_Interrupt;

      Hexapod.Console.Put_Line ("MPU interrupt enabled");
      --  if not Success then
      --     raise Program_Error;
      --  end if;
      --
      --  declare
      --     use type Interfaces.Unsigned_8;
      --
      --     B : Interfaces.Unsigned_8 := 255;
      --
      --  begin
      --     while BBF.Board.Pin_50.Get loop
      --        null;
      --     end loop;
      --
      --     loop
      --        Self.Bus.Read_Synchronous (Self.Device, 16#3A#, B, Success);
      --
      --        if (B and 1) = 0 then
      --           Hexapod.Console.Put_Line
      --             ("IS: " & Interfaces.Unsigned_8'Image (B));
      --           exit;
      --
      --        else
      --           Hexapod.Console.Put (".");
      --        end if;
      --     end loop;
      --  end;
      --
      --  --  while BBF.Board.Pin_50.Get loop
      --  --     null;
      --  --  end loop;
      --
      --  Hexapod.Console.Put_Line
      --    ("PIN: " & Boolean'Image (BBF.Board.Pin_50.Get));
   end Enable;

   ---------------
   -- Configure --
   ---------------

   type CONFIG_Resgisters is record
      SMPLRT_DIV     : Registers.SMPLRT_DIV_Register;
      CONFIG         : Registers.CONFIG_Register;
      GYRO_CONFIG    : Registers.GYRO_CONFIG_Register;
      ACCEL_CONFIG   : Registers.ACCEL_CONFIG_Register;
      ACCEL_CONFIG_2 : Registers.MPU6500_ACCEL_CONFIG_2_Register;
   end record
     with Pack, Object_Size => 40;

   type PWR_MGMT_Registers is record
      PWR_MGMT_1 : Registers.PWR_MGMT_1_Register;
      PWR_MGMT_2 : Registers.PWR_MGMT_2_Register;
   end record
     with Pack, Object_Size => 16;

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Self                : in out Abstract_MPU_Sensor'Class;
      Delays              : not null access BBF.Delays.Delay_Controller'Class;
      Accelerometer_Range : Accelerometer_Range_Type;
      Gyroscope_Range     : Gyroscope_Range_Type;
      Temperature         : Boolean;
      Filter              : Boolean;
      Sample_Rate         : Sample_Rate_Type;
      Success             : in out Boolean)
   is
      use type Interfaces.Unsigned_8;

      SMPLRT_DIV : constant Interfaces.Unsigned_8 :=
        Interfaces.Unsigned_8
          ((if Filter then 1_000 else 8_000) / Sample_Rate - 1);
      --  MPU6500 has additional 8_000 and 32_000 modes, however, this value is
      --  used only when DLPF in 1 .. 6.

      CONFIG     : constant CONFIG_Resgisters :=
        (SMPLRT_DIV     =>
           (SMPLRT_DIV => SMPLRT_DIV),
           --  MPU6050: Gyro rate is 8k when CONFIG:DLPF_CFG = 0, and
           --  1k overwise. MPU6500: Depends from CONFIG:DLPF_CFG and
           --  GYRO_CFG:FCHOICE_B, looks compatible with allowed MPU6050
           --  values.
         CONFIG         =>
           (DLPF_CFG          =>
                (if not Filter then 0
                 elsif Sample_Rate >= 188 * 2 then 1
                 elsif Sample_Rate >=  98 * 2 then 2
                 elsif Sample_Rate >=  42 * 2 then 3
                 elsif Sample_Rate >=  20 * 2 then 4
                 elsif Sample_Rate >=  10 * 2 then 5
                                              else 6),
            --  MPU6500 support value 7 to bypass filter, not implemented.
            EXT_SYNC_SET      => Registers.Disabled,
            MPU6500_FIFO_MODE => False,
            others            => False),
         --  Enable DLPF_CFG, rate will be about 180 Hz.
         GYRO_CONFIG    =>
           (MPU6500_FCHOICE_B => 0,
            GYRO_FS_SEL       =>
              (case Gyroscope_Range is
                  when FSR_250DPS  => Registers.G_250,
                  when FSR_500DPS  => Registers.G_500,
                  when FSR_1000DPS => Registers.G_1000,
                  when FSR_2000DPS => Registers.G_2000,
                  when Disabled    => Registers.GYRO_FS_SEL_Type'First),
            others            => False),
         ACCEL_CONFIG   =>
           (ACCEL_FS_SEL =>
                (case Accelerometer_Range is
                    when FSR_2G   => Registers.A_2,
                    when FSR_4G   => Registers.A_4,
                    when FSR_8G   => Registers.A_8,
                    when FSR_16G  => Registers.A_16,
                    when Disabled => Registers.ACCEL_FS_SEL_Type'First),
            others       => False),
         ACCEL_CONFIG_2 =>
           (A_DLPF_CFG     =>
                (if not Filter then 0
                 elsif Sample_Rate >= 188 * 2 then 1
                 elsif Sample_Rate >=  98 * 2 then 2
                 elsif Sample_Rate >=  42 * 2 then 3
                 elsif Sample_Rate >=  20 * 2 then 4
                 elsif Sample_Rate >=  10 * 2 then 5
                                              else 6),
            ACCEL_CHOICE_B => False,
            FIFO_SIZE_1024 => True,
            --  MPU6500 shares 4kB of memory between the DMP and the FIFO.
            --  Since the first 3kB are needed by the DMP, we'll use the
            --  last 1kB for the FIFO.
            others         => False));
         --  This register is available on MPU6500/9250 only. Selected values
         --  run accelerometer at about 180 Hz, like gyro.
      CONFIG_B   : constant BBF.I2C.Unsigned_8_Array (1 .. 5)
        with Import, Convention => Ada, Address => CONFIG'Address;

      PWR_MGMT   : constant PWR_MGMT_Registers :=
        (PWR_MGMT_1 =>
           (CLKSEL   =>
                (if Gyroscope_Range /= Disabled
                   then Registers.PLL_X
                   else Registers.Internal),
                 --  On MPU6500 Auto (PLL_X) can be used always
            TEMP_DIS => not Temperature,
            SLEEP    =>
              Accelerometer_Range = Disabled
                and Gyroscope_Range = Disabled
                and not Temperature,
            others => <>),
         PWR_MGMT_2 =>
           (STBY_ZG => Gyroscope_Range = Disabled,
            STBY_YG => Gyroscope_Range = Disabled,
            STBY_XG => Gyroscope_Range = Disabled,
            STBY_ZA => Accelerometer_Range = Disabled,
            STBY_YA => Accelerometer_Range = Disabled,
            STBY_XA => Accelerometer_Range = Disabled,
            others  => <>));
      PWR_MGMT_B : constant BBF.I2C.Unsigned_8_Array (1 .. 2)
        with Import, Convention => Ada, Address => PWR_MGMT'Address;

   begin
      if not Success then
         return;
      end if;

      if not Self.Initialized then
         Success := False;

         return;
      end if;

      --  Configuration of SMPLRT_DIV is set to lower gyro rate on MPU6050 to
      --  rate of the accelerometer.
      --
      --  DLPF is enabled and DLPF_CFG/FCHOICE_B set to have gyro rate 184 Hz.
      --  It is possible to lower gyro rate and have it close to accelerometer
      --  rate.
      --
      --  On MPU6500/9250 accelerometer configured to 188 Hz rate. It is
      --  separate rergister on these sensors, on MPU6050/9150 when DLPF
      --  is configured it applies to both gyro and accelerometer.
      --
      --  MPU6500/9250 has more modes, but they are not compatible with
      --  MPU6050/9150 and not useful for my purposes.

      Self.Bus.Write_Synchronous
        (Self.Device,
         SMPLRT_DIV_Address,
         CONFIG_B (1 .. (if Self.Is_6500_9250 then 5 else 4)),
         Success);
      Self.Bus.Write_Synchronous
        (Self.Device, PWR_MGMT_1_Address, PWR_MGMT_B, Success);

      Delays.Delay_Milliseconds (50);
   end Configure;

   ----------
   -- Dump --
   ----------

   procedure Dump (Self : in out Abstract_MPU_Sensor'Class) is
      Data    : Raw_Out_Registers;
      Buffer  : BBF.I2C.Unsigned_8_Array
        (1 .. Raw_Out_Registers'Max_Size_In_Storage_Elements)
           with Address => Data'Address;
      Success : Boolean := True;

      --  A_Scale : constant := 2_048;
      --  R_Scale : constant := 32_768;
      GA_Precision : constant := 16_384;
      GA_Scale     : constant := GA_Precision / 2_048;
      --  G_Precision : constant := 131_072;  --  2^15 / 250 * 1000
      --  G_Prescale  : constant := 1_000;
      --  G_Scale     : constant := 8 * 1_000; --  A_Precision / 16.4;

      function A
        (H : Interfaces.Integer_8;
         L : Interfaces.Unsigned_8) return Gravitational_Acceleration
      is
         use type Interfaces.Integer_32;

         V_Raw        : constant Interfaces.Integer_32 :=
           Interfaces.Integer_32 (H) * 256 + Interfaces.Integer_32 (L);
         V_Scaled     : constant Interfaces.Integer_32 := V_Raw * GA_Scale;
         A_Integral   : constant Gravitational_Acceleration :=
           Gravitational_Acceleration (V_Scaled / GA_Precision);
            A_Fractional : constant Gravitational_Acceleration :=
              Gravitational_Acceleration'Base
                (V_Scaled mod GA_Precision) * Gravitational_Acceleration'Delta;

      begin
            return A_Integral + A_Fractional;
      end A;

      function A
        (H : Interfaces.Integer_8;
         L : Interfaces.Unsigned_8) return Rotation_Velosity
      is
         use type Interfaces.Integer_64;

         RV_Precision : constant := 131_072;  --  2^15 / 250 * 1000
         RV_Scale     : constant := 1_000;

         V_Raw        : constant Interfaces.Integer_64 :=
           Interfaces.Integer_64 (H) * 256 + Interfaces.Integer_64 (L);
         V_Scaled     : constant Interfaces.Integer_64 := V_Raw * RV_Scale;
         --  V_Scaled     : constant Interfaces.Integer_32 := V_Raw * G_Scale;
         A_Integral   : constant Rotation_Velosity :=
           Rotation_Velosity (V_Scaled / RV_Precision);
         --  A_Integral   : constant Rotation_Velosity :=
         --    Rotation_Velosity (V_Scaled / G_Precision);
         --    --  Rotation_Velosity ((V_Scaled / G_Precision) / G_Prescale);

      begin
         --  Hexapod.Console.New_Line;
         --  Hexapod.Console.Put (Interfaces.Integer_64'Image (V_Scaled));
         --  Hexapod.Console.Put (Rotation_Velosity'Image (A_Integral));
         --  Hexapod.Console.Put
         --    (Interfaces.Integer_64'Image (V_Scaled mod GA_Precision));

         declare
         A_Fractional : constant Rotation_Velosity :=
           Rotation_Velosity'Base
             (Long_Float (V_Scaled mod RV_Precision) * Long_Float (Rotation_Velosity'Delta));
         --      --  ((V_Scaled mod G_Precision) / G_Prescale) * Rotation_Velosity'Delta;
      begin
            return A_Integral + A_Fractional;
            end;
      end A;

   begin
      Hexapod.Console.Put_Line
        ("I2C    ERROR: "
         & Integer'Image (Fail_Read_Counter)
         & "   ENQUEUE: "
         & Integer'Image (Enqueue_Read_Counter)
         & "   DONE: "
         & Integer'Image (Success_Read_Counter)
        );

      --  Self.Bus.Read_Synchronous
      --    (Self.Device, ACCEL_XOUT_H_Address, Buffer, Success);
      --
      Hexapod.Console.Put_Line
        --  (Interfaces.Integer_8'Image (Data.ACCEL.ACCEL_XOUT_H)
        --   & Interfaces.Unsigned_8'Image (Data.ACCEL.ACCEL_XOUT_L)
        --   & "   "
        --   & Interfaces.Integer_8'Image (Data.ACCEL.ACCEL_YOUT_H)
        --   & Interfaces.Unsigned_8'Image (Data.ACCEL.ACCEL_YOUT_L)
        --   & "   "
        --   & Interfaces.Integer_8'Image (Data.ACCEL.ACCEL_YOUT_H)
        --   & Interfaces.Unsigned_8'Image (Data.ACCEL.ACCEL_YOUT_L)
        --   & "     "
        ("GA: "
         & Gravitational_Acceleration'Image
           (A (Data.ACCEL.ACCEL_XOUT_H, Data.ACCEL.ACCEL_XOUT_L))
         & " "
         & Gravitational_Acceleration'Image
           (A (Data.ACCEL.ACCEL_YOUT_H, Data.ACCEL.ACCEL_YOUT_L))
         & " "
         & Gravitational_Acceleration'Image
           (A (Data.ACCEL.ACCEL_ZOUT_H, Data.ACCEL.ACCEL_ZOUT_L)));

      Hexapod.Console.Put_Line
        (Interfaces.Integer_8'Image (Data.TEMP.TEMP_OUT_H)
         & Interfaces.Unsigned_8'Image (Data.TEMP.TEMP_OUT_L));

      Hexapod.Console.Put_Line
        ("RV: "
         --  & Interfaces.Integer_8'Image (Data.GYRO.GYRO_XOUT_H)
         --  & Interfaces.Unsigned_8'Image (Data.GYRO.GYRO_XOUT_L)
         --  & "   "
         --  & Interfaces.Integer_8'Image (Data.GYRO.GYRO_YOUT_H)
         --  & Interfaces.Unsigned_8'Image (Data.GYRO.GYRO_YOUT_L)
         --  & "   "
         --  & Interfaces.Integer_8'Image (Data.GYRO.GYRO_ZOUT_H)
         --  & Interfaces.Unsigned_8'Image (Data.GYRO.GYRO_ZOUT_L));
      --  Hexapod.Console.Put_Line
      --    (""
         & Rotation_Velosity'Image
             (A (Data.GYRO.GYRO_XOUT_H, Data.GYRO.GYRO_XOUT_L))
         & " "
         & Rotation_Velosity'Image
             (A (Data.GYRO.GYRO_YOUT_H, Data.GYRO.GYRO_YOUT_L))
         & " "
         & Rotation_Velosity'Image
             (A (Data.GYRO.GYRO_ZOUT_H, Data.GYRO.GYRO_ZOUT_L))
        );

      --
      --  --  BBF.Board.Pin_50.Set_Direction (BBF.GPIO.Input);
      --  Hexapod.Console.New_Line;
      --  Hexapod.Console.Put_Line
      --    ("PIN: " & Boolean'Image (BBF.Board.Pin_50.Get));

      Self.Enable;
      --  Handler (Self'Address);
   end Dump;

   --------------------------------
   -- Internal_Enable_Interrupts --
   --------------------------------

   not overriding procedure Internal_Enable_Interrupts
     (Self    : in out Abstract_MPU_Sensor;
      Success : in out Boolean) is
   begin
      raise Program_Error;
   end Internal_Enable_Interrupts;

   -------------------------
   -- Internal_Initialize --
   -------------------------

   procedure Internal_Initialize
     (Self    : in out Abstract_MPU_Sensor;
      Success : in out Boolean) is
   begin
      --  XXX set internal data

      null;
      BBF.HPL.PMC.Enable_Peripheral_Clock (BBF.HPL.Parallel_IO_Controller_C);
   end Internal_Initialize;

   -------------------------
   -- Internal_Initialize --
   -------------------------

   procedure Internal_Initialize
     (Self    : in out Abstract_MPU_Sensor'Class;
      Delays  : not null access BBF.Delays.Delay_Controller'Class;
      WHOAMI  : Interfaces.Unsigned_8;
      Success : in out Boolean)
   is
      use type Interfaces.Unsigned_8;

      Buffer : Interfaces.Unsigned_8;

   begin
      Self.Initialized := False;

      if not Success then
         return;
      end if;

      --  Do controller's probe.

      Success := Self.Bus.Probe (Self.Device);

      if not Success then
         return;
      end if;

      --  Check controller's WHOAMI code

      Self.Bus.Read_Synchronous
        (Self.Device, MPU.WHO_AM_I_Address, Buffer, Success);

      if not Success then
         return;

      elsif Buffer /= WHOAMI then
         Success := False;

         return;
      end if;

      --  Device reset

      declare
         PWR_MGMT_1   : constant Registers.PWR_MGMT_1_Register :=
           (DEVICE_RESET => True,
            CLKSEL       => Registers.Internal,
            others       => <>);
         PWR_MGMT_1_B : Interfaces.Unsigned_8
           with Address => PWR_MGMT_1'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device, PWR_MGMT_1_Address, PWR_MGMT_1_B, Success);

         if not Success then
            return;
         end if;
      end;

      Delays.Delay_Milliseconds (100);

      --  Signal path reset

      declare
         SIGNAL_PATH_RESET   : Registers.SIGNAL_PATH_RESET_Register :=
           (TEMP_Reset  => True,
            ACCEL_Reset => True,
            GYRO_Reset  => True,
            others      => <>);
         SIGNAL_PATH_RESET_B : Interfaces.Unsigned_8
           with Address => SIGNAL_PATH_RESET'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device,
            SIGNAL_PATH_RESET_Address,
            SIGNAL_PATH_RESET_B,
            Success);

         if not Success then
            return;
         end if;
      end;

      Delays.Delay_Milliseconds (100);

      --  Wakeup

      declare
         PWR_MGMT_1   : Registers.PWR_MGMT_1_Register :=
           (SLEEP  => False,
            CLKSEL => Registers.Internal,
            others => <>);
         PWR_MGMT_1_B : Interfaces.Unsigned_8
           with Address => PWR_MGMT_1'Address;

      begin
         Self.Bus.Write_Synchronous
           (Self.Device, PWR_MGMT_1_Address, PWR_MGMT_1_B, Success);
      end;

      Self.Initialized := True;
   end Internal_Initialize;

--     ----------------
--     -- Initialize --
--     ----------------
--
--     procedure Initialize
--       (Self    : in out Abstract_MPU_Sensor'Class;
--        Delays  : not null access BBF.Delays.Delay_Controller'Class;
--        Success : in out Boolean)
--     is
--
--     begin
--        Self.Initialized := False;
--
--        --  Reset device
--
--        Self.Internal_Reset (Success);
--        Delays.Delay_Milliseconds (100);
--
--        --  Wakeup chip
--
--        Self.Internal_Wakeup (Success);
--
--        --  Chip specific initialization
--
--        Self.Internal_Initialize (Success);
--
--
--  --      BBF.HPL.TWI.Master_Read_Synchronous
--  --       (Self.Bus, Device_Address, 16#08#, Buffer, Success);
--  --
--  --      if not Success then
--  --         Console.Put_Line ("  Read (08) failure");
--  --
--  --         return;
--  --      end if;
--
--        Self.Bus.Write_Synchronous
--          (Device_Address, INT_PIN_CFG_Address, 2#0000_0010#, Success);
--
--        if not Success then
--           Hexapod.Console.Put_Line ("MPU9250 write error, register 37");
--        end if;
--     end Initialize;

end BBF.Drivers.MPU;
