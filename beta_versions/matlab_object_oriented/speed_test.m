
args = struct; args.I = rand(3) .* eye(3);
p_o = plant(args);

duration_1 = 0;
duration_2 = 0;
iter = 1000;


args = struct;
for i=1:iter
  args.M = rand(3, 1);
  if mod(i,2) == 0
    tic;
    p_o.propagate(args);
    duration_1 = duration_1 + toc;
  else
    tic;
    %p_o.propagate(args);
    duration_2 = duration_2 + toc;
  end
end
disp(sprintf('iterations: %d',iter))
disp(sprintf('method 1: %0.3f sec',duration_1))
disp(sprintf('method 2: %0.3f sec',duration_2))
