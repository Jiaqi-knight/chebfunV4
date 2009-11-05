function Fout = acot(F)
% ACOT   Inverse cotangent of a chebfun.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team. 

Fout = comp(F, @(x) acot(x));
for k = 1:numelf(F)
    Fout(k).jacobian = anon('@(u) diag(-1./(1+F.^2))*jacobian(F,u)',{'F'},{F(k)});
    Fout(k).ID = newIDnum();  
end