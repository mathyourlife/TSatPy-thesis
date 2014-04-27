disp('Testing plotting while updating LaTeX labels')

global t graphs

record_it = 0;

args = struct;
args.name = 'sim_plot_with_latex';
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id)

item = struct; item.name = 'test_series_1'; item.type = 'plot'; item.style = 'r';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = 'sim_plot_with_latex'; args.item = item;
graphManager(args);


item = struct; item.name = 'test_series_2'; item.type = 'plot'; item.style = 'b--';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = 'sim_plot_with_latex'; args.item = item;
graphManager(args);

item = struct;
item.title = 'Real-time Plotting with Updated Floating LaTeX Equations';
item.xlabel = 'Seconds Before Now';
item.ylabel = 'y-axis';
args = struct; args.action = 'format'; args.graph = 'sim_plot_with_latex'; args.item = item;
graphManager(args);


label = struct;
label.lh = text(0,0,'Testing new','Parent',graphs.sim_plot_with_latex.obj.plot_id,'HorizontalAlignment','right','interpreter','latex','FontSize',12);
graphs.sim_plot_with_latex.obj.labels.('cos') = label;

label = struct;
label.lh = text(0,0,'Testing new','Parent',graphs.sim_plot_with_latex.obj.plot_id,'HorizontalAlignment','right','interpreter','latex','FontSize',12);
graphs.sim_plot_with_latex.obj.labels.('sin') = label;

args = struct; args.historylen = 100;
ts_1_hist = hist(args);
end_time = t.now() + 30;
pause_time = 0.1;
if (record_it)
  fh=figure(fig_id);
  clear mov;
  frame = 0;
end

while end_time > t.now()
  pause(pause_time);
  
  if (record_it)
    frame = frame + 1;
  end
  
  cur_time = t.now();
  args = struct;
  args.var = 'ts_1';
  args.value = sin(cur_time/2);
  ts_1_hist = ts_1_hist.log(args);
  
  cur_time = t.now();
  args = struct;
  args.var = 'ts_2';
  args.value = cos(cur_time/2);
  ts_1_hist = ts_1_hist.log(args);
  
  item = struct; item.name = 'test_series_1'; item.type = 'plot';
  data = struct; data.x = ts_1_hist.logs.ts_1(:,1)-cur_time; data.y = ts_1_hist.logs.ts_1(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = 'sim_plot_with_latex'; args.item = item;
  graphManager(args);
  
  item = struct; item.name = 'test_series_2'; item.type = 'plot';
  data = struct; data.x = ts_1_hist.logs.ts_2(:,1)-cur_time; data.y = ts_1_hist.logs.ts_2(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = 'sim_plot_with_latex'; args.item = item;
  graphManager(args);
  
  set(graphs.sim_plot_with_latex.obj.labels.cos.lh,'Position',[0 cos(cur_time/2) 0]);
  set(graphs.sim_plot_with_latex.obj.labels.cos.lh,'String',sprintf('$$cos\\left(\\frac{t}{2}\\right) = %0.4f$$',cos(cur_time/2)));
  set(graphs.sim_plot_with_latex.obj.labels.sin.lh,'Position',[0 sin(cur_time/2) 0]);
  set(graphs.sim_plot_with_latex.obj.labels.sin.lh,'String',sprintf('$$sin\\left(\\frac{t}{2}\\right) = %0.4f$$',sin(cur_time/2)));
  if (record_it)
    mov(frame)=getframe(fh);
  end
end
if (record_it)
  movie2avi(mov,'realtime_plotting_latex_updates.avi', 'COMPRESSION', 'Cinepak', 'FPS', floor(1/pause_time));
  clear mov;
end

close(fig_id);