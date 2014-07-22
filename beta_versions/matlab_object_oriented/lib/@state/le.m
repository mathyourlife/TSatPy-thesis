function b = le(s1,s2)
% State 1 is greater than state 2
%    iff both quaternion and body rates for s1 are > s2
%    testing purposes mostly

b = s1.q <= s2.q && s1.w <= s2.w;
