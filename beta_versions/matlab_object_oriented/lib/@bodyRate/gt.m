function b = gt(br1,br2)
% Body rate 1 is greater than body rate 2
%    iff br1.w > br2.w for all 3 axes

b = sum(br1.w>br2.w) == 3;
