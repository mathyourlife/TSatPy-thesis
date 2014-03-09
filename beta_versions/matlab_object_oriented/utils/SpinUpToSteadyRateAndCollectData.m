function [data, normal] = SpinUpToSteadyRateAndCollectData(fan_volt,collection_time)

stage = 0;
disp('Overcoming static friction')
[msg_num, msg_data] = SendCommandAndWait(18,[12,0,0,0],118);
pause(20)


while (stage < 99)
    if stage == 0
        
        disp('Sending voltage to CW fan')
        [msg_num, msg_data] = SendCommandAndWait(18,[fan_volt,0,0,0],118);
        
        stage = stage + 1; 
            
    elseif stage == 1
        
		stable = WaitForSteadyStateSpin();
		if stable == 1
			stage = stage + 1;
		end 
		
	elseif stage == 2
		disp('Collecting steady spin data')
		%Set and confirm start of sensor collection.
		[msg_num, msg_data] = SendCommandAndWait(19,1,119);
		pause(collection_time)
		stage = stage + 1; 
            
	elseif stage == 3
        
		disp('Retrieving steady spin data')
		%Set and confirm end sensor collection.
		[msg_num, msg_data] = SendCommandAndWait(19,0,119);
		[msg_num, msg_data] = SendCommandAndWait(18,[0,0,0,0],118);
 		data = RetrieveSensorLog();
		plot_sensors(data(:,2:end))
		normal = plotTAM3D(data(:,14:16));
		stage = stage + 1;
		
	elseif stage == 4
        reply = input('Acceptable results? (1 for yes, 0 for no) ');
        if reply == 1
			stage = stage + 1; 
		elseif reply == 0
			disp('I apologize... doing it over')
			stage = 0;
        end
		
	else
		stage = stage + 1;
		
	end


end