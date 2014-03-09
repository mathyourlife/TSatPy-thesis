function cmd(varargin)
	global tsat
	
	% Check if the arguments include a ?
	if (arrContainsText(varargin,'?'))
		printOnly = true;
	else
		printOnly = false;
	end
	
	check={'init'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Initializing TableSat Instance')
		init;
		return;
	end
	
	check={'init','timers'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Deleting timers and re-initializing')
		delete(timerfindall)
		args = struct; args.action = 'init';
		timerManager(args);
		return;
	end
	
	check={'calibration','pull','data'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Pulling in stored calibration data')
		c = calibration();
		c.calibrate_mag_from_logs();
		return;
	end
	
	check={'show','timers'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Initialized timers')
		g=timerfindall;
		disp(sprintf('idx\t0/1\tHz\tTimer Name'));
		for i=1:size(g,2)
			disp(sprintf('%d\t%s\t%0.f\t%s',i,get(g(i),'Running'), 1/get(g(i),'Period'),get(g(i),'Name')));
		end
		return;
	end
	
	check={'start','timer'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Starting a timer')
		g=timerfindall;
		disp(sprintf('idx\t0/1\tHz\tTimer Name'));
		for i=1:size(g,2)
			disp(sprintf('%d\t%s\t%0.f\t%s',i,get(g(i),'Running'), 1/get(g(i),'Period'),get(g(i),'Name')));
		end
		choice = input('Enter the index # for the timer to start (-1 = all,0 = escape):');
		if choice == -1
			for i=1:size(g,2)
				args = struct; args.action = 'stop'; args.name = get(g(i),'Name');
				timerManager(args);
			end
		elseif choice > 0
			name = get(g(choice),'Name');
			disp(sprintf('Attempting to start timer %s',name))
			args = struct; args.action = 'start', args.name = name;
			timerManager(args);
		end
		return;
	end
	
	check={'stop','timer'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Stopping a timers')
		g=timerfindall;
		disp(sprintf('idx\t0/1\tHz\tTimer Name'));
		for i=1:size(g,2)
			disp(sprintf('%d\t%s\t%0.f\t%s',i,get(g(i),'Running'), 1/get(g(i),'Period'),get(g(i),'Name')));
		end
		choice = input('Enter the index # for the timer to stop (-1 = all,0 = escape):');
		if choice == -1
			for i=1:size(g,2)
				args = struct;
				args.action = 'stop'; args.name = get(g(i),'Name');
				timerManager(args);
			end
		elseif choice > 0
			name = get(g(choice),'Name');
			disp(sprintf('Attempting to stop timer %s',name))
			args = struct; args.action = 'stop'; args.name = name;
			timerManager(args);
		end
		return;
	end
	
	check={'start','sensor','model'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Starting render of TableSat measurements')
		tsat.tsatModel=tsat.tsatModel.draw();
		args = struct; args.action = 'start'; args.name = 'Sensor->Model';
		timerManager(args);
		return;
	end
	
	check={'stop','sensor','model'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Stopping render of TableSat measurements')
		args = struct; args.action = 'stop'; args.name = 'Sensor->Model';
		timerManager(args);
		return;
	end
	
	check={'start','sensor','graph'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Starting timer to transfer data from the buffer to the sensor object')
		args = struct; args.action = 'start'; args.name = 'Sensor->Graph';
		timerManager(args);
		return;
	end
	
	check={'stop','sensor','graph'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Stopping timer to transfer data from the buffer to the sensor object')
		args = struct; args.action = 'stop'; args.name = 'Sensor->graph';
		timerManager(args);
		return;
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Estimator area
	
	check={'switch','estimator'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		disp('Sensor Filtering Options')
		disp(sprintf('1\tNo Filter'))
		disp(sprintf('2\tLuenberger Observer'))
		disp(sprintf('3\tPID Observer'))
		disp(sprintf('4\tKF'))
		disp(sprintf('5\tEKF'))
		disp(sprintf('6\tSMO'))
		choice = input('Enter the index # for the timer to stop:');
		if choice == 1
			args = struct; args.type = 'none';
			tsat.estimator=tsat.estimator.switchEstimator(args);
		elseif choice == 2
			args = struct; args.type = 'luenberger';
			tsat.estimator=tsat.estimator.switchEstimator(args);
		elseif choice == 3
			args = struct; args.type = 'pid';
			tsat.estimator=tsat.estimator.switchEstimator(args);
		elseif choice == 4
			args = struct; args.type = 'kf';
			tsat.estimator=tsat.estimator.switchEstimator(args);
		elseif choice == 5
			args = struct; args.type = 'ekf';
			tsat.estimator=tsat.estimator.switchEstimator(args);
		elseif choice == 6
			args = struct; args.type = 'smo';
			tsat.estimator=tsat.estimator.switchEstimator(args);
		else
			disp('Invalid filter choice')
			return;
		end
		return;
	end
	
	check={'reset','estimator'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		disp 'Resetting the active estimator'
		tsat.estimator = tsat.estimator.reset();
		return;
	end
	
	% End Area
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Controller area
	
	check={'switch','controller'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		disp('Controller Options')
		disp(sprintf('1\tNo Controller'))
		disp(sprintf('2\tPID Controller'))
		disp(sprintf('3\tSMC Controller'))
		disp(sprintf('4\tLQR Controller'))
		choice = input('Enter the # for controller to output:');
		args = struct;
		if choice == 1
			args.type = 'none';
		elseif choice == 2
			args.type = 'pid';
		elseif choice == 3
			args.type = 'smc';
		elseif choice == 4
			args.type = 'lqr';
		else
			disp('Invalid controller choice')
			return;
		end
		tsat.controller = tsat.controller.run(args)
		tsat.controller = tsat.controller.setOutput(args)
		return;
	end
	
	check={'reset','controller'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		disp 'Resetting the controller'
		tsat.controller = tsat.controller.reset();
		return;
	end
	
	% End Controller Area
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Tools area
	
	% Add command for autocorrelation of sensor history field.
	
	
	
	% End Tools Area
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Testing area
	
	% Add command to list test files	
	
	check={'test','quaternion'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Running Quaternion class test')
		testQuaternion;
		return;
	end
	
	check={'test','quaternion' 'euler'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Running the nutation graphing proof of concept test')
		testCompareQuaternionAndEulerMatrices;
		return;
	end
	
	check={'test','nutation' 'graph'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Running the nutation graphing proof of concept test')
		testDemoAttitudePlotting;
		return;
	end
	
	check={'test','graphing'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Running graph utility test')
		testPlotManagement;
		return;
	end
	
	check={'test','sensor','graph'};
	if (echoArr(printOnly,check,varargin) && isEqual(varargin,check))
		display('Running EKF class test')
		testMockSensorValuesToMultiplePlotUpdates;
		return;
	end
	
	% End Testing area
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	if (~printOnly)
		disp(sprintf('Command arguments not an exact match.\nPossible Options:'))
		varargout = arr_push(varargin,'?');
		str = 'cmd';
		for i=1:size(varargout,2)
			str = sprintf('%s %s',str,varargout{i});
		end
		eval(str);
	end
end

function str = printCell(cell2Print)
	str = '  >> cmd';
	for i=1:size(cell2Print,2)
		str = sprintf('%s %s',str,cell2Print{i});
	end
end

function value = echoArr(printOnly,arr,passedIn)
	if (printOnly)
		value = false;
		if (isSubset(arr,passedIn))
			disp(printCell(arr))
		end
		return;
	end
	value = true;
end

function value = isEqual(arr1,arr2)
	if size(arr1,2) ~= size(arr2,2)
		value = false;
		return;
	end
	for i=1:size(arr1,2)
		found = false;
		for j=1:size(arr2,2)
			if (strcmp(arr1(i),arr2(j)))
				found = true;
				break;
			end
		end
		if (~found)
			value = false;
			return;
		end
	end
	value = true;
end

function value = isSubset(arr,subset)
	for i=1:size(subset,2)
		if (~strcmp('?',subset(i)) && ~arrContainsText(arr,subset(i)))
			value = false;
			return;
		end
	end
	value = true;
end

function located = arrContainsText(arr,text)
	located = false;
	for a=1:size(arr,2)
		if(strcmp(arr{a},text))
			located = true;
			return;
		end
	end
end