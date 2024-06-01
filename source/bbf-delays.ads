--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package provides capability to do delays in the application.
--  Depending of the timer configuration and tasking support its behavior
--  may vary.
--
--  This package should not be used inside exception handler to do delays.

with A0B.Time;

package BBF.Delays
  with Preelaborate
is

   procedure Delay_For (Interval : A0B.Time.Time_Span);
   --  Delay execution for given amount of time.

end BBF.Delays;
