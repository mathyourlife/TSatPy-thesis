function s_KalmanFilterDemo()
	disp('Demonstrating the Kalman Filter')
	
	global t
	
	record_it = 0;
	
	if (record_it)
		clear mov;
	end
	
	%=============================
	% Step size parameters
	step_n = 0.2;   % Average discrete time step size
	step_s = 0.06;  % Standard deviation of the discrete time step size
	% End step size parameters
	%=============================
	
	%================
	% Plot setup
	args = struct;
	args.name = 'kalman_filter_demo';
	args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id);
	subplot(2,1,1)
	title(sprintf('Discrete Kalman Filter - Non Uniform Step Size N(%0.1f,%0.2f^2)',step_n,step_s))
	xlabel('Time (sec)')
	ylabel('Position (m)')
	% End plot setup
	%================
	
	%====================================
	% Initialize plotting objects
	args = struct;
	args.action = 'addseries'; args.graph = 'kalman_filter_demo';
	args.item = struct;
	args.item.name = 'truth'; args.item.type = 'plot'; args.item.style = '--b'; args.item.LineWidth = 2;
	data = struct; data.x = 0; data.y = 0;
	args.item.data = data;
	graphManager(args);
	
	args.item.name = 'meas'; args.item.style = '-k.'; args.item.LineWidth = 1;
	graphManager(args);
	
	args.item.name = 'est'; args.item.style = '-r'; args.item.LineWidth = 2;
	graphManager(args);
	legend('truth','meas','est','Location','SW')
	% End initialize plotting objects
	%====================================
	
	%======================================
	% System/Estimator configuration
	
	% Magnitude of the forcing function
	u_mag = -1;
	
	% Discrete system setup
	A_func = @(dt)[[1 dt; 0 1]];
	B_func = @(dt)[[dt^2/2 dt]'];
	C = [1 0]; % Observe the measurement output
	
	% Setup initial conditions for the truth model and the estimator
	x_truth = [-20 5]';
	x_est = [0 0]';
	
	% Process noise setup
	Q_std = 0.05;                          % Process noise standard deviation
	w = @(dt)[Q_std  * [(dt^2/2); dt]];    % Create process noise matrix function using the process noise std
	w_k = @(dt)[w(dt) .* randn(2,1)];      % Add process noise at time step k
	Q_k = @(dt)[w(dt) * w(dt)'];           % Q_k = Ex = w*w'
	
	% Initialize the covariance matrix
	P = Q_k(step_n);
	
	% Measurement noise setup
	R_std = 5;                             % Measurement noise standard deviation
	v = R_std;                             % Base level measurment noise for y = Cx + v
	v_k = @(dt)[v * randn];                % Measurement noise variance
	R_k = R_std^2;                         % R_k = Ez = v * v'
	
	% End System/Estimator configuration
	%======================================
	
	% Template for the text box for updating with runtime values
	notes = 'Known 2nd order system, No Parameter Uncertainty\nKnown measurement and process noise corruption\nNoise: Measurement N(0,%d), Process N(0,%0.4f)\n\nRun Time: %0.1f sec\nTime Step Size: %0.3f sec\nTracking Position: Truth (%+0.3f) Meas (%+0.3f) Est(%+0.3f)\nError = Estimated - Truth = %0.1f';
	
	%=================================
	% Setup textbox on the graph
	mTextBox = uicontrol('style','text');
	set(mTextBox,'Position',[20 20 500 175]);
	set(mTextBox,'FontSize',12);
	set(mTextBox,'String',sprintf(notes,R_std^2,Q_std^2,0,0,0,0,0,0));
	% End setup textbox on the graph
	%=================================
	
	% Create history instance to track values for plotting
	args = struct; args.historylen = 100;
	h=hist(args);
	
	% initialize the frame counter for optional video capture
	if (record_it)
		frame = 0;
	end
	
	% Set the time values for the loop
	start_time = t.now();
	last_update_time = t.now();
	
	% Loop through the time steps and break out when the estimated state
	% stabilizes to the truth and the run time is > 3 sec.
	while t.now() < start_time + 3 || mean(abs(h.logs.est(:,2) - h.logs.truth(:,2))) > 1.5
		
		% Increment the frame counter for video capture
		if (record_it)
			frame = frame + 1;
		end
		
		% This gets referenced a few times so just calc and store
		t_now = t.now();
		
		% Alter the input force depending on the simulation time
		if mod(t_now-start_time,20) < 10
			u = u_mag;
		else
			u = -u_mag;
		end
		
		% Determine the actual time step
		dt = t_now - last_update_time;
		last_update_time = t_now;
		
		%==========================
		% System model update
		
		% Create a state matrix based on the measured time step
		A = A_func(dt);
		B = B_func(dt);
		
		% Update the truth model state without process noise
		x_truth = A * x_truth + B * u;
		% Add process noise to the system state
		x_truth = x_truth + w_k(dt);
		
		% Generate a noisy measurement
		y = C * x_truth + v_k(dt);
		
		% End system model update
		%==========================
		
		
		%==========================
		% Estimator update
		
		% (a priori) Predict the next state and covariance values
		x_est = A * x_est + B * u;  % state
		P = A * P * A' + Q_k(dt);    % covariance
		
		% Compute Kalman Gain
		K = P * C' * inv(C * P * C' + R_k);
		
		% (a posteriori) Update predictions
		x_adj = K * (y - C * x_est); % Calulate the measurement based adjustement
		x_est = x_est + x_adj;       % Combine the predicted state with the measurement adjustment
		P = (eye(2) - K * C) * P;    % Update the coviance matrix
		
		% End estimator update
		%==========================
		
		% Determine the position error
		error = x_est(1) - x_truth(1);
		
		% Update the plot text box
		msg = sprintf(notes,R_std^2,Q_std^2,t.now()-start_time,dt,x_truth(1),y,x_est(1), error);
		set(mTextBox, 'String', msg);
		
		%========================================
		% Log changes to the history object
		args = struct; args.var = 'truth'; args.value = x_truth(1); % track true position
		h = h.log(args);
		args = struct; args.var = 'meas'; args.value = y;           % track measured position
		h = h.log(args);
		args = struct; args.var = 'est'; args.value = x_est(1);     % track estimated position
		h = h.log(args);
		% End log changes to the history object
		%========================================
		
		%==========================
		% Update plots
		args = struct;
		args.action = 'updateseries'; args.graph = 'kalman_filter_demo';
		args.item = struct;
		args.item.name = 'truth'; args.item.type = 'plot';
		data = struct; data.x = h.logs.truth(:,1)-start_time; data.y = h.logs.truth(:,2);
		args.item.data = data;
		graphManager(args);
		
		args.item.name = 'meas';
		data = struct; data.x = h.logs.meas(:,1)-start_time; data.y = h.logs.meas(:,2);
		args.item.data = data;
		graphManager(args);
		
		args.item.name = 'est';
		data = struct; data.x = h.logs.est(:,1)-start_time; data.y = h.logs.est(:,2);
		args.item.data = data;
		graphManager(args);
		% End update plots
		%==========================
		
		if (record_it)
			mov(frame)=getframe(fig_id);
		end
		
		% Create a gaussian based variable time step
		pause(step_n + randn*step_s)
	end
	
	if (record_it)
		movie2avi(mov,'kalman_filter_demo.avi', 'COMPRESSION', 'Cinepak', 'FPS', 5);
		clear mov;
	end
	
end