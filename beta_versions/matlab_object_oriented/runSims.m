function runSims()

	tmp = getAllFiles(pwd);

	idx = 1;
	for i=1:size(tmp,1)
		filename = tmp{i};
		running = filename(numel(pwd)+2:end);
		
		if (strcmp(running(1:2),'s_'))
			disp(['RUNNING SIMULATION ' running])
			eval(running(1:end-2))
		end
	end
end
