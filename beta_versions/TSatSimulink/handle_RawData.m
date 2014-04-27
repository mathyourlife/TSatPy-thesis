function msg_data = handle_uplinkRawData(flags,sock)

global tsat_msg_waits oldRawT oldRawCSS oldRawTAM oldRawRate oldRawFan TSgui

% Read the data out of the receive buffer
display('***********Reading pnet raw data')
msg_data=pnet(sock,'read',15,'double','intel')
display('***********Returning pnet raw data')
return;

% If not showing the data, just return
%if (~TSgui.showData(2))
%    handleErr=0;
%    return
%end

% Otherwise, draw the graphs
figure(2);
if (TSgui.firstTime(2))
    oldRawT =    x(1);
    oldRawCSS=  x(2:5);
    oldRawRate= x(6);
    oldRawTAM= x(7:9);
    oldRawFan = x(10:11);
    clf;
end

subplot(4,1,1);
line([oldRawT;x(1)],[oldRawCSS;x(2:5)]);
subplot(4,1,2);
line([oldRawT;x(1)],[oldRawTAM;x(7:9)]);
subplot(4,1,3);
line([oldRawT;x(1)],[oldRawRate;x(4)]);
subplot(4,1,4);
line([oldRawT;x(1)],[oldRawFan;x(10:11)]);

if (TSgui.firstTime(2))
    subplot(4,1,1); legend('CSS1','CSS2','CSS3','CSS4',3);
    subplot(4,1,2); legend('TAMX','TAMY','TAMZ',3);
    subplot(4,1,3); legend('Gyro',3);
    subplot(4,1,4); legend('Fan1','Fan2',3);
    hold on;
    TSgui.firstTime(2)=0;
end

oldRawT = x(1);
oldRawCSS=x(2:5);
oldRawTAM=x(7:9);
oldRawRate=x(6);
oldRawFan=x(10:11);

tsat_msg_waits(84) = 0;                   % This is answer to msg #81
tsat_send_msg(84,{uint8(0)},sock);    % Request more yummy data

handleErr = 0;

