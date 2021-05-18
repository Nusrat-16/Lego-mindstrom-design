
with Ada.Real_Time; use Ada.Real_Time;
with System;
package body tasks is
period_Length: Time_Span;
Period_Button:constant Time_Span :=Milliseconds(50);
Distance_Threshold:Constant Integer:= 20;
TIMEOUT:Constant Time_Span:=Milliseconds(500);
SPEED_STOP:Constant float:=0.0;
SPEED_Full:Constant float:=60.0;
Run:Boolean:=False;
DELAY_DIST:Constant Time_Span:=Milliseconds(50);
protected body driving_command is

     function Get return driving_command_type is begin return dr; end Get;

 procedure Set_Speed(ndr : driving_command_type) is
 begin
  dr.speed := ndr.speed;
 end Set_Speed;

 procedure Set_Override(ndr : driving_command_type) is
 begin
  dr.Right_Prop := ndr.Right_Prop;
  dr.Left_Prop := ndr.Left_Prop;
 end Set_Override;

    end driving_command;

     procedure Background is
   begin
    loop
        null;
    end loop;
   end Background;

   task MotorcontrolTask is
 pragma Priority (PRIO_IDLE);
 pragma Storage_Size(2048);
end MotorcontrolTask;

task body MotorcontrolTask is
 Right_Motor_ID : constant Motor_Id := Motor_B;
 Left_Motor_ID : constant Motor_Id := Motor_A;
        subtype Natural  is Integer range 0 .. Integer'Last;
    dr : driving_command_type;
 Left_Effect : Power_percentage;
 Right_Effect : Power_percentage;
    
begin

 while not RUN loop
  delay until Clock + TIMEOUT;
 end loop;
    loop
     dr := driving_command.Get;
 
  Left_Effect := Power_percentage (dr.Speed * dr.Left_Prop);
  Right_Effect := Power_percentage (dr.Speed * dr.Right_Prop);
  Control_Motor(Right_Motor_ID, Right_Effect, Forward);
  Control_Motor(Left_Motor_ID, Left_Effect, Forward);
  period_Length := period_Length - Milliseconds(50);
  
 end loop;
end MotorcontrolTask;

task buttonpress is
pragma Priority (System.Priority'First + 2);
      pragma Storage_Size (2048);
  end buttonpress;
  task body buttonpress is
     ts : Touch_Sensor(Sensor_3);
     pressed : Boolean := false;
    Right_Motor_ID : constant Motor_Id := Motor_B;
    Left_Motor_ID : constant Motor_Id := Motor_A;
    Left_Effect : Power_percentage;
    Right_Effect : Power_percentage;
     Run := True;
  begin
   pressed := false;
   delay until Clock+TIMEOUT;
  Loop
      if Pressed  then
       Control_Motor(Right_Motor_ID, Right_Effect, Backward);
        Control_Motor(Left_Motor_ID, Left_Effect, Backward);
     end if;
	 delay until Clock + Milliseconds (10);
  end loop;
end buttonpress;
   
 task Display is
      pragma Priority (System.Priority'First + 2);
      pragma Storage_Size (2048);
end Display;
task body Display is
      Next_Time :Constant Time_Span:= Milliseconds(5);
   begin
      loop
         delay until Clock + Milliseconds (10);
         Clear_Screen_Noupdate;
         Set_Pos (0,0);
         Put_Noupdate ("   vehicle_v12");
         Newline_Noupdate;
         Put_Noupdate ("    running...");
      end loop;
end Display;


task DistanceTask is
 pragma Priority (PRIO_DIST_CONTROL);
    pragma Storage_Size(2048);
end DistanceTask;

task body DistanceTask is
		dr : driving_command_type;
		us : Ultrasonic_Sensor := NXT.Ultrasonic_Sensors.Ctors.Make(Sensor_2);
		val : Natural;
		dist_error : Integer;
		Weight : Integer;
	begin
	dr := driving_command.Get;
    loop
	NXT.Ultrasonic_Sensors.Set_Mode(us, Ping);
	NXT.Ultrasonic_Sensors.Get_Distance(us, val);


  -- Speed is determined by a P-controller along with a weight multiplier so that we de-/accelerate proportional
  -- to the distance of the object in front
  dist_error := val - DISTANCE_THRESHOLD;
	if dist_error > DISTANCE_THRESHOLD then dist_error := DISTANCE_THRESHOLD; end if;

	if dist_error < 0 then
	Weight := 10;
	else
	Weight := 1;
	end if;
	dr.Speed := dr.Speed + Float (dist_error * Weight);

	if dr.Speed < SPEED_STOP then dr.Speed := SPEED_STOP; end if;
	if dr.Speed > SPEED_FULL then dr.Speed := SPEED_FULL; end if;

	driving_command.Set_Speed(dr);
	delay until Clock + DELAY_DIST;

	end loop;
  end DistanceTask;
end tasks;
