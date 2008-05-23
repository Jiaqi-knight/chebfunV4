function s = char(d)
% CHAR   Pretty-print domain as a string.

% Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun.

if isempty(d)
  s = '   empty domain';
else
  s = sprintf('   interval [%g,%g]',d.ends([1 end]));
  if length(d.ends) > 2
    breaks = sprintf(' %g,',d.ends(2:end-1));
    breaks(end)=[];
    cws = get(0,'commandwindowsize');
    if length(breaks) > cws(1)-length(s)-24
      breaks = sprintf(' %g, ..., %g',d.ends(2),d.ends(end-1));
    end
    txt = ' with breakpoint';
    if length(d.ends) > 3
      txt = [txt 's'];
    end
    s = [ s txt breaks ];
  end
end

end