% JACCSD Jacobian through complex step differentiation
% [z J] = jaccsd(f,x)
% z = f(x)
% J = f'(x)
%
% By Yi Cao at Cranfield University, 02/01/2008
%
function [z,A] = jaccsd(fun,x)
	z=fun(x);
	n=numel(x);
	m=numel(z);
	A=zeros(m,n);
	h=n*eps;
	for k=1:n
		x1=x;
		x1(k)=x1(k)+h*i;
		A(:,k)=imag(fun(x1))/h;
	end
end