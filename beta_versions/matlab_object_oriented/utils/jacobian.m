function A = jacobian(x)
	if isa(x,'state')
		args = struct;
		args.vector = x.w.w;
		args.scalar = 0;
		q  = quaternion(args)
		A_q = [q.x() q.vector; -q.vector' 0]
		A_w = zeros(3, 3);
		
		A = [A_q zeros(4,3); zeros(3,4) ones(3,3)];
	else
		A = NaN
	end
end
