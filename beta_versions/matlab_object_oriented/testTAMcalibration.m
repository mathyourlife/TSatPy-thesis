clear all

load('TAM-Calibration2.mat')
TAMplot = tPlot;

item = struct;
item.type = 'plot3';

item.data.x = [0 1]';
item.data.y = [0 1]';
item.data.z = [0 1]';
item.name = '+x';
item.style = 'r-';
TAMplot = TAMplot.addSeries(item);
item.name = '+y';
item.style = 'b-';
TAMplot = TAMplot.addSeries(item);
item.name = '-x';
item.style = 'g-';
TAMplot = TAMplot.addSeries(item);
item.name = '-y';
item.style = 'c-';
TAMplot = TAMplot.addSeries(item);
item.name = 'm';
item.style = 'k-';
TAMplot = TAMplot.addSeries(item);

width=14;

testdata = test.angle240;
success = 0;
total = 0;
angles = zeros(size(testdata,1)-width,1);
for t=1:1:size(testdata,1)-width
  total = total + 1;
  if width == 0
    sensordata = testdata(t,:);
  else
    sensordata = mean(testdata(t:t+width,:));
  end

  [ css_mag, css_theta ] = conv_css_to_theta(sensordata(3:8));
  css_deg = css_theta * 180 / pi;
  css_deg = round(css_deg);
  if css_deg == 0
    css_deg = 360;
  end

  vec = sensordata(14:16) - calibration.steady_avg(css_deg,:);

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
    res1 = [f 0]; 
  elseif (ypd == arr(4))
    first = '+y';
    f = ypd;
    b = vec - yp;
    res1 = [0 f];
  elseif (xnd == arr(4))
    first = '-x';
    f = xnd;
    b = vec - xn;
    res1 = [-f 0]; 
  elseif (ynd == arr(4))
    success = success + 1;
    first = '-y';
    f = ynd;
    b = vec - yn;
    res1 = [0 -f]; 
  end


  if (xpd == arr(3))
    second = '+x';
    s = dot(b,xp);
    %s = xpd;
    res2 = [s 0]; 
  elseif (ypd == arr(3))
    second = '+y';
    s = dot(b,yp);
    %s = ypd;
    res2 = [0 s]; 
  elseif (xnd == arr(3))
    second = '-x';
    s = dot(b,xn);
    %s = xnd;
    res2 = [-s 0]; 
  elseif (ynd == arr(3))
    second = '-y';
    s = dot(b,yn);
    %s = ynd;
    res2 = [0 -s]; 
  end

  if (1)
    v=[vec;0 0 0];
    item.name = ['m'];
    item.data.x = v(:,1); item.data.y = v(:,2); item.data.z = v(:,3);
    TAMplot=TAMplot.updateSeries(item);
%    plot3(v(:,1),v(:,2),v(:,3),'g')
%    hold on;
%    grid on;
%    square axis;
    v=[xp;0 0 0];
    item.name = ['+x'];
    item.data.x = v(:,1); item.data.y = v(:,2); item.data.z = v(:,3);
    TAMplot=TAMplot.updateSeries(item);
%    plot3(v(:,1),v(:,2),v(:,3),'k')
    v=[yp;0 0 0];
    item.name = ['+y'];
    item.data.x = v(:,1); item.data.y = v(:,2); item.data.z = v(:,3);
    TAMplot=TAMplot.updateSeries(item);
%    plot3(v(:,1),v(:,2),v(:,3),'b')
    v=[xn;0 0 0];
    item.name = ['-x'];
    item.data.x = v(:,1); item.data.y = v(:,2); item.data.z = v(:,3);
    TAMplot=TAMplot.updateSeries(item);
%    plot3(v(:,1),v(:,2),v(:,3),'r')
    v=[yn;0 0 0];
    item.name = ['-y'];
    item.data.x = v(:,1); item.data.y = v(:,2); item.data.z = v(:,3);
    TAMplot=TAMplot.updateSeries(item);
%    plot3(v(:,1),v(:,2),v(:,3),'c')
    square axis;
    axis([-1 1 -1 1 -1 1]);
  end

  %disp(sprintf('First %s:%0.4f Second %s:%0.4f',first,f,second,s))
  res = res1 + res2;
  angle = atan2(res(2),res(1))*180/pi;
  if angle < 0
    angle = angle + 360;
  end
  %disp(sprintf('%0.2f',angle))
  angles(t) = angle;
  pause(0.01);
end

figure(2)
plot(angles)

disp(sprintf('Results avg:%0.4f  stdev:%0.4f',mean(angles),std(angles)))
%disp(sprintf('Success rate %0.4f with width %d',success/total,width))
