function s = uminus(a)
% Calculate the of two state variables.

q = -a.q;
w = -a.w;

s = state(q,w);