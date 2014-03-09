function arr = arr_push(arr,item)
%arr_push Pushes the passed item onto the end of array provided and returns the new array
%
%	arr = arr_push(arr,item)
	idx = size(arr,2) + 1;
	%display(sprintf('Adding item at index %d',idx))
	arr{idx} = item;
end