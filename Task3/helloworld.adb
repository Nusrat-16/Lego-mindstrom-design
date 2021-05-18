with Tasks;
with System;

procedure helloworld is
   pragma Priority (System.Priority'First);
   
begin
   Tasks.Background;
--   Tasks.Event.Wait();
end helloworld;

