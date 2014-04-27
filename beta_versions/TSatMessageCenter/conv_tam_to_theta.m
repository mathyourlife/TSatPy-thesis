function [tam_theta, tam_mag] = conv_tam_to_theta( tam_voltages )
%CONV_MAG_TO_THETA uses the onboard 3-axes magnetometer to determine
%orientation.
%   Inputs:  vector of 3 magnetometer voltages.  Orientation is to be
%   determined.
%   
%   Output:  Orientation w.r.t. the vertical z-axis.
%
TamGain = [1.0 1.0 1.0];
TamBias = [4.0 2.5 3.0];  %Average values on a full cycle

TamTemp = [0.0 0.0 0.0];
%BhatX = 0; BhatY = 0; BhatZ = 0;

%/* Calculate Unit Magnetic Vector (Bhat) */ 
TamTemp(1) = TamGain(1) * (tam_voltages(1) - TamBias(1)); 
TamTemp(2) = TamGain(2) * (tam_voltages(2)- TamBias(2)); 
TamTemp(3) = TamGain(3) * (tam_voltages(3) - TamBias(3)); 
tam_mag = sqrt((TamTemp(1)^2) + (TamTemp(2)^2) + (TamTemp(3)^2)); 
 
%BhatX = TamTemp(2)/TamMag; 
%BhatY = -TamTemp(1)/TamMag; 
%BhatZ = TamTemp(3)/TamMag; 
 
%/* Compute TAM azimuth */
X=TamTemp(3);
Y=TamTemp(2);
tam_theta = atan(Y/X);
if X < 0
    tam_theta = tam_theta+pi();
end
if tam_theta < 0
    tam_theta = tam_theta + 2*pi();
end
