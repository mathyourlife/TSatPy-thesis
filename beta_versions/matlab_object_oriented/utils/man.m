% MAN - manual (alias for help)
%
% My linux preference is showing.  I kept on typing 
% "man" expecting it to work so wrote this alias utility.
%
% Inputs:
% @func
%    value - Name of the function to print the manual
%    type - char
function man(varargin)
	if nargin == 0
		disp('What function did you want help with?')
		return;
	end
	help(varargin{:})