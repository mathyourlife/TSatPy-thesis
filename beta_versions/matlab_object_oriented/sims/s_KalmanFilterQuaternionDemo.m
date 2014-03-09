function s_KalmanFilterQuaternionDemo()
	disp('Kalman Filter Quaternion Demo')
	
	global t
	
	args = struct;
	args.name = 'q_kf';
	args.action = 'create';
	graphManager(args);
	
	args = struct; args.show_thrusters = 0;
	tm_act = tsatModel(args);
	plot_args = struct; plot_args.graph = 'q_kf'; plot_args.color = 'c';
	tm_act.setupPlot(plot_args);
	
	args = struct; args.show_thrusters = 0;
	tm_est = tsatModel(args);
	plot_args = struct; plot_args.graph = 'q_kf'; plot_args.color = 'b';
	tm_est.setupPlot(plot_args);
	
	args = struct; args.I = eye(3);
	p_est = plant(args);
	p_act = plant(args);
	
	args = struct;
	args.state = state();
	args.state.w.w = [0.0001 0.0001 0.1]';
	
	args.state.q = mock().gen_random_quaternion;
	p_act.set_state(args);
	
	p_est.propagate();
	p_act.propagate();
	
	A_sm = stateMatrix();
	P = zeros(7);
	Q_k = zeros(7);
	Q_k(1:3, 1:3) = eye(3) * 1
	Q_k(4, 4) = 1 * 1
	Q_k(5:7, 5:7) = eye(3) * 1
	C = eye(7);
	R_k = zeros(7);
	R_k(1:3, 1:3) = eye(3) * .5
	R_k(4, 4) = 1 * .5
	R_k(5:7, 5:7) = eye(3) * .5
	for i = 1:1000
		
		args = struct;
		p_est.propagate();
		p_act.propagate();
		
		disp(' ')
		plot_args = struct; plot_args.graph = 'q_kf'; plot_args.state = p_act.state;
		tm_act.updatePlot(plot_args);
		
		plot_args = struct; plot_args.graph = 'q_kf'; plot_args.state = p_est.state;
		tm_est.updatePlot(plot_args);
		
		args = struct; args.I = eye(3); args.state = p_est.state;
		A_sm.jacobian(args);
		
		y = p_act.state.matrix();
		x_est = p_est.state.matrix();
		disp(sprintf('Measured:   %s',num2str(y')))
		disp(sprintf('Estimated:  %s',num2str(x_est')))
		D = zeros(7);
		u = zeros(7, 1);
		A = A_sm.matrix();
		B = zeros(7);
		P = A * P * A' + Q_k;    % covariance
		K = P * C' * inv(C * P * C' + R_k);
		err = (y - (C * x_est + D * u));
		disp(sprintf('Error:      %s',num2str(err')))
		x_adj = K * err; % Calulate the measurement based adjustement
		disp(sprintf('Adjustment: %s',num2str(x_adj')))
		x_est = x_est + x_adj;                 % Combine the predicted state with the measurement adjustment
		P = (eye(7) - K * C) * P;              % Update the coviance matrix
		
		args = struct;
		args.state = matrixToState(x_est);
		args.state.q.normalize();
		p_est.set_state(args);
		
		pause(0.2)
	end
	return;
	
	%=============================
	% Step size parameters
	step_n = 0.2;   % Average discrete time step size
	step_s = 0.06;  % Standard deviation of the discrete time step size
	sim_time = 60; % Duration of the simulation (sec)
	disp(sprintf('%g sec simulation with timesteps avg = %g sec, stdev = %g sec', sim_time, step_n, step_s))
	% End step size parameters
	%=============================
	
	%======================================
	% System/Estimator configuration
	
	% Magnitude of the forcing function
	u_mag = -1;
	
	% Discrete system setup
	A = @(args)([1 args.dt; 0 1]);   % Function to generate an A matrix based on the step size
	B = @(args)([args.dt^2/2 args.dt]');  % Function to generate a B matrix based on the step size
	C = @(args)(1);                     % Tracked state is x(1)
	D = @(args)(0);
	
	% Setup initial conditions for the truth model and the estimator
	x_truth = [-20 5]';
	x_est = [0 0]';
	
	% Process noise setup, based on time step sizes
	Q_std = 0.05;                          % Process noise standard deviation
	w = @(args)(Q_std  * [(args.dt^2/2); args.dt]);    % Create process noise matrix function using the process noise std
	w_k = @(args)(w(args) .* randn(2,1));      % Add process noise at time step k
	Q_k = @(args)(w(args) * w(args)');           % Q_k = Ex = w*w'
	
	% Measurement noise setup
	R_std = 5;                             % Measurement noise standard deviation
	v = R_std;                             % Base level measurment noise for y = Cx + v
	v_k = @()(v * randn);                  % Measurement noise variance
	R_k = R_std^2;                         % R_k = Ez = v * v'
	
	% End System/Estimator configuration
	%======================================
	
	args = struct;
	args.A = A;
	args.B = B;
	args.C = C;
	args.D = D;
	args.Q_k = Q_k;
	args.R_k = R_k;
	args.state = x_est;
	est = kf(args);
	
	% Create history instance to track values for plotting
	args = struct; args.historylen = floor(sim_time / step_n * 1.05);
	h = hist(args);
	
	% Set the time values for the loop
	start_time = t.now();
	last_update_time = t.now();
	t_step = t.now();
	
	% Simulate the System with a Kalman Filter estimator
	while t_step < start_time + sim_time
		
		% Alter the input force depending on the simulation time
		if mod(t_step - start_time, 20) < 10
			u = u_mag;
		else
			u = -u_mag;
		end
		
		% Determine the actual runtime step size
		dt = t_step - last_update_time;
		last_update_time = t_step;
		
		%==========================
		% System model update
		[x_truth, y] = plant_update(x_truth, A, B, C, D, u, w_k, v_k, dt);
		% End system model update
		%==========================
		
		
		%==========================
		% Estimator update
		args = struct;
		args.y = y;
		args.u = u;
		est = est.update(args);
		% End estimator update
		%==========================
		
		% Determine the position error
		x_err = est.state(1) - x_truth(1);
		
		%========================================
		% Log changes to the history object
		args = struct; args.var = 'truth'; args.value = x_truth(1); % track true position
		h = h.log(args);
		args = struct; args.var = 'meas'; args.value = y;           % track measured position
		h = h.log(args);
		args = struct; args.var = 'est'; args.value = est.state(1); % track estimated position
		h = h.log(args);
		args = struct; args.var = 'err'; args.value = x_err;        % track state error
		h = h.log(args);
		% End log changes to the history object
		%========================================
		
		% Create a gaussian based variable time step
		pause(step_n + randn * step_s)
		
		% Update the current timestamp
		% This gets referenced a few times so just recalc and store
		t_step = t.now();
	end
	
	% Summary
	disp('Simulation Complete');
	disp(sprintf(' Final state error: %g', x_err))
	
	% Show the simulation results
	plot_simulation_results(h, start_time)
end

function [x_truth, y] = plant_update(x_truth, A, B, C, D, u, w_k, v_k, dt)
	
	persistent update_args;
	
	if ~isstruct(update_args)
		update_args = struct;
	end
	update_args.dt = dt;
	
	% Create a state matrix based on the time step size
	A = A(update_args);
	B = B(update_args);
	
	% Update the truth model state without process noise
	x_truth = A * x_truth + B * u;
	% Add process noise to the system state
	x_truth = x_truth + w_k(update_args);
	
	% Generate a noisy measurement
	y = C(update_args) * x_truth + D(update_args) * u + v_k();
end

function plot_simulation_results(h, start_time)
	subplot(2,1,1)
	hold on;
	plot(h.logs.meas(:, 1) - start_time, h.logs.meas(:, 2), 'k.');
	plot(h.logs.truth(:, 1) - start_time, h.logs.truth(:, 2), 'g--', 'LineWidth', 2);
	plot(h.logs.est(:, 1) - start_time, h.logs.est(:, 2), 'b-', 'LineWidth', 2);
	legend('measured', 'truth', 'estimated', 'Location', 'SouthEast');
	title('Kalman Filter with Non-Uniform Timesteps')
	xlabel('Time (sec)')
	ylabel('State')
	grid on;
	subplot(2,1,2);
	plot(h.logs.err(:, 1) - start_time, h.logs.err(:, 2), 'r-', 'LineWidth', 2);
	legend('estimated - truth', 'Location', 'SouthEast');
	xlabel('Time (sec)')
	ylabel('Error')
	grid on;
	hold off;
end
