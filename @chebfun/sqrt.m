function Fout = sqrt(F)
% SQRT   Square root.
% SQRT(F) returns the square root chebfun of a positive or negative chebfun F.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team.


% Fout = comp(F, @(x) sqrt(x));

for k = 1:numel(F)
    Fout(k) = sqrtcol(F(k));
    Fout(k).jacobian = anon('@(u) (1/2)*diag(1./Fout)*jacobian(F,u)',{'Fout','F'},{Fout(k) F(k)});
    Fout(k).ID = newIDnum;
end

end


function Fout = sqrtcol(F)

% Add breakpoints at roots
F = add_breaks_at_roots(F);
Fout = F;

% Loop through funs
for k = 1:F.nfuns
    f = extract_roots(F.funs(k));
    exps = f.exps;
    f.exps = [0 0];
    fout = compfun(f, @(x) sqrt(x));
    fout.exps = exps/2;
    fout = replace_roots(fout);
    Fout.funs(k) = fout;
end

Fout.imps = sqrt(Fout.imps);

end
