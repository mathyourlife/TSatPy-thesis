function s_SubPlotting()
disp('Testing plotting to a subplot')

global t

graph = 'sim_subplotting';

args = struct;
args.name = graph;
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id)

subplot(2,2,1)

item = struct; item.name = 'test_series_1'; item.type = 'plot'; item.style = 'r';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = graph; args.item = item;
graphManager(args);

subplot(2,2,2)
args = struct; args.fig_id = fig_id;
fig2 = tPlot(args);

item = struct; item.name = 'test_series_2'; item.type = 'plot'; item.style = 'b--';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = graph; args.item = item;
graphManager(args);

subplot(2,2,3:4)
args = struct; args.fig_id = fig_id;
fig3 = tPlot(args);

item = struct; item.name = 'test_series_3'; item.type = 'plot'; item.style = 'r';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = graph; args.item = item;
graphManager(args);

item = struct; item.name = 'test_series_4'; item.type = 'plot'; item.style = 'b--';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = graph; args.item = item;
graphManager(args);

args = struct; args.historylen = 50;
ts_1_hist = hist(args);
end_time = t.now() + 10;

while end_time > t.now()
  pause(0.1);
  
  cur_time = t.now();
  args = struct;
  args.var = 'ts_1';
  args.value = sin(cur_time*2);
  ts_1_hist = ts_1_hist.log(args);
  
  cur_time = t.now();
  args = struct;
  args.var = 'ts_2';
  args.value = cos(cur_time*2);
  ts_1_hist = ts_1_hist.log(args);
  
  item = struct; item.name = 'test_series_1'; item.type = 'plot';
  data = struct; data.x = ts_1_hist.logs.ts_1(:,1)-cur_time; data.y = ts_1_hist.logs.ts_1(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = graph; args.item = item;
  graphManager(args);
  
  item.name = 'test_series_3';
  args = struct; args.action = 'updateseries'; args.graph = graph; args.item = item;
  graphManager(args);
  
  item = struct; item.name = 'test_series_2'; item.type = 'plot';
  data = struct; data.x = ts_1_hist.logs.ts_2(:,1)-cur_time; data.y = ts_1_hist.logs.ts_2(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = graph; args.item = item;
  graphManager(args);
  
  item.name = 'test_series_4';
  args = struct; args.action = 'updateseries'; args.graph = graph; args.item = item;
  graphManager(args);
  
end

close(fig_id);