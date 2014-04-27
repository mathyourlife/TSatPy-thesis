function r = listFiles()

  tmp = getAllFiles(pwd);

  idx = 1;
  for i=1:size(tmp,1)
    if(strcmp(tmp{i}(end-1:end),'.m'))
      filename = tmp{i}(size(pwd,2)+2:end);
      
      disp(' ');
      filename = strrep(filename, '\', '/');
      latexName = strrep(filename, '_', '\_');
      disp(sprintf('\\section{File %s}',latexName))
        disp(sprintf('\\lstinputlisting{../TSat/%s}', filename));
    end
  end

end
