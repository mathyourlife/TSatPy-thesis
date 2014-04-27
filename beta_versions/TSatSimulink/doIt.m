

TSsock=tsat_init(9877,'192.168.3.126');

%Determine Run Mode 
%   0 = shutdown system
%   1 = running
%   2 = set fan voltages to 0 volts
tsat_send_msg(4,{uint8(0)},TSsock);

%tsat_send_msg(18,{[0,0,0,0]},TSsock);%Send command to fans
%Request sensor data
%tsat_send_msg(33,{[10]},TSsock);     %set sample rate
%tsat_send_msg(19,{uint8(0)},TSsock); %start/stop recording
%tsat_send_msg(21,{uint8(0)},TSsock); %retrieve data from file

p = 0;
plah = 0;
pause(.1);
while(p < 8)
 p = p+1;
 plah =  tsat_recv_msg(TSsock)
end
clear pnet;