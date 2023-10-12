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

pragma Restrictions (No_Elaboration_Code);

package body BBF.ADT.Generic_MPMC_Bounded_Queues is

   use type Atomic_Primitives.Mem_Model;

   function cmpexch_failure_order2
     (M : Atomic_Primitives.Mem_Model) return Atomic_Primitives.Mem_Model;

   function Index (Self : Queue; Item : Index_Type) return Index_Type;

   function Turn (Self : Queue; Item : Index_Type) return Index_Type;

   procedure Store
     (Item  : aliased Atomic_Index_Type;
      Value : Index_Type;
      Model : Atomic_Primitives.Mem_Model);

   generic
      type Atomic_Type is mod <>;
   procedure Atomic_Store
     (Ptr   : System.Address;
      Val   : Atomic_Type;
      Model : Atomic_Primitives.Mem_Model);
   pragma Import (Intrinsic, Atomic_Store, "__atomic_store_4");
   --  Not provided by System.Atomic_Primitives.

   ----------------------------
   -- cmpexch_failure_order2 --
   ----------------------------

   function cmpexch_failure_order2
     (M : Atomic_Primitives.Mem_Model) return Atomic_Primitives.Mem_Model is
   begin
      return
        (if M = Atomic_Primitives.Acq_Rel
           then Atomic_Primitives.Acquire
           elsif M = Atomic_Primitives.Release
             then Atomic_Primitives.Relaxed
             else M);
   end cmpexch_failure_order2;

   -----------------------------
   -- Compare_Exchange_Strong --
   -----------------------------

   function Compare_Exchange_Strong
     (Item      : aliased Atomic_Index_Type;
      Old_Value : aliased Index_Type;
      New_Value : Index_Type;
      M_Order   : Atomic_Primitives.Mem_Model := Atomic_Primitives.Seq_Cst)
      return Boolean
   is
      function Internal is
        new Atomic_Primitives.Atomic_Compare_Exchange (Index_Type);

   begin
      return
        Internal
          (Item'Address,
           Old_Value'Address,
           New_Value,
           False,
           M_Order,
           cmpexch_failure_order2 (M_Order));
   end Compare_Exchange_Strong;

   -------------
   -- Enqueue --
   -------------

   function Enqueue
     (Self : in out Queue;
      Data : Data_Type) return Boolean
   is
      pragma Suppress (All_Checks);

      Head      : aliased Index_Type;
      Prev_Head : aliased Index_Type;

   begin
      Head := Load (Self.Head, Atomic_Primitives.Acquire);

      loop
         declare
            Slot : Slot_Type renames Self.Slots (Index (Self, Head));

         begin
            if Turn (Self, Head) * 2
                  = Load (Slot.Turn, Atomic_Primitives.Acquire)
            then
               if Compare_Exchange_Strong (Self.Head, Head, Head + 1) then
                  Slot.Storage := Data;
                  Store
                    (Slot.Turn,
                     Turn (Self, Head) * 2 + 1,
                     Atomic_Primitives.Release);

                  return True;
               end if;

            else
               Prev_Head := Head;
               Head      := Load (Self.Head, Atomic_Primitives.Acquire);

               if Head = Prev_Head then
                  return False;
               end if;
            end if;
         end;
      end loop;
   end Enqueue;

   -----------
   -- Index --
   -----------

   function Index (Self : Queue; Item : Index_Type) return Index_Type is
   begin
      return Item mod Self.Capacity;
   end Index;

   ----------
   -- Load --
   ----------

   function Load
     (Item  : aliased Atomic_Index_Type;
      Model : Atomic_Primitives.Mem_Model := Atomic_Primitives.Seq_Cst)
      return Index_Type
   is
      function Internal is new Atomic_Primitives.Atomic_Load (Index_Type);

   begin
      return Internal (Item'Address, Model);
   end Load;

   -----------
   -- Store --
   -----------

   procedure Store
     (Item  : aliased Atomic_Index_Type;
      Value : Index_Type;
      Model : Atomic_Primitives.Mem_Model)
   is
      procedure Internal is new Atomic_Store (Index_Type);

   begin
      Internal (Item'Address, Value, Model);
   end Store;

   -------------
   -- Try_Pop --
   -------------

   function Dequeue
     (Self : in out Queue;
      Item : out Data_Type) return Boolean
   is
      Tail      : aliased Index_Type;
      Prev_Tail : Index_Type;

   begin
      Tail := Load (Self.Tail, Atomic_Primitives.Acquire);

      loop
         declare
            Slot : Slot_Type renames Self.Slots (Index (Self, Tail));

         begin
            if Turn (Self, Tail) * 2 + 1
                 = Load (Slot.Turn, Atomic_Primitives.Acquire)
            then
               if Compare_Exchange_Strong (Self.Tail, Tail, Tail + 1) then
                  Item := Slot.Storage;
                  Store
                    (Slot.Turn,
                     Turn (Self, Tail) * 2 + 2,
                     Atomic_Primitives.Release);

                  return True;
               end if;
            else
               Prev_Tail := Tail;
               Tail      := Load (Self.Tail, Atomic_Primitives.Acquire);

               if Tail = Prev_Tail then
                  return False;
               end if;
            end if;
         end;
      end loop;
   end Dequeue;

   ----------
   -- Turn --
   ----------

   function Turn (Self : Queue; Item : Index_Type) return Index_Type is
   begin
      return Item / Self.Capacity;
   end Turn;

end BBF.ADT.Generic_MPMC_Bounded_Queues;
