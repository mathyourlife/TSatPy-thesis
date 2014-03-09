function w = calculate_body_rate(q1, q2, dt)
	
	// qe = q1.conj * q2;
	q_dot = q1 - q2;
	q_w = 2 * q1 * q_dot;
	
	w = q_w.vector;
	q2_est = q1.copy();
	
	args = struct; args.vector = [0 0 0]'; args.scalar = 0;
	q_w_step = quaternion(args);
	
	scalar = 0;
	w_total = 0;
	for i=1:100
		w_total = w_total + w;
		
		q_w_step.vector = -w/2;
		q_step_dot = q_w_step * q2_est;
		q2_est = q2_est + q_step_dot;
		q2_est.normalize();
		
		q2_err = q2.conj * q2_est;
		if scalar > 0.99999999
			break;
		elseif abs(q2_err.scalar) > scalar
			scalar = abs(q2_err.scalar);
		else
			w = -w/10;
			scalar = 0;
		end
	end
	
	w = w_total / dt;
end