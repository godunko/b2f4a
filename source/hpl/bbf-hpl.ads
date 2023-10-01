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

pragma Restrictions (No_Elaboration_Code);

with Interfaces;

package BBF.HPL is

   pragma Pure;

   type Peripheral_Identifier is
     (Supply_Controller,
      Reset_Controller,
      Real_Time_Clock,
      Real_Time_Timer,
      Watchdog_Timer,
      Power_Management_Controller,
      Enhanced_Flash_Controller_0,
      Enhanced_Flash_Controller_1,
      Universal_Asynchronous_Receiver_Transceiver,
      Static_Memory_Controller,
      Parallel_IO_Controller_A,
      Parallel_IO_Controller_B,
      Parallel_IO_Controller_C,
      Parallel_IO_Controller_D,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_0,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_1,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_2,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_3,
      Multimedia_Card_Interface,
      Two_Wire_Interface_0,
      Two_Wire_Interface_1,
      Serial_Peripheral_Interface_0,
      Synchronous_Serial_Controller,
      Timer_Counter_0,
      Timer_Counter_1,
      Timer_Counter_2,
      Timer_Counter_3,
      Timer_Counter_4,
      Timer_Counter_5,
      Timer_Counter_6,
      Timer_Counter_7,
      Timer_Counter_8,
      Pulse_Width_Modulation_Controller,
      Analog_To_Digital_Converter_Controller,
      Digital_To_Analog_Converter_Controller,
      DMA_Controller,
      USB_Controller,
      True_Random_Number_Generator,
      Ethernet_MAC,
      CAN_Controller_0,
      CAN_Controller_1);
   for Peripheral_Identifier'Size use Interfaces.Unsigned_8'Size;
   for Peripheral_Identifier use
     (Supply_Controller                                         => 0,
      Reset_Controller                                          => 1,
      Real_Time_Clock                                           => 2,
      Real_Time_Timer                                           => 3,
      Watchdog_Timer                                            => 4,
      Power_Management_Controller                               => 5,
      Enhanced_Flash_Controller_0                               => 6,
      Enhanced_Flash_Controller_1                               => 7,
      Universal_Asynchronous_Receiver_Transceiver               => 8,
      Static_Memory_Controller                                  => 9,
      Parallel_IO_Controller_A                                  => 11,
      Parallel_IO_Controller_B                                  => 12,
      Parallel_IO_Controller_C                                  => 13,
      Parallel_IO_Controller_D                                  => 14,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_0 => 17,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_1 => 18,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_2 => 19,
      Universal_Synchronous_Asynchronous_Receiver_Transceiver_3 => 20,
      Multimedia_Card_Interface                                 => 21,
      Two_Wire_Interface_0                                      => 22,
      Two_Wire_Interface_1                                      => 23,
      Serial_Peripheral_Interface_0                             => 24,
      Synchronous_Serial_Controller                             => 26,
      Timer_Counter_0                                           => 27,
      Timer_Counter_1                                           => 28,
      Timer_Counter_2                                           => 29,
      Timer_Counter_3                                           => 30,
      Timer_Counter_4                                           => 31,
      Timer_Counter_5                                           => 32,
      Timer_Counter_6                                           => 33,
      Timer_Counter_7                                           => 34,
      Timer_Counter_8                                           => 35,
      Pulse_Width_Modulation_Controller                         => 36,
      Analog_To_Digital_Converter_Controller                    => 37,
      Digital_To_Analog_Converter_Controller                    => 38,
      DMA_Controller                                            => 39,
      USB_Controller                                            => 40,
      True_Random_Number_Generator                              => 41,
      Ethernet_MAC                                              => 42,
      CAN_Controller_0                                          => 43,
      CAN_Controller_1                                          => 44);

end BBF.HPL;
