with Tasks;
with System;

procedure Helloworld is
   pragma Priority (System.Priority'First);
   
begin
   Tasks.Background;
--   Tasks.Event.Wait();
end Helloworld;

