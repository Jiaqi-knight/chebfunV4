function f = ctor_ini()

% Copyright 2002-2008 by The Chebfun Team. 
% See www.comlab.ox.ac.uk/chebfun.html

f = struct([]);
% The following fields should always be allocated automatically with the
% function set.
f(1).funs = [];
f(1).nfuns = [];
f(1).scl = [];
% The following fields can be manipulated manually.
f(1).ends = [];
f(1).imps = [];
f(1).trans = [];
