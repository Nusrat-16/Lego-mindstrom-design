with NXT;               use NXT;
with NXT.AVR;          use NXT.AVR;
with Nxt.Display;           use Nxt.Display;
with ADA.Real_time;      use ADA.Real_time;
--with NXT.Light_Sensors;  --use NXT.Light_Sensors;
--with NXT.Light_Sensors.Ctors; --use NXT.Light_Sensors.Ctors;
with NXT.Motor_Controls;   use NXT.Motor_Controls;
with NXT.Touch_Sensors;   use NXT.Touch_Sensors;
with NXT.Ultrasonic_Sensors;  use NXT.Ultrasonic_Sensors;
with NXT.Ultrasonic_Sensors.Ctors; use NXT.Ultrasonic_Sensors.Ctors;


package tasks is
PRIO_IDLE : constant Integer := 1;
PRIO_BUTTON : constant Integer := 3;
PRIO_DIST_CONTROL: constant Integer:=4;
PRIO_DRIVING_COMMAND : constant Integer := 5;

  type driving_command_type is record
        Left_Prop : Float;
    Right_Prop : Float;
    Speed : Float;
    end record;
 
    protected driving_command is
        pragma Priority(PRIO_DRIVING_COMMAND);
    function Get return driving_command_type;
        procedure Set_Speed(ndr : driving_command_type);
        procedure Set_override(ndr : driving_command_type);

    private
        dr : driving_command_type :=
            (
            Left_Prop => 0.5,
            Right_Prop => 1.0,
            Speed => 50.0
            );
        end driving_command;
procedure Background;
end tasks;
