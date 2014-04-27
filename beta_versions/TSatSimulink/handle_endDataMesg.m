function msg_data = handle_endDataMesg(flags,sock)

global TSgui tsat_msg_waits 

display('***********Reading pnet acknowledge data')
theMesg=pnet(sock,'read',1,'char','intel');

msgNum = ceil(theMesg)
display('***********Returning pnet acknowledge data')
tsat_msg_waits(msgNum)=0;

%if (msgNum==6)
%    if (TSgui.controllerOn)
%        set(TSgui.controlButton,'Value',0.0);
%        disp('Setting button to 0');
%    else
%        set(TSgui.controlButton,'Value',1.0);
%        disp('Setting button to 1');
%    end
%end

msg_data = 1;
