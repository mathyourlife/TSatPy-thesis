function [ css_mag, css_theta ] = conv_css_to_theta( css_voltages )
%CONV_CSS_TO_THETA uses the six sun sensors to find the direction to the 
%largest source of light.
%   Inputs:  vector of 6 css voltages.  CSS 1 is assumed to be zero
%   degrees.  An offset may be added to this code if a different zero is
%   needed.
%   
%   Outputs:  Using a resultant force style analysis.  The resultant
%   magnitude showing the strength of the signal and the resultant angle
%   theta are returned.
%
if (size(css_voltages,1)==1 || size(css_voltages,2)==6)
  css_voltages = css_voltages';
end 
css_x=0;
css_y=0;
for n = 1:size(css_voltages,1)
    css_x = css_x + cos((n-1)*pi()/3)*css_voltages(n);
    css_y = css_y + sin((n-1)*pi()/3)*css_voltages(n);
end
css_mag = (css_x^2+css_y^2)^0.5;
css_theta = atan(css_y/css_x);
if css_x < 0
    css_theta = css_theta+pi();
end
if css_theta < 0
    css_theta = css_theta + 2*pi();
end
