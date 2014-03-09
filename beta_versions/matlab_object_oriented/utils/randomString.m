function str = randomString(length)
	if (nargin == 0) length = 10; end

	str = char(64+ceil(26.*rand(length,1)))';
end
	
