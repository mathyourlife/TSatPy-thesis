global calibration

v = [calibration.steady_normal; 0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'k')
hold on;
grid on;
axis square;
v = [calibration.xpos_normal; 0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'b')
v = [calibration.ypos_normal; 0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'g')
v = [calibration.xneg_normal; 0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'c')
v = [calibration.yneg_normal; 0 0 0];
plot3(v(:,1),v(:,2),v(:,3),'r')
hold off;

pause

% Find the end of the steady data
css_angle = zeros(size(calibration.steady_data,1),1);
for i=1:size(calibration.steady_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.steady_data(i, 3:8));
  css_angle(i)= css_theta;
end

for row=size(css_angle,1):-1:1
  check = css_angle(row);
  if (check-0.1 < css_angle(1) && check+0.1 > css_angle(1))
    break
  end
end
plot(css_angle(1:row))
calibration.steady_end_row = row

pause

% Find the end of the xpos data
css_angle = zeros(size(calibration.xpos_data,1),1);
for i=1:size(calibration.xpos_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.xpos_data(i, 3:8));
  css_angle(i)= css_theta;
end

for row=size(css_angle,1):-1:1
  check = css_angle(row);
  if (check-0.1 < css_angle(1) && check+0.1 > css_angle(1))
    break
  end
end
plot(css_angle(1:row))
calibration.xpos_end_row = row

pause

% Find the end of the ypos data
css_angle = zeros(size(calibration.ypos_data,1),1);
for i=1:size(calibration.ypos_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.ypos_data(i, 3:8));
  css_angle(i)= css_theta;
end

for row=size(css_angle,1):-1:1
  check = css_angle(row);
  if (check-0.1 < css_angle(1) && check+0.1 > css_angle(1))
    break
  end
end
plot(css_angle(1:row))
calibration.ypos_end_row = row

pause

% Find the end of the xneg data
css_angle = zeros(size(calibration.xneg_data,1),1);
for i=1:size(calibration.xneg_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.xneg_data(i, 3:8));
  css_angle(i)= css_theta;
end

for row=size(css_angle,1):-1:1
  check = css_angle(row);
  if (check-0.1 < css_angle(1) && check+0.1 > css_angle(1))
    break
  end
end
plot(css_angle(1:row))
calibration.xneg_end_row = row

pause

% Find the end of the yneg data
css_angle = zeros(size(calibration.yneg_data,1),1);
for i=1:size(calibration.yneg_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.yneg_data(i, 3:8));
  css_angle(i)= css_theta;
end

for row=size(css_angle,1):-1:1
  check = css_angle(row);
  if (check-0.1 < css_angle(1) && check+0.1 > css_angle(1))
    break
  end
end
plot(css_angle(1:row))
calibration.yneg_end_row = row

pause


% Find the center
TAMcenter = zeros(1,3);
TAMcenter(1) = mean(calibration.steady_data(1:calibration.steady_end_row,14));
TAMcenter(2) = mean(calibration.steady_data(1:calibration.steady_end_row,15));
TAMcenter(3) = mean(calibration.steady_data(1:calibration.steady_end_row,16));
calibration.TAMcenter = TAMcenter;


% Find the TAM reading that corresponds wih 0 degrees on the CSS reading
TAMzero = zeros(1,3);
TAM90 = zeros(1,3);
countZero = 0;
count90 = 0;
angle_threshold = 10;
for i=1:calibration.steady_end_row
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.steady_data(i, 3:8));
  css_deg = round((css_theta * 180 / pi) - 0.49999);
  if (css_deg < angle_threshold) | (css_deg > (360 - angle_threshold))
    TAMzero(1) = TAMzero(1) + calibration.steady_data(i, 14);
    TAMzero(2) = TAMzero(2) + calibration.steady_data(i, 15);
    TAMzero(3) = TAMzero(3) + calibration.steady_data(i, 16);
    countZero = countZero + 1;
  end
  if (css_deg < 90 + angle_threshold) & (css_deg > 90 - angle_threshold) 
    TAM90(1) = TAM90(1) + calibration.steady_data(i, 14);
    TAM90(2) = TAM90(2) + calibration.steady_data(i, 15);
    TAM90(3) = TAM90(3) + calibration.steady_data(i, 16);
    count90 = count90 + 1;
  end
end
TAMzero(1) = TAMzero(1)/countZero;
TAMzero(2) = TAMzero(2)/countZero;
TAMzero(3) = TAMzero(3)/countZero;
TAM90(1) = TAM90(1)/count90;
TAM90(2) = TAM90(2)/count90;
TAM90(3) = TAM90(3)/count90;
calibration.TAMzero = TAMzero;
calibration.TAM90 = TAM90;

% Vector from TAM center to the TAMzero
TAMzeroVec = TAMzero - TAMcenter;
calibration.TAMzeroVec = TAMzeroVec;

TAM90vec = TAM90 - TAMcenter;
calibration.TAM90vec = TAM90vec;


buffer = 15;

avgarr = zeros(360,3);
countarr = zeros(360,1);
for r=1:size(calibration.steady_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.steady_data(r, 3:8));
  css_deg = css_theta * 180 / pi;
  css_deg = round(css_deg);
  if css_deg == 0
    css_deg = 360;
  end
  for g=max(1,css_deg-buffer):min(360,css_deg+buffer)
    avgarr(g,1) = avgarr(g,1) + calibration.steady_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.steady_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.steady_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer+360):min(360,css_deg+buffer+360)
    avgarr(g,1) = avgarr(g,1) + calibration.steady_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.steady_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.steady_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer-360):min(360,css_deg+buffer-360)
    avgarr(g,1) = avgarr(g,1) + calibration.steady_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.steady_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.steady_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end  
end
for r=1:360
  avgarr(r,1) = avgarr(r,1) / countarr(r);
  avgarr(r,2) = avgarr(r,2) / countarr(r);
  avgarr(r,3) = avgarr(r,3) / countarr(r);
end
calibration.steady_avg = avgarr;


avgarr = zeros(360,3);
countarr = zeros(360,1);
for r=1:size(calibration.xpos_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.xpos_data(r, 3:8));
  css_deg = css_theta * 180 / pi;
  css_deg = round(css_deg);
  if css_deg == 0
    css_deg = 360;
  end
  for g=max(1,css_deg-buffer):min(360,css_deg+buffer)
    avgarr(g,1) = avgarr(g,1) + calibration.xpos_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.xpos_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.xpos_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer+360):min(360,css_deg+buffer+360)
    avgarr(g,1) = avgarr(g,1) + calibration.xpos_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.xpos_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.xpos_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer-360):min(360,css_deg+buffer-360)
    avgarr(g,1) = avgarr(g,1) + calibration.xpos_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.xpos_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.xpos_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end  
end
for r=1:360
  avgarr(r,1) = avgarr(r,1) / countarr(r);
  avgarr(r,2) = avgarr(r,2) / countarr(r);
  avgarr(r,3) = avgarr(r,3) / countarr(r);
end
calibration.xpos_avg = avgarr;


avgarr = zeros(360,3);
countarr = zeros(360,1);
for r=1:size(calibration.ypos_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.ypos_data(r, 3:8));
  css_deg = css_theta * 180 / pi;
  css_deg = round(css_deg);
  if css_deg == 0
    css_deg = 360;
  end
  for g=max(1,css_deg-buffer):min(360,css_deg+buffer)
    avgarr(g,1) = avgarr(g,1) + calibration.ypos_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.ypos_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.ypos_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer+360):min(360,css_deg+buffer+360)
    avgarr(g,1) = avgarr(g,1) + calibration.ypos_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.ypos_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.ypos_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer-360):min(360,css_deg+buffer-360)
    avgarr(g,1) = avgarr(g,1) + calibration.ypos_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.ypos_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.ypos_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end  
end
for r=1:360
  avgarr(r,1) = avgarr(r,1) / countarr(r);
  avgarr(r,2) = avgarr(r,2) / countarr(r);
  avgarr(r,3) = avgarr(r,3) / countarr(r);
end
calibration.ypos_avg = avgarr;


avgarr = zeros(360,3);
countarr = zeros(360,1);
for r=1:size(calibration.xneg_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.xneg_data(r, 3:8));
  css_deg = css_theta * 180 / pi;
  css_deg = round(css_deg);
  if css_deg == 0
    css_deg = 360;
  end
  for g=max(1,css_deg-buffer):min(360,css_deg+buffer)
    avgarr(g,1) = avgarr(g,1) + calibration.xneg_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.xneg_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.xneg_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer+360):min(360,css_deg+buffer+360)
    avgarr(g,1) = avgarr(g,1) + calibration.xneg_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.xneg_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.xneg_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer-360):min(360,css_deg+buffer-360)
    avgarr(g,1) = avgarr(g,1) + calibration.xneg_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.xneg_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.xneg_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end  
end
for r=1:360
  avgarr(r,1) = avgarr(r,1) / countarr(r);
  avgarr(r,2) = avgarr(r,2) / countarr(r);
  avgarr(r,3) = avgarr(r,3) / countarr(r);
end
calibration.xneg_avg = avgarr;


avgarr = zeros(360,3);
countarr = zeros(360,1);
for r=1:size(calibration.yneg_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.yneg_data(r, 3:8));
  css_deg = css_theta * 180 / pi;
  css_deg = round(css_deg);
  if css_deg == 0
    css_deg = 360;
  end
  for g=max(1,css_deg-buffer):min(360,css_deg+buffer)
    avgarr(g,1) = avgarr(g,1) + calibration.yneg_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.yneg_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.yneg_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer+360):min(360,css_deg+buffer+360)
    avgarr(g,1) = avgarr(g,1) + calibration.yneg_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.yneg_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.yneg_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end
  for g=max(1,css_deg-buffer-360):min(360,css_deg+buffer-360)
    avgarr(g,1) = avgarr(g,1) + calibration.yneg_data(r, 14);
    avgarr(g,2) = avgarr(g,2) + calibration.yneg_data(r, 15);
    avgarr(g,3) = avgarr(g,3) + calibration.yneg_data(r, 16);
    countarr(g) = countarr(g) + 1;
  end  
end
for r=1:360
  avgarr(r,1) = avgarr(r,1) / countarr(r);
  avgarr(r,2) = avgarr(r,2) / countarr(r);
  avgarr(r,3) = avgarr(r,3) / countarr(r);
end
calibration.yneg_avg = avgarr;

plot3(calibration.steady_avg(:,1),calibration.steady_avg(:,2),calibration.steady_avg(:,3),'k')
grid on;
axis square;
hold on;
plot3(calibration.xpos_avg(:,1),calibration.xpos_avg(:,2),calibration.xpos_avg(:,3),'b')
plot3(calibration.ypos_avg(:,1),calibration.ypos_avg(:,2),calibration.ypos_avg(:,3),'g')
plot3(calibration.xneg_avg(:,1),calibration.xneg_avg(:,2),calibration.xneg_avg(:,3),'r')
plot3(calibration.yneg_avg(:,1),calibration.yneg_avg(:,2),calibration.yneg_avg(:,3),'c')




return;




















v = [calibration.xpos_avg(1,:); calibration.steady_avg(1,:)]
plot3(v(:,1),v(:,2),v(:,3),'k')
hold on
square axis
axis square;
hold on
grid on
v = [calibration.ypos_avg(1,:); calibration.steady_avg(1,:)]
plot3(v(:,1),v(:,2),v(:,3),'b')
v = [calibration.xneg_avg(1,:); calibration.steady_avg(1,:)]
plot3(v(:,1),v(:,2),v(:,3),'r')
v = [calibration.yneg_avg(1,:); calibration.steady_avg(1,:)]
plot3(v(:,1),v(:,2),v(:,3),'c')


v = [calibration.xpos_avg(90,:); calibration.steady_avg(90,:)]
plot3(v(:,1),v(:,2),v(:,3),'k')
hold on
square axis
axis square;
hold on
grid on
v = [calibration.ypos_avg(90,:); calibration.steady_avg(90,:)]
plot3(v(:,1),v(:,2),v(:,3),'b')
v = [calibration.xneg_avg(90,:); calibration.steady_avg(90,:)]
plot3(v(:,1),v(:,2),v(:,3),'r')
v = [calibration.yneg_avg(90,:); calibration.steady_avg(90,:)]
plot3(v(:,1),v(:,2),v(:,3),'c')



