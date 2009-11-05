function Fout = csc(F)
% CSC   Cosecant of a chebfun.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team. 

for k = 1:numel(F)
    if any(get(F(:,k),'exps')), error('CHEBFUN:csc:inf',...
        'Csc is not defined for functions which diverge to infinity'); end
end

Fout = comp(F, @(x) csc(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('@(u) diag(-diag(cot(F))*csc(F))*jacobian(F,u)',{'F'},{F(k)});
    Fout(k).ID = newIDnum();
end