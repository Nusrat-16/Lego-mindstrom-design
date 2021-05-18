with NXT.AVR; use NXT.AVR;
with NXT.Display; use NXT.Display;
with Ada.Real_Time; use Ada.Real_Time;
-- Light sensors and Touch sensor
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
with NXT.Touch_Sensors; use NXT.Touch_Sensors;


package body Tasks is
   
   --------------------------
   -- Background procedure --
   --------------------------
   
		procedure Background is
			begin
				loop
				null;
				end loop;
		end Background;
   
   ---------------
   -- Protected one --
   ---------------
   
   protected Event is
		entry Wait(Event_Id : out Integer);
		procedure Signal(Event_Id : in Integer);
	private
      Current_Event_Id : Integer; --Event data declaration
      Signalled: Boolean := False; -- This is flag for event signal
   end Event;
   
   protected body Event is
			entry Wait(Event_Id : out Integer) when Signalled is
			begin
			Event_Id := Current_Event_Id;
			Signalled := False;
			end Wait;
 
	procedure Signal (Event_Id : in Integer) is
		begin
			Current_Event_Id := Event_Id;
			Signalled := True;
		end Signal;
   end Event;
   
   
   -----------
   -- Tasks --
   -----------
   
 task Eventdispatcher is
       pragma Storage_Size (4096);
 end Eventdispatcher;

task body Eventdispatcher is
      NextCycle : Time := Clock_Time;
   begin
      loop

		if Count /= 0 and Pressed(Bumper)  then
			NextCycle := NextCycle + SecondPeriod;
			delay until NextCycle;
			Event.Signal(1);
			if(Event_Id = 1) then
			Event.Signal(1);
			elsif Event_Id = 0 then
			Event.Signal(0);
			end if;
		end if;
 
        if Light_Sensor1.Light_Value < 37 then
			Event.Signal(0);
		end if;
		
		if NXT.AVR.Button = Power_Button then
			Event.Signal(2);
		end if;
		Count := Count + 1;
		NextCycle := NextCycle + FirstPeriod;
		delay until NextCycle;
      end loop;
 end Eventdispatcher;

   
 task HelloworldTask is
      pragma Storage_Size (4096); 
 end HelloworldTask;
   
 task body HelloworldTask is
      NextCycle : Time := Clock_Time;
     
	begin
      loop
   
         --Followed some psedo code from drivers.
		Clear_Screen_Noupdate;
       
		Event.Wait(Event_Id);
 
		if Event_Id = 1 then
		Right motor_B.Set_Power (40);
		Left motor_A.Set_Power (40);
		Right motor_B.Forward;
		Left motor_A.Forward; 
		elsif  Event_Id = 0 then
		Right Motor_B.Stop;
		Left Motor_A.Stop;
		Right motor_B.Set_Power(0);
		Left motor_A.Set_Power(0);
		end if;
		if Event_Id = 2 then
		Right motor_B.Stop;
		Left motor_A.Stop;
		Right motor_B.Set_Power(0);
		Left motor_A.Set_Power(0);
		Power_Down;
		end if;
		NextCycle := NextCycle + FirstPeriod;
		delay until NextCycle;
      end loop;
 end HelloworldTask;
   
   
   
end Tasks;
