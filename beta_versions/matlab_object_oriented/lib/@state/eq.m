function b = eq(s1,s2)
% Determine if the two states are equivalent

% Equivalent states have equivalent quaternions and body rates
b = s1.q==s2.q & s1.w==s2.w;