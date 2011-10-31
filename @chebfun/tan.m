function Fout = tan(F)
% TAN   Tangent of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(get(F(k),'exps')<0), error('CHEBFUN:tan:inf',...
        'TAN is not defined for functions which diverge to infinity'); end
end

Fout = comp(F, @(x) tan(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(sec(F).^2); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'tan');
    Fout(k).ID = newIDnum;
end