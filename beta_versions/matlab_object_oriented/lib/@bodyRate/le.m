function b = le(br1,br2)
% Body rate 1 is less than or equal to body rate 2
%    iff br1.w < br2.w for all 3 axes

b = sum(br1.w<=br2.w) == 3;
