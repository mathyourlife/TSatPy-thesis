
l=linearSystem();

for i=1:300
  pause(0.1)
  l=l.update();
  time=l.history.y(:,1)-min(l.history.y(:,1));
  plot(time,l.history.y(:,2),'-b',time,l.history.y(:,3),'-g')
end
