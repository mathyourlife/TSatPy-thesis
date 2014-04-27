function s_EKFQuaternionDemo()
  disp('Quaternion Based Extended Kalman Filter Demo')
  
  global t
  
  record_it = 0;
  
  if (record_it)
    clear mov;
  end
  
  args = struct;
  args.name = 'ekf';
  args.action = 'create';
  fig_id = graphManager(args);
  
  args = struct; args.show_thrusters = 0;
  tm_act = tsatModel(args);
  plot_args = struct; plot_args.graph = 'ekf'; plot_args.color = 'c';
  tm_act.setupPlot(plot_args);
  plot_args = struct; plot_args.graph = 'ekf';
  tm_act.addAxesLabels(plot_args);
  
  args = struct; args.show_thrusters = 0;
  tm_est = tsatModel(args);
  plot_args = struct; plot_args.graph = 'ekf'; plot_args.color = 'b';
  tm_est.setupPlot(plot_args);
  plot_args = struct; plot_args.graph = 'ekf';
  tm_est.addAxesLabels(plot_args);
  
  I = eye(3);
  
  args = struct; args.I = I;
  p_act = plant(args);
  
  args = struct;
  args.state = state();
  args.state.q.vector = [0 0.1 1]';
  args.state.q.normalize();
  args.state.w.w = [0 0 2]';
  p_act.set_state(args);
  
  p_act.propagate();
  
  msg = sprintf('Quaternion Based Extended Kalman Filter\nPlant Propagation through Euler Moment and Quaternion Dynamic Equations\n(Truth = light blue, EKF Estimate = dark blue)');
  title(msg);
  
  info = annotation('textbox', [0, 0, 1, 0.5],'LineStyle','none','HorizontalAlignment','right','FontWeight','bold');
  
  args = struct;
  args.Q_k = zeros(7);
  args.Q_k(1:3, 1:3) = eye(3) * 1;
  args.Q_k(4, 4) = 1 * 1;
  args.Q_k(5:7, 5:7) = eye(3) * 1;
  args.R_k = zeros(7);
  args.R_k(1:3, 1:3) = eye(3) * 50;
  args.R_k(4, 4) = 1 * 50;
  args.R_k(5:7, 5:7) = eye(3) * 50;
  args.I = I;
  args.state = state();
  args.state.w.w = [-2 -2 -2]';
  
  ekf_est = ekf(args);
  
  update_info(info, p_act, ekf_est.state)
  
  % initialize the frame counter for optional video capture
  if (record_it)
    frame = 0;
  end
  
  pause(10)
  
  for i = 1:430
    
    % Increment the frame counter for video capture
    if (record_it)
      frame = frame + 1;
    end
    
    args = struct;
    p_act.propagate();
    
    args = struct; args.state = p_act.state;
    ekf_est.update(args);
    
    plot_args = struct; plot_args.graph = 'ekf'; plot_args.state = p_act.state;
    tm_act.updatePlot(plot_args);
    
    plot_args = struct; plot_args.graph = 'ekf'; plot_args.state = ekf_est.state;
    tm_est.updatePlot(plot_args);
    
    update_info(info, p_act, ekf_est.state)
    
    pause(0.1)
    
    if (record_it)
      mov(frame)=getframe(fig_id);
    end
    
  end
  
  if (record_it)
    movie2avi(mov,'ekf.avi', 'COMPRESSION', 'Cinepak', 'FPS', 5);
    clear mov;
  end
end

function update_info(info, p_act, p_est)
  s_err = p_est.state - p_act.state;
  msg = sprintf('Actual State:\n%s\nEstimated State:\n%s\nState Error:\n%s',p_act.state.str,p_est.state.str, s_err.str);
  set(info,'String',msg)
end