function CalibrateTAM()

global TAMTrans
global ForcedTAMTrans
global baseline
global movAvg

[StableSpinTAMData, result]= readtext('StableSpinTAMDatav2 7.5 volts fan1 with 2 forced nutation.txt', ' ', '','','numeric');
disp(sprintf('Samples: %d',result.rows));

% Plot raw data
plot(StableSpinTAMData(1:end, 14:16))

% Analyze time stamps
time = StableSpinTAMData(1:end,2);
[Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(time);
disp(sprintf('Mean Sample Rate: %0.4f Hz',Hz_mean));
disp(sprintf('Mean Delta T: %0.4f s',delta_mean));
disp(sprintf('Standard Deviation Delta T: %0.6f s',delta_stdev));

TAMData = StableSpinTAMData(1:end, 14:16);
Txbar(1) = mean(TAMData(1:end,1));
Txbar(2) = mean(TAMData(1:end,2));
Txbar(3) = mean(TAMData(1:end,3));
disp(sprintf('TAM mean values\nTAM_x:%0.2f V  TAM_y:%0.2f V  TAM_z:%0.2f V',Txbar(1),Txbar(2),Txbar(3)));

% Beginings of tranlation vector
Trans = -Txbar';

Tsigma(1) = std(TAMData(1:end,1));
Tsigma(2) = std(TAMData(1:end,2));
Tsigma(3) = std(TAMData(1:end,3));
disp(sprintf('TAM standard deviation values\nTAM_x:%0.2f V  TAM_y:%0.2f V  TAM_z:%0.2f V',Tsigma(1),Tsigma(2),Tsigma(3)));

% Subtract the mean values to center the data about the origin.
TAMNorm = TAMData;
TAMNorm(1:end,1) = TAMData(1:end,1) - Txbar(1);
TAMNorm(1:end,2) = TAMData(1:end,2) - Txbar(2);
TAMNorm(1:end,3) = TAMData(1:end,3) - Txbar(3);
plot(TAMNorm)
plot3(TAMNorm(:,1),TAMNorm(:,2),TAMNorm(:,3))

title('Raw TAM X,Y,Z Voltge Data (50Hz Sampling)')
xlabel('TAM X (V)');
ylabel('TAM Y (V)');
zlabel('TAM Z (V)');
grid on;
axis square;


points = 50;
movAvg = zeros(size(TAMNorm,1)-points+1,3);
for i=points:size(TAMNorm,1)
sum(1) = 0;
sum(2) = 0;
sum(3) = 0;
for j=i-points+1:i
sum(1) = sum(1) + TAMNorm(j,1);
sum(2) = sum(2) + TAMNorm(j,2);
sum(3) = sum(3) + TAMNorm(j,3);
end
movAvg(i-points+1,1) = sum(1) / points;
movAvg(i-points+1,2) = sum(2) / points;
movAvg(i-points+1,3) = sum(3) / points;
end

plot(movAvg)
plot3(movAvg(:,1),movAvg(:,2),movAvg(:,3))

return;

title(sprintf('Raw TAM X,Y,Z Voltge Data with %d Point Moving Average (50Hz Sampling)',points))
xlabel('TAM X (V)');
ylabel('TAM Y (V)');
zlabel('TAM Z (V)');
grid on;
axis square;

%Fitting points to a plane
x = movAvg(:,1);
y = movAvg(:,2);
z = movAvg(:,3);

Xcolv = x(:); % Make X a column vector
Ycolv = y(:); % Make Y a column vector
Zcolv = z(:); % Make Z a column vector
Const = ones(size(Xcolv)); % Vector of ones for constant term

Coefficients = [Xcolv Ycolv Const]\Zcolv; % Find the coefficients
zShift = -Coefficients(3); % constant term
disp(sprintf('Shift points along z-axis by%0.8f V',zShift));

%shift points down so the fitted plane goes through the origin
z = movAvg(:,3)+zShift;

% adjust translation vector to account for z-shift
Trans(3) = Trans(3) + zShift;

fitNormal = plotData([x y z])

% calculate the rotation matrix needed to align the fitted plane's normal
% vector with the z-axis
cp = cross(fitNormal,[0 0 1])

theta = asin(norm(cp) / norm(fitNormal) / norm([0 0 1]))


% Make cp a unit vector for easier rotation matrix calculations
cp = cp / norm(cp);

% Rotation matrix
u = cp(1);
v = cp(2);
w = cp(3);

r11 = u^2 + (v^2 + w^2) * cos(theta);
r22 = v^2 + (u^2 + w^2) * cos(theta);
r33 = w^2 + (u^2 + v^2) * cos(theta);

r12 = u*v*(1-cos(theta))-w*sin(theta);
r21 = u*v*(1-cos(theta))+w*sin(theta);

r13 = u*w*(1-cos(theta))+v*sin(theta);
r31 = u*w*(1-cos(theta))-v*sin(theta);

r23 = v*w*(1-cos(theta))-u*sin(theta);
r32 = v*w*(1-cos(theta))+u*sin(theta);


R = [r11 r12 r13; r21 r22 r23; r31 r32 r33]

% Full transformation matrix

%T = [R Trans; 0 0 0 1]
T = [R [0 0 0]'; 0 0 0 1]

%TAMTrans = TAMData;
TAMTrans = movAvg;

for i=points:size(TAMTrans,1)
pt2 = TransformPoint(TAMTrans(i,:),T);
TAMTrans(i,:) = pt2;
end

%plotData(TAMTrans)
x = TAMTrans(:,1);
y = TAMTrans(:,2);
z = TAMTrans(:,3);

Xcolv = x(:); % Make X a column vector
Ycolv = y(:); % Make Y a column vector
Zcolv = z(:); % Make Z a column vector
Const = ones(size(Xcolv)); % Vector of ones for constant term

Coefficients = [Xcolv Ycolv Const]\Zcolv; % Find the coefficients
XCoeff = Coefficients(1); % X coefficient
YCoeff = Coefficients(2); % X coefficient
CCoeff = Coefficients(3); % constant term
% Using the above variables, z = XCoeff * x + YCoeff * y + CCoeff

% Normal Vector
fitNormal = [-XCoeff -YCoeff 1]/norm([XCoeff YCoeff 1]);
disp(sprintf('Normal Vector: <%0.4f V,%0.4f V,%0.4f V>',fitNormal))
L=plot3(x,y,z,'ro'); % Plot the original data points
set(L,'Markersize',0.4*get(L,'Markersize')) % Making the circle markers larger
set(L,'Markerfacecolor','r') % Filling in the markers
grid on;
%hold on;

[xx, yy]=meshgrid(-0.04:0.005:0.04,-0.04:0.005:0.04); % Generating a regular grid for plotting
zz = XCoeff * xx + YCoeff * yy + CCoeff;
surf(xx,yy,zz) % Plotting the surface
disp(sprintf('Fitted Plane: z=(%f)*x+(%f)*y+(%f)',XCoeff, YCoeff, CCoeff));
title(sprintf('Raw TAM X,Y,Z Voltage Data with Fitted Plane (50Hz Sampling)\nz=(%f)*x+(%f)*y+(%f)',XCoeff, YCoeff, CCoeff))
xlabel('TAM X (V)');
ylabel('TAM Y (V)');
zlabel('TAM Z (V)');
axis square;
% By rotating the surface, you can see that the points lie on the plane
% Also, if you multiply both sides of the equation in the title by 4,
% you get the equation in the c
axis([-0.05,0.05,-0.05,0.05,-0.05,0.05]);

center = [0 0 0];
data_n=[center; center+fitNormal*0.02];
x=data_n(:,1);
y=data_n(:,2);
z=data_n(:,3);
plot3(x,y,z,'color','k','LineWidth',3)

buffer = 4;
for i=1:size(TAMTrans,1)
pt = TAMTrans(i,:);
angle = round(atan2(pt(2),pt(1))/pi*180);
for j=angle-buffer:angle+buffer
    if j<=0
       baseline(j+360) = pt(3); 
    else
       baseline(j) = pt(3); 
    end
end

end














[ForcedSpinTAMData, result]= readtext('ForcedSpinTAMData.txt', ' ', '','','numeric');
disp(sprintf('Samples: %d',result.rows));

% Plot raw data
%plot(ForcedSpinTAMData(1:end, 14:16))

% Analyze time stamps
time = ForcedSpinTAMData(1:end,2);
[Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(time);
disp(sprintf('Mean Sample Rate: %0.4f Hz',Hz_mean));
disp(sprintf('Mean Delta T: %0.4f s',delta_mean));
disp(sprintf('Standard Deviation Delta T: %0.6f s',delta_stdev));

ForcedTAMData = ForcedSpinTAMData(1:end, 14:16);

% Subtract the mean values to center the data about the origin.
ForcedTAMNorm = ForcedTAMData;
ForcedTAMNorm(1:end,1) = ForcedTAMData(1:end,1) + Trans(1);
ForcedTAMNorm(1:end,2) = ForcedTAMData(1:end,2) + Trans(2);
ForcedTAMNorm(1:end,3) = ForcedTAMData(1:end,3) + Trans(3);
%plot(ForcedTAMNorm)
%plot3(ForcedTAMNorm(:,1),ForcedTAMNorm(:,2),ForcedTAMNorm(:,3))

title('Raw TAM X,Y,Z Voltge Data (50Hz Sampling)')
xlabel('TAM X (V)');
ylabel('TAM Y (V)');
zlabel('TAM Z (V)');
grid on;
axis square;

points = 40;
ForcedmovAvg = zeros(size(ForcedTAMNorm,1)-points+1,3);
for i=points:size(ForcedTAMNorm,1)
sum(1) = 0;
sum(2) = 0;
sum(3) = 0;
for j=i-points+1:i
sum(1) = sum(1) + ForcedTAMNorm(j,1);
sum(2) = sum(2) + ForcedTAMNorm(j,2);
sum(3) = sum(3) + ForcedTAMNorm(j,3);
end
ForcedmovAvg(i-points+1,1) = sum(1) / points;
ForcedmovAvg(i-points+1,2) = sum(2) / points;
ForcedmovAvg(i-points+1,3) = sum(3) / points;
end

%plot(ForcedmovAvg)
%plot3(ForcedmovAvg(:,1),ForcedmovAvg(:,2),ForcedmovAvg(:,3))

%title(sprintf('Raw TAM X,Y,Z Voltge Data with %d Point Moving Average (50Hz Sampling)',points))
%xlabel('TAM X (V)');
%ylabel('TAM Y (V)');
%zlabel('TAM Z (V)');
%grid on;
%axis square;


ForcedTAMTrans = ForcedmovAvg;

for i=points:size(ForcedTAMTrans,1)
pt2 = TransformPoint(ForcedTAMTrans(i,:),T);
ForcedTAMTrans(i,:) = pt2;
end




for i=1:size(ForcedTAMTrans,1)
pt = ForcedTAMTrans(i,:);
angle = round(atan2(pt(2),pt(1))/pi*180);
if angle<=0
    angle = angle + 360;
end
ForcedTAMTrans(i,3) = ForcedTAMTrans(i,3) + baseline(angle);
end

size(time(1:end-39))
size(ForcedTAMTrans(:,3))
plot(time(1:end-39),ForcedTAMTrans(:,3))


return;

x = ForcedTAMTrans(:,1);
y = ForcedTAMTrans(:,2);
z = ForcedTAMTrans(:,3);

Xcolv = x(:); % Make X a column vector
Ycolv = y(:); % Make Y a column vector
Zcolv = z(:); % Make Z a column vector
Const = ones(size(Xcolv)); % Vector of ones for constant term

Coefficients = [Xcolv Ycolv Const]\Zcolv; % Find the coefficients
XCoeff = Coefficients(1); % X coefficient
YCoeff = Coefficients(2); % X coefficient
CCoeff = Coefficients(3); % constant term
% Using the above variables, z = XCoeff * x + YCoeff * y + CCoeff

% Normal Vector
fitNormal = [-XCoeff -YCoeff 1]/norm([XCoeff YCoeff 1]);
disp(sprintf('Normal Vector: <%0.4f V,%0.4f V,%0.4f V>',fitNormal))
J=plot3(x,y,z,'bo'); % Plot the original data points
set(J,'Markersize',0.4*get(J,'Markersize')) % Making the circle markers larger
set(J,'Markerfacecolor','b') % Filling in the markers
grid on;
hold off;


end












function pt2 = TransformPoint(pt,T)

    result = T * [pt'; 1];

    x2 = result(1);
    y2 = result(2);
    z2 = result(3);

    pt2 = result(1:3);
end









function fitNormal = plotData(data)

x = data(:,1);
y = data(:,2);
z = data(:,3);

Xcolv = x(:); % Make X a column vector
Ycolv = y(:); % Make Y a column vector
Zcolv = z(:); % Make Z a column vector
Const = ones(size(Xcolv)); % Vector of ones for constant term

Coefficients = [Xcolv Ycolv Const]\Zcolv; % Find the coefficients
XCoeff = Coefficients(1); % X coefficient
YCoeff = Coefficients(2); % X coefficient
CCoeff = Coefficients(3); % constant term
% Using the above variables, z = XCoeff * x + YCoeff * y + CCoeff

% Normal Vector
fitNormal = [-XCoeff -YCoeff 1]/norm([XCoeff YCoeff 1]);
disp(sprintf('Normal Vector: <%0.4f V,%0.4f V,%0.4f V>',fitNormal))
L=plot3(x,y,z,'ro'); % Plot the original data points
set(L,'Markersize',0.2*get(L,'Markersize')) % Making the circle markers larger
set(L,'Markerfacecolor','r') % Filling in the markers
grid on;

[xx, yy]=meshgrid(-0.04:0.005:0.04,-0.04:0.005:0.04); % Generating a regular grid for plotting
zz = XCoeff * xx + YCoeff * yy + CCoeff;
surf(xx,yy,zz) % Plotting the surface
disp(sprintf('Fitted Plane: z=(%f)*x+(%f)*y+(%f)',XCoeff, YCoeff, CCoeff));
title(sprintf('Raw TAM X,Y,Z Voltage Data with Fitted Plane (50Hz Sampling)\nz=(%f)*x+(%f)*y+(%f)',XCoeff, YCoeff, CCoeff))
xlabel('TAM X (V)');
ylabel('TAM Y (V)');
zlabel('TAM Z (V)');
axis square;
% By rotating the surface, you can see that the points lie on the plane
% Also, if you multiply both sides of the equation in the title by 4,
% you get the equation in the c
axis([-0.05,0.05,-0.05,0.05,-0.05,0.05]);

center = [0 0 0];
data_n=[center; center+fitNormal*0.02];
x=data_n(:,1);
y=data_n(:,2);
z=data_n(:,3);
plot3(x,y,z,'color','k','LineWidth',3)



end