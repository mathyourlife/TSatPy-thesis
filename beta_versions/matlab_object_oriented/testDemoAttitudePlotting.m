function r = testDemoAttitudePlotting()
	
	disp(' ')
	disp('Simulate visualization of state estimator')
	
	plot_axes = [
	1 0 0;
	0 1 0;
	0 0 1;
	-1 0 0;
	0 -1 0;
	0 0 -1;
	0 0 0];
	
	disk_rad = 0.4;
	total = 20;
	disk = [];
	for i=0:total
		theta = 2*pi/total*i;
		disk = [disk; cos(theta)*disk_rad sin(theta)*disk_rad 0];
	end
	
	booms = [
	0.7 0 0;
	-0.7 0 0;
	0 0 0;
	0 0.7 0;
	0 -0.7 0];
	
	disk = [disk; booms];
	
	radius = linspace(0,20,1); % For ten rings
	theta = (pi/180)*[0:45:360]; % For eight angles
	[R,T] = meshgrid(radius,theta); % Make radius/theta grid
	X = R.*cos(T) % Convert grid to cartesian coordintes
	Y = R.*sin(T);
	Z = 0.*sin(T);
	%disk = size([X Y Z])
	%surf(X,Y,Z) %Plot the sound pressure surface
	
	total = 45;
	
	u = [0 0 1]';
	theta = 2*pi/total;
	disp(sprintf('Spin rate step rotation of %0.4f deg about axis <%g %g %g>', theta*180/pi, u))
	args = struct; args.vector = u*sin(-theta/2); args.scalar = cos(-theta/2);
	qz_inc = quaternion(args);
	
	u = [0 0 1]';
	theta = 0;
	args = struct; args.vector = u*sin(-theta/2); args.scalar = cos(-theta/2);
	qz = quaternion(args);
	
	for j=1:total
		qz = qz * qz_inc;
		
		newDisk = [];
		
		nutation_angle = 2*pi/total*1.8*j;
		nutation_axis = [cos(nutation_angle) sin(nutation_angle)  0]';
		nutation_axis = nutation_axis / norm(nutation_axis);
		theta = pi/8 * sin(2*pi/total*j);
		disp(sprintf('Nutation of %0.4f deg about axis ',theta*180/pi, nutation_axis))
		args = struct; args.vector = nutation_axis*sin(-theta/2); args.scalar = cos(-theta/2);
		qn = quaternion(args);
		
		nutation_pts = [nutation_axis'; -nutation_axis']; 
		
		for i=1:size(disk,1)
			pt = disk(i,:)';
			q = qz*qn;
			newpt = q.rmatrix * pt;
			newDisk = [newDisk; newpt'];
		end
		
		[x,y,z] = sphere;
		surf(.15*x+1.2,.15*y,.15*z)  % sphere centered at (3,-2,0)
		hold on
		daspect([1 1 1]')
		
		% Plot the TSAT model initial position
		L=plot3(disk(:,1),disk(:,2),disk(:,3),['b' '-']); 
		set(L,'Markersize',0.3*get(L,'Markersize')) % Making the circle markers larger
		set(L,'Markerfacecolor','r') % Filling in the markers
		
		% Plot axes points to keep the scale/view constant
		L=plot3(plot_axes(:,1),plot_axes(:,2),plot_axes(:,3),['b' 'o']); % Plot the original data points
		set(L,'Markersize',0.7*get(L,'Markersize')) % Making the circle markers larger
		set(L,'Markerfacecolor','r') % Filling in the markers
		
		% Plot estimator state
		L=plot3(newDisk(:,1),newDisk(:,2),newDisk(:,3),['r' '-o']); % Plot the original data points
		set(L,'Markersize',0.7*get(L,'Markersize')) % Making the circle markers larger
		set(L,'Markerfacecolor','r') % Filling in the markers
		
		% Plot nutation axis
		L=plot3(nutation_pts(:,1),nutation_pts(:,2),nutation_pts(:,3), ['k' ':']); % Plot the original data points
		grid on;
		
		hold off;
		
		pause(0.05);
	end
end