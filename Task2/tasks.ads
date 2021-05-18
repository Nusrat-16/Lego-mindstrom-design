-- For Light Sensor --
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
-- For touch Sensor and motors
with NXT.Touch_Sensors; use NXT.Touch_Sensors;
with NXT.Motors.Simple; use NXT.Motors.Simple;
with NXT.Motors.Simple.Ctors; use NXT.Motors.Simple.Ctors;
with NXT.Motor_Encoders; use NXT.Motor_Encoders;


-- Add required sensor and actuator package

package Tasks is
   procedure Background;
   
   
private
   -- Define periods and times --
   Clock_Time : Time := Clock;
   FirstPeriod : Ada.Real_Time.Time_Span := Milliseconds(100);
   SecondPeriod : Ada.Real_Time.Time_Span := Milliseconds(1000);
   -- Define used sensor ports --
   Light_Sensor1 : Light_Sensor := Make(Sensor_1, Floodlight_On => True);
   Bumper : Touch_Sensor (Sensor_3);
   -- Motor Sensors --
   Right Motor_B : Simple_Motor := Make(Motor_B);
   Left Motor_A : Simple_Motor := Make(Motor_A);
   Touch Button: Boolean:=false;
   
   Event_Id: Integer := 0;
   -- for looping
   Count : Integer := 0;
end Tasks;