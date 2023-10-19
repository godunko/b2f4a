------------------------------------------------------------------------------
--                                                                          --
--                           Bare Board Framework                           --
--                                                                          --
--                           Abstract Data Types                            --
--                                                                          --
------------------------------------------------------------------------------
--
--  Copyright (C) 2023, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package provides lock free implementation of Multiple Providers
--  Multible Consumers Bounded Queue.

pragma Restrictions (No_Elaboration_Code);

generic
   type Data_Type is private;

package BBF.ADT.Generic_MPMC_Bounded_Queues is

   pragma Pure;

   type Index_Type is mod 2 ** 32;

   type Queue (Capacity : Index_Type) is limited private;

   function Enqueue
     (Self : in out Queue;
      Data : Data_Type) return Boolean;

   function Dequeue
     (Self : in out Queue;
      Item : out Data_Type) return Boolean;

private

   --  Atomic_Primitives package contains copy-paste code from
   --  System.Atomic_Primitives package. This package is not provides by RTL.

   package Atomic_Primitives is

      Relaxed : constant := 0;
      Consume : constant := 1;
      Acquire : constant := 2;
      Release : constant := 3;
      Acq_Rel : constant := 4;
      Seq_Cst : constant := 5;
      Last    : constant := 6;

      subtype Mem_Model is Integer range Relaxed .. Last;

      ------------------------------------
      -- GCC built-in atomic primitives --
      ------------------------------------

      generic
         type Atomic_Type is mod <>;
      function Atomic_Load
        (Ptr   : System.Address;
         Model : Mem_Model := Seq_Cst) return Atomic_Type;
      pragma Import (Intrinsic, Atomic_Load, "__atomic_load_n");

      generic
         type Atomic_Type is mod <>;
      function Atomic_Compare_Exchange
        (Ptr           : System.Address;
         Expected      : System.Address;
         Desired       : Atomic_Type;
         Weak          : Boolean   := False;
         Success_Model : Mem_Model := Seq_Cst;
         Failure_Model : Mem_Model := Seq_Cst) return Boolean;
      pragma Import
        (Intrinsic, Atomic_Compare_Exchange, "__atomic_compare_exchange_n");

   end Atomic_Primitives;

   Hardware_Destructive_Interference_Size : constant := 32;
   --  Hardware_Destructive_Interference_Size : constant := 64;

   type Atomic_Index_Type is record
      Value : Index_Type with Volatile;
   end record
     with Object_Size => Index_Type'Size;

   function Load
     (Item  : aliased Atomic_Index_Type;
      Model : Atomic_Primitives.Mem_Model := Atomic_Primitives.Seq_Cst)
      return Index_Type;

   function Compare_Exchange_Strong
     (Item      : aliased Atomic_Index_Type;
      Old_Value : aliased Index_Type;
      New_Value : Index_Type;
      M_Order   : Atomic_Primitives.Mem_Model := Atomic_Primitives.Seq_Cst)
      return Boolean;

   type Aligned_Atomic_Index_Type is new Atomic_Index_Type
     with Alignment => Hardware_Destructive_Interference_Size,
          Size      => 256;

   type Slot_Type is record
      Turn    : aliased Atomic_Index_Type := (Value => 0);
      Storage : Data_Type;
   end record
     with Alignment => Hardware_Destructive_Interference_Size;

   type Slot_Array is array (Index_Type range <>) of aliased Slot_Type;

   type Queue (Capacity : Index_Type) is record
      Head  : aliased Aligned_Atomic_Index_Type;
      Tail  : aliased Aligned_Atomic_Index_Type;

      Slots : aliased Slot_Array (0 .. Capacity);
      --  Allocate one extra slot to prevent false sharing on the last slot
   end record;

end BBF.ADT.Generic_MPMC_Bounded_Queues;
