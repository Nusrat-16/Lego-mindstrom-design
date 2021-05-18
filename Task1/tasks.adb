with NXT.AVR;		      use NXT.AVR;
with Nxt.Display;             use Nxt.Display;

package body Tasks is

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
	task HelloworldTask is
      -- define its priority higher than the main procedure --
      pragma Storage_Size (4096); --  task memory allocation --
	end HelloworldTask;

	task body HelloworldTask is
      Next_Time : Time := Time_Zero;
      LS:Light_Sensor:= make (Sensor_3,true);
	begin      
      -- task body starts here ---
		put_noupdate("helloworld");
		New_Line;
	delay until Next_Time+Milliseconds(3000);

      loop
         -- read light sensors and print ----

			Put_noupdate(LS.Light_Value);
			New_Line;

				if NXT.AVR.Button = Power_Button then
				Power_Down;
				end if;
				Next_Time := Next_Time + Period_Display;
		delay until Next_Time;
      end loop;
   end HelloworldTask;
    
end Tasks;
