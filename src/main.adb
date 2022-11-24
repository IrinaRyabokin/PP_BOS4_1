with Ada.Text_IO; use Ada.Text_IO;

procedure main is
   NumElements : constant := 100000;
   NumThreads  : constant := 16;
   type my_array is array (1 .. NumElements) of Long_Long_Integer;

   a : my_array;

   function part_sum (left : Integer; Right : Integer) return Long_Long_Integer
   is
      sum : Long_Long_Integer := 0;
      i   : Integer;
   begin
      i := left;
      while i <= Right loop
         sum := sum + a (i);
         i   := i + 1;
      end loop;
      return sum;
   end part_sum;

   procedure create_array is
   begin
      for i in a'Range loop
         a (i) := Long_Long_Integer (i);
      end loop;
   end create_array;

   task type my_task is
      entry start (left, Right : in Integer);
      entry finish (sum1 : out Long_Long_Integer);
   end my_task;

   task body my_task is
      left, Right : Integer;
      sum         : Long_Long_Integer := 0;
   begin
      accept start (left, RigHt : in Integer) do
         my_task.left  := left;
         my_task.right := Right;
      end start;

      sum := part_sum (left, Right);
      accept finish (sum1 : out Long_Long_Integer) do
         sum1 := sum;
      end finish;

   end my_task;

   tasks : array (1 .. NumThreads) of my_task;

   sum_singlethread     : Long_Long_Integer;
   sum_multithread : Long_Long_Integer;

   part_begin     : array (1 .. NumThreads) of Integer;
   part_end       : array (1 .. NumThreads) of Integer;
   part_sum_value : Long_Long_Integer;
begin
   create_array;
   sum_singlethread := part_sum (a'First, a'Last);

   Put_Line ("Single-thread sum: " & sum_singlethread'Img);

   for i in part_begin'Range loop
      part_begin (i) := a'First + (a'Last - a'First) * (i - 1) / NumThreads;
   end loop;

   for i in part_end'Range loop
      if i < part_end'Last then
         part_end (i) := part_begin (i + 1) - 1;
      else
         part_end (i) := a'Last;
      end if;
   end loop;

   for i in tasks'Range loop
      tasks (i).start (part_begin (i), part_end (i));
   end loop;

   sum_multithread := 0;
   for i in tasks'Range loop
      tasks (i).finish (part_sum_value);
      sum_multithread := sum_multithread + part_sum_value;
   end loop;

   Put_Line ("Multi-thread sum: " & sum_multithread'Img);

end main;
