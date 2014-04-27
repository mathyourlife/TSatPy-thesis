disp('Testing plant class')

args = struct;
args.I = rand(3) .* eye(3);
args.I = eye(3);
p = plant(args);
tb=testBase;

tb.assertEquals(state(),p.state,'Initialize the state on the plant.');

p.propagate();

tb.assertEquals(state(),p.state,'State after a propagation has not changed.');

%=========================================================================
% Test the propagation of states for a plant given a constant initial
% body and left unforced.
%=========================================================================

% Feed a moment into the plant and watch the state change
deg_per_sec = 2;
rad_per_sec = deg_per_sec / 180 * pi;

duration = 7;
end_time = t.now() + duration;

%disp(sprintf('Simulating a constant %d deg/sec spin about z for %d seconds', deg_per_sec, duration))
args = struct;
args.I = eye(3);
args.q = quaternion();
args.w =  bodyRate();
args.w.w = [0 0 rad_per_sec]';
p = plant(args);

while t.now() < end_time
%  disp('===============================================')
  pause(0.01)
  p.propagate();
%  disp(p.state.str)
%  [vec, theta] = p.state.q.toRotation();
%  vec = round(vec * 100) / 100;
%  disp(sprintf('%0.2f deg about vector <%g %g %g>',theta / pi * 180, vec))
end

[vec, theta] = p.state.q.toRotation();
tb.assertMaxError(duration * deg_per_sec, theta / pi * 180, 1, 'State propagation with a constant body rate');

%=========================================================================
% Test the propagation of states for a plant given a constant initial
% body and left unforced.
%=========================================================================

args = struct;
args.I = eye(3);
p = plant(args);

duration = 7;
end_time = t.now() + duration;

args = struct;
args.M = [0 0.01 0]';

while t.now() < end_time
%  disp('===============================================')
  pause(0.01)
  p.propagate(args);
%  disp(p.state.str)
%  [vec, theta] = p.state.q.toRotation();
%  vec = round(vec * 100) / 100;
%  disp(sprintf('%0.2f deg about vector <%g %g %g>',theta / pi * 180, vec))
end

[vec, theta] = p.state.q.toRotation();
% A constant acceleration translates to a*t^2/2 change in position
theta_f = args.M(2) * (duration ^ 2) / 2;
tb.assertMaxError(theta_f, theta, 1, 'State propagation with a constant acceleration');
