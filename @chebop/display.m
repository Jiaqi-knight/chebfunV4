function display(A)
% DISPLAY Pretty-print a chebop.
% DISPLAY is called automatically when a statement that results in a chebop
% output is not terminated with a semicolon.


loose = ~isequal(get(0,'FormatSpacing'),'compact');
if loose, fprintf('\n'), end
disp([inputname(1) ' = chebop']);
if loose, fprintf('\n'), end
s = char(A);
if ~loose   
  s( all(isspace(s),2), : ) = [];  % remove blank lines
end
disp(s)
if loose, fprintf('\n'), end

end

