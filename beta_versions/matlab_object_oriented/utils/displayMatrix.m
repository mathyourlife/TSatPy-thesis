function m_str = displayMatrix(A)
	char='|';
	space=' ';
	
	for b=1:size(A,1)
		bars(b)=char;
		spaces(b)=space;
	end
	bars = bars';
	spaces = spaces';
	
	m_str = [spaces bars num2str(A) bars spaces];
end