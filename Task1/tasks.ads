with Ada.Real_Time;       use Ada.Real_Time;
with NXT;                 use NXT;
-- Add required sensor and actuator package --

with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
package Tasks is

   procedure Background;

   private

   --  Define periods and times  --
      Period_Display : Time_Span := Milliseconds(500); 
      Time_Zero : Time := Clock;
     --light_value:Integer:=0;

   --  Define used sensor ports  --
		LS:Light_Sensor:= make(Sensor_3,true);
 

end Tasks;
