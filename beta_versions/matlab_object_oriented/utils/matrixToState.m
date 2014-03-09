function s = matrixToState(m)
	s = state();
	s.q.vector = m(1:3);
	s.q.scalar = m(4);
	s.w.w = m(5:7);
end