function html = matrix_to_html(A)
	html = '<table border="1" cellspacing="0" cellpadding="4"><tr>';
	A = A';
	cols = size(A, 2);
	for index = 1:numel(A)
		html = sprintf('%s<td>%s</td>', html, num2str(A(index)));
		if mod(index, cols) == 0
			html = sprintf('%s</tr>', html);
		end
	end
	html = sprintf('%s</table>', html);
end