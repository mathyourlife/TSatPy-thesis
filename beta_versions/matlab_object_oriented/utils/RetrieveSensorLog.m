function data = RetrieveSensorLog()
    %Delete the current sensor log text file
    delete 'sensor_log.txt'
    pause(0.1)

    %Retrieve log size
    [msg_num, msg_data] = SendCommandAndWait(23,0,65);
    log_size = msg_data;
    reply=sprintf('Retrieving %d log entries.',log_size);
    disp(reply)
	
	progress = 0;
    for i=1:log_size
        [msg_num, msg_data] = SendCommandAndWait(23,i,64);

		if i/log_size*100 > progress
			progress = progress + 10;
		    reply=sprintf('%d%%',progress);
		    disp(reply)
			
		end
        data_list='';
        for n=1:length(msg_data)
            if n==1
                data_list = [num2str(msg_data(n))];
            else
                data_list = [data_list ' ' num2str(msg_data(n))];
            end
        end

        fid = fopen('sensor_log.txt','a');
        fprintf(fid,data_list);
        fprintf(fid,'\n');
        fclose(fid);
    end
    [data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
