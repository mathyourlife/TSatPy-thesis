function fitNormal = plotTAM3D(data,color)

if nargin < 2
  color = 'b';
end

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
L=plot3(x,y,z,[color 'o']); % Plot the original data points
set(L,'Markersize',0.2*get(L,'Markersize')) % Making the circle markers larger
set(L,'Markerfacecolor','r') % Filling in the markers
grid on;
axis square;
