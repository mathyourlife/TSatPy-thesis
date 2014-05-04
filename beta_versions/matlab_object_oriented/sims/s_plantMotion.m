function s_plantMotion()
  disp('Demo Satellite Plant Motion')

  % Simulation Parameters
  I = eye(3) * 10;
  rate = [0.1 -0.2 -2]';
  tilt = [0 0.1 1]';


  global t

  record_it = 0;

  if (record_it)
    clear mov;
  end

  graph_name = 'plant_motion';

  args = struct;
  args.name = graph_name;
  args.action = 'create';
  fig_id = graphManager(args);

  args = struct; args.show_thrusters = 0;
  tm_act = tsatModel(args);
  plot_args = struct; plot_args.graph = graph_name; plot_args.color = 'b';
  tm_act.setupPlot(plot_args);
  plot_args = struct; plot_args.graph = graph_name;
  tm_act.addAxesLabels(plot_args);

  args = struct; args.I = I;
  p_act = plant(args);

  args = struct;
  args.state = state();
  args.state.q.vector = tilt;
  args.state.q.normalize();
  args.state.w.w = rate;
  p_act.set_state(args);

  p_act.propagate();

  msg = sprintf('Equations of Motion - Demonstration');
  title(msg);

  info = annotation('textbox', [0, 0, 1, 0.25],'LineStyle','none', ...
    'HorizontalAlignment','right','FontWeight','bold');

  update_info(info, p_act)

  % initialize the frame counter for optional video capture
  if (record_it)
    frame = 0;
  end

  pause(3)

  for i = 1:430

    % Increment the frame counter for video capture
    if (record_it)
      frame = frame + 1;
    end

    args = struct;
    p_act.propagate();

    plot_args = struct; plot_args.graph = graph_name; plot_args.state = p_act.state;
    tm_act.updatePlot(plot_args);

    update_info(info, p_act)

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

function update_info(info, p_act)
  msg = sprintf('Plant State:\n%s',p_act.state.str);
  set(info,'String',msg)
end