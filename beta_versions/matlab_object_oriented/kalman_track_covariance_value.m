function kalman_track_covariance_value()

dt = 1;
A_func = @(dt)[[1 dt; 0 1]];
C = [1 0]; % Observe the measurement output

Q_std = 0.05;                          % Process noise standard deviation
w = @(dt)[Q_std  * [(dt^2/2); dt]];    % Create process noise matrix function using the process noise std
Q_k = @(dt)[w(dt) * w(dt)'];           % Q_k = Ex = w*w'

dt = 1;
P = Q_k(dt);

R_std = 10;                            % Measurement noise standard deviation
R_k = R_std^2;                         % R_k = Ez = v * v'

gains = [];

for a = 1:100

A = A_func(dt);
if a > 1
P = A * P * A' + Q_k(dt);
end
K = P * C' * inv(C * P * C' + R_k);
P = (eye(size(P)) - K * C) * P;
gains(a,:) = K';

if a == 50
P = Q_k(dt);
end

end

plot(1:100,gains(:,1),1:100, gains(:,2))