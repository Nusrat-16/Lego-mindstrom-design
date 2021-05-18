with Ada.Real_Time; use Ada.Real_Time;
with System;				


package body tasks is

	-- Threshold in which we wanted our robot to have between itself and the robot in front 
	
	Light_offset : Integer := 50;
	-- A distance threshold is used.
	Distance_threshold : constant Integer := 20;
	--Motor_delay : constant Time_Span := Milliseconds(0);
	Light_delay : constant Time_Span := Milliseconds(5);
	Distance_delay : constant Time_Span := Milliseconds(5);
	 Max_speed: constant Float := 40.0;
	Min_speed : constant Float := 0.0;

	
	-- Delay for the calibration of light sensor
	Timedelay : Time_Span := Milliseconds(500);
	Run : Boolean := false;



   	-- protected object to safely set driving command record
   	protected body driving_command is

    	function Get return driving_command_type is begin return dr; end Get;
		
		procedure Set_Turn(newdr : driving_command_type) is
		begin
			dr.Right_Shaft := newdr.Right_Shaft;
			dr.Left_Shaft := newdr.Left_Shaft;
		end Set_Turn;
		

		procedure Set_Speed(newdr : driving_command_type) is
		begin
			dr.speed := newdr.speed;
		end Set_Speed;

   	end driving_command;
      
   ----------------------------
   --  Background procedure  --
   ----------------------------
   procedure Background is
   begin
    loop
        null;
    end loop;
   end Background;

      
	-------------
	--  Tasks  --
	-------------
-- For calibrating the light sensor 
	task Calibration is
		pragma Priority(9);
		-- program is too big to upload so storaze size is reduced to half
		pragma Storage_Size(2048);
	end Calibration;


	-- Calibration
	-- Need to calibrate before motor become active.
	task body Calibration is
      	ts : Touch_Sensor(Sensor_1);
		ls : Light_Sensor := Make(Sensor_3, true);
		
		pressed : Boolean := false;
	begin
		pressed := false;
			delay until Clock + Timedelay;

		put_noupdate("Press button for");
		newline;
		put_noupdate("Offset");
		newline;
		while not pressed loop
			pressed := NXT.Touch_Sensors.Pressed(ts);
		end loop;
		Light_offset:= ls.Light_value;
		pressed := false;
			put_noupdate("See the magic!");
		newline;
		delay until Clock + Timedelay + Timedelay;


		-- A Global variable is used for motorcontrol 
		Run := True;

	end Calibration;




	task Test_Light_Sensor is
		pragma Priority (PRIO_TURN_CONTROL);
		pragma Storage_Size(2048);
		

	end Test_Light_Sensor;

	task body Test_Light_Sensor is
		on_track : boolean := true;
		light_value : Integer;
		ls : Light_Sensor := make(Sensor_3, true);
		light_error : Float;
		turn : float;
		dr : driving_command_type;

	begin

		while not Run loop
			delay until clock + Timedelay;
		end loop;
		loop
			dr := driving_command.Get;
			light_value := ls.Light_value;
			light_error := Float(light_value-Light_offset);
			-- A P-Controller is used.
			-- Followed the psedo code for p-controller.
			-- Error is the difference between pre declered offset value and light value
			--for every 1 unit error change ,the power of one motor will be increased by 10.
			--A multiplier is used to get a optimum turn-ratio
			
			if light_error < -0.0 then
				turn := light_error * 0.05;
				---the motors will stop Running if the turn ratio is more than 1.0
				if turn < -0.9 then turn := -0.9; end if;
					dr.Right_Shaft := 1.0;
				dr.Left_Shaft := 1.0 + turn;
			    driving_command.Set_Turn(dr); 
			elsif light_error > 0.0 then
				turn := (light_error + 10.0) * 0.05;
				 --the motors will stop Running if the turn ration is more than 1.0
				if turn > 0.9 then turn := 0.9; end if;
				dr.Left_Shaft := 1.0;
				dr.Right_Shaft := 1.0 - turn;
				driving_command.Set_Turn(dr);

			end if;

			delay until Clock + Light_delay;
		end loop;
	end Test_Light_Sensor;




	task Motorcontrol is
		pragma Priority (PRIO_ENGINE);
		pragma Storage_Size(2048);
	end Motorcontrol;

	task body Motorcontrol is
			Left_Motor_ID : constant Motor_Id := Motor_A;
		Right_Motor_ID : constant Motor_Id := Motor_B;
        
		Left_Power : Power_percentage;
		Right_Power : Power_percentage;
		  dr : driving_command_type;

	begin

		while not Run loop
			delay until clock + Timedelay;
		end loop;
	   	loop
	    	dr := driving_command.Get;
			Left_Power := Power_percentage (dr.Speed * dr.Left_Shaft);
			Right_Power := Power_percentage (dr.Speed * dr.Right_Shaft);
			
			Control_Motor(Left_Motor_ID, Left_Power, Forward);

			Control_Motor(Right_Motor_ID, Right_Power, Forward);
			

	   	end loop;
	end Motorcontrol;




	task Distancecontrol is
		pragma Priority (PRIO_DIST_CONTROL);
	   	pragma Storage_Size(2048);
	end Distancecontrol;

	task body Distancecontrol is
		
		us : Ultrasonic_Sensor := NXT.Ultrasonic_Sensors.Ctors.Make(Sensor_2);
		Weight_multiplier: Integer;
		distance_error : Integer;
			value : Natural;
		dr : driving_command_type;
	begin
		dr := driving_command.Get;
	    loop
			NXT.Ultrasonic_Sensors.Set_Mode(us, Ping);
			NXT.Ultrasonic_Sensors.Get_Distance(us, value);


			-- a P-controller is used to determine the speed.
			--a Weight_multiplier is used here to  de-/accelerate speed proportional
			-- Here distance_error is obtained from predefined distance value and the object infront.
			distance_error := value - Distance_threshold;
			if distance_error > Distance_threshold then distance_error := Distance_threshold; end if;

			if distance_error < 0 then
				Weight_multiplier := 10;
			else
				Weight_multiplier := 1;
			end if;
			dr.Speed := dr.Speed + Float (distance_error * Weight_multiplier);

			if dr.Speed < Min_speed then dr.Speed := Min_speed; end if;
			if dr.Speed > Max_speed then dr.Speed := Max_speed; end if;

			driving_command.Set_Speed(dr);
			delay until Clock + Distance_delay;

	    end loop;
	end Distancecontrol;
   

end tasks;
