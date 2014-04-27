function GetNutationAngles(sensordata)

global calibration

[ css_mag, css_theta ] = conv_css_to_theta(sensordata(1:6));
css_deg = css_theta * 180 / pi;
css_deg = round(css_deg);
if css_deg == 0
  css_deg = 360;
end

vec = sensordata(12:14) - calibration.steady_avg(css_deg,:);

xp = calibration.xpos_avg(css_deg,:) - calibration.steady_avg(css_deg,:);
yp = calibration.ypos_avg(css_deg,:) - calibration.steady_avg(css_deg,:);
xn = calibration.xneg_avg(css_deg,:) - calibration.steady_avg(css_deg,:);
yn = calibration.yneg_avg(css_deg,:) - calibration.steady_avg(css_deg,:);

vec = vec/norm(vec);
xp = xp/norm(xp);
yp = yp/norm(yp);
xn = xn/norm(xn);
yn = yn/norm(yn);

xpd = dot(vec,xp);
ypd = dot(vec,yp);
xnd = dot(vec,xn);
ynd = dot(vec,yn);

arr = sort([xpd ypd xnd ynd]);

if (xpd == arr(4))
first = '+x';
f = xpd;
b = vec - xp;
elseif (ypd == arr(4))
first = '+y';
f = ypd;
b = vec - yp;
elseif (xnd == arr(4))
first = '-x';
f = xnd;
b = vec - xn;
elseif (ynd == arr(4))
first = '-y';
f = ynd;
b = vec - yn;
end


if (xpd == arr(3))
second = '+x';
s = dot(b,xp);
elseif (ypd == arr(3))
second = '+y';
s = dot(b,yp);
elseif (xnd == arr(3))
second = '-x';
s = dot(b,xn);
elseif (ynd == arr(3))
second = '-y';
s = dot(b,yn);
end

v=[vec;0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'g')
hold on;
grid on;
square axis;
v=[xp;0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'k')
v=[yp;0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'b')
v=[xn;0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'r')
v=[yn;0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'c')
axis([-1 1 -1 1 -1 1])
hold off;

disp(sprintf('First %s:%0.4f Second %s:%0.4f',first,f,second,s))

