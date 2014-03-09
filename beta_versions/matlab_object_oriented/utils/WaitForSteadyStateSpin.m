function stable = WaitForSteadyStateSpin()

	stable = 0;
	threshold = 0.003;
	gyro_last_volt = [1 10 100 1000 100000];
	disp('Checking for stable spin rate')

	while (stable == 0)
		%Check every 4 seconds
		pause(4)

		%Request sensor data and wait.
		[msg_num, msg_data] = SendCommandAndWait(20,0,63);

		%Calculate slope of the last five gyro readings.
		x=zeros(1,size(gyro_last_volt,2));
		for n=1:size(gyro_last_volt,2)
			x(n) = n;  %populate x vector for polyfit size of gyro recordings
		end
		p=polyfit(x,gyro_last_volt,1);
		reply = sprintf('Stable spin metric: %0.4f',p(1));
		disp(reply)

		if abs(p(1)) < threshold
			%Gyro shows an acceleration approaching zero over the last 
			%4 seconds. Stop the timer and move to analysis.
			
			%Stop the timer and move on to the next calibration step.
			stable = 1;
			return;
		else
			%Bump values for moving average.
			for n=1:size(gyro_last_volt,2)-1
				gyro_last_volt(n) = gyro_last_volt(n+1);
			end
			gyro_last_volt(size(gyro_last_volt,2))=msg_data(12);
		end

	end
