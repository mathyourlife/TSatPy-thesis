function timerManager(args)
	if (nargin == 0); args = struct; end
	
	try
		action = args.action;
	catch
		action = '';
	end
	
	try
		name = args.name;
	catch
		name = '';
	end
	
	
	if(strcmp(action,'init'))
		initializeTimers();
	elseif(strcmp(action,'start'))
		if (strcmp('all',name))
			timerObjs = timerfindall;
			for a=1:size(timerObjs,2)
				start(timerObjs(a));
			end
		else
			args = struct; args.name = name;
			r = findTimerByName(args);
			if (r.status); timerObj = r.val; else return; end
			if (strcmp('off',get(timerObj,'Running')))
				start(timerObj);
				disp([name ' ....Started'])
			else
				disp([name ' ....Already running'])
			end
		end
	elseif(strcmp(action,'stop'))
		if (strcmp('all',name))
			timerObjs = timerfindall;
			for a=1:size(timerObjs,2)
				stop(timerObjs(a));
			end
		else
			args = struct; args.name = name;
			r = findTimerByName(args);
			if (r.status); timerObj = r.val; else return; end
			stop(timerObj);
			disp([name ' ....Stopped'])
		end
	elseif(strcmp(action,'delete'))
		if (strcmp('all',name))
			delete(timerfindall);
		else
			args = struct; args.name = name;
			r = findTimerByName(args);
			if (r.status); timerObj = r.val; else return; end
			delete(timerObj);
		end
	end
end

function initializeTimers()
	
	%Clear all timers from the system so none are duplicated
	delete(timerfindall);
	
	% Add timer to regularly update the estimator's state
	newTimer = timer;
	set(newTimer,'Name','Sensor->Estimator','ExecutionMode','FixedSpacing', ...
		'TimerFcn','Sensor2Estimator','Period',0.1);

	% Add timer to mock send new voltages from the buffer to the sensor object.
	% This should be performed by check buffer eventually
	newTimer = timer;
	set(newTimer,'Name','updateEstimatorStateModel','ExecutionMode','FixedSpacing', ...
		'TimerFcn','updateEstimatorStateModel','Period',0.3);

	% Add timer to update the Measured state model
	newTimer = timer;
	set(newTimer,'Name','Sensor->Model','ExecutionMode','FixedSpacing', ...
		'TimerFcn','Sensor2Model','Period',0.3);

	% Add timer to mock send new voltages from the buffer to the sensor object.
	% This should be performed by check buffer eventually
	newTimer = timer;
	set(newTimer,'Name','Buffer->Sensor','ExecutionMode','FixedSpacing', ...
		'TimerFcn','Buffer2Sensor','Period',0.1);

	% 
	newTimer = timer;
	set(newTimer,'Name','State->Graph','ExecutionMode','FixedSpacing', ...
		'TimerFcn','State2Graph','Period',0.1);

	newTimer = timer;
	set(newTimer,'Name','Sensor->Graph','ExecutionMode','FixedSpacing', ...
		'TimerFcn','Sensor2Graph','Period',0.5);

	newTimer = timer;
	set(newTimer,'Name','Estimator->Model','ExecutionMode','FixedSpacing', ...
		'TimerFcn','Estimator2Model','Period',0.5);
end

function timerObj = findTimerByName(args)
	if (nargin == 0); args = struct; end
	
	try
		name = args.name;
	catch
		name = '';
	end
	
	timerObj = timerfind('Name',name);
	if (strcmp(class(timerObj),'timer'))
		timerObj = {true, timerObj};
	else
		timerObj = {false};
	end
	
end