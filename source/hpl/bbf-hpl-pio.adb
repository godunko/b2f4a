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

package body BBF.HPL.PIO is

   -----------
   -- Clear --
   -----------

   procedure Clear (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.CODR :=
        (As_Array => True,
         Arr      => BBF.HRI.PIO.PIOA_CODR_P_Field_Array (Mask));
   end Clear;

   ----------
   -- PIOA --
   ----------

   function PIOA return PIO is
   begin
      return BBF.HRI.PIO.PIOA_Periph'Access;
   end PIOA;

   ----------
   -- PIOB --
   ----------

   function PIOB return PIO is
   begin
      return BBF.HRI.PIO.PIOB_Periph'Access;
   end PIOB;

   ----------
   -- PIOC --
   ----------

   function PIOC return PIO is
   begin
      return BBF.HRI.PIO.PIOC_Periph'Access;
   end PIOC;

   ----------
   -- PIOD --
   ----------

   function PIOD return PIO is
   begin
      return BBF.HRI.PIO.PIOD_Periph'Access;
   end PIOD;

   ---------
   -- Set --
   ---------

   procedure Set (Base : PIO; Mask : PIO_Pin_Array) is
   begin
      Base.SODR :=
        (As_Array => True,
         Arr      => BBF.HRI.PIO.PIOA_SODR_P_Field_Array (Mask));
   end Set;

   ----------------
   -- Set_Output --
   ----------------

   procedure Set_Output
     (Base       : PIO;
      Mask       : PIO_Pin_Array;
      Default    : Boolean := True;
      Multidrive : Boolean := False) is
   begin
      --  Enable multi-drive if necessary

      if Multidrive then
         Base.MDER :=
           (As_Array => True,
            Arr      => BBF.HRI.PIO.PIOA_MDER_P_Field_Array (Mask));

      else
         Base.MDDR :=
           (As_Array => True,
            Arr      => BBF.HRI.PIO.PIOA_MDDR_P_Field_Array (Mask));
      end if;

      --  Set default value

      if Default then
         Set (Base, Mask);

      else
         Clear (Base, Mask);
      end if;

      --  Configure as output and enable control of PIO

      Base.OER.Arr := BBF.HRI.PIO.PIOA_OER_P_Field_Array (Mask);
      Base.PER.Arr := BBF.HRI.PIO.PIOA_PER_P_Field_Array (Mask);
   end Set_Output;

   --------------------
   -- Set_Peripheral --
   --------------------

   procedure Set_Peripheral
     (Base : PIO;
      Mask : PIO_Pin_Array;
      To   : Peripheral_Function)
   is
      use type BBF.HRI.PIO.PIOA_ABSR_P_Field_Array;

   begin
      --  Disable interrupts on the pin(s)

      Base.IDR.Arr := BBF.HRI.PIO.PIOA_IDR_P_Field_Array (Mask);

      --  Set peripheral function

      case To is
         when A =>
            Base.ABSR.Arr :=
              Base.ABSR.Arr and not BBF.HRI.PIO.PIOA_ABSR_P_Field_Array (Mask);

         when B =>
            Base.ABSR.Arr :=
              Base.ABSR.Arr or BBF.HRI.PIO.PIOA_ABSR_P_Field_Array (Mask);
      end case;

      --  Remove the pins from under the control of PIO

      Base.PDR.Arr := BBF.HRI.PIO.PIOA_PDR_P_Field_Array (Mask);
   end Set_Peripheral;

end BBF.HPL.PIO;
