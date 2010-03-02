function F = cumsum(F,n)
%CUMSUM   Indefinite integral.
% CUMSUM(F) is the indefinite integral of the chebfun F. Dirac deltas 
% already existing in F will decrease their degree.
%
% CUMSUM(F,N) returns the Nth integral of F. If N is not an integer CUMSUM(F,N)
% returns the fractional integral of order N as defined by the
% Riemann–Liouville integral.
%
% CUMSUM does not currently support chebfuns whose indefinite integral diverges
% (i.e. has exponents <-1) when using nontrivial maps. Even for chebfuns
% with a bounded definite integral, nontrivial maps will be slow.
%
% See http://www.maths.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2009 by The Chebfun Team. 

if nargin==1, n=1; end

if round(n)~=n
    F = fraccalc(F,n);
else
    for j = 1:n
        for k = 1:numel(F)
            F(k) = cumsumcol(F(k));
        end
    end
end

% -------------------------------------
function fout = cumsumcol(f)

if isempty(f), fout = chebfun; return, end

exps = get(f,'exps');
ends = f.ends;

for k = 1:f.nfuns
    if all(exps(k,:)) && any(exps(k,:)<=-1)
        midpt = mean(ends(k:k+1));
        if ~isnan(midpt)
            index = struct('type','()','subs',{{midpt}});
            f = subsasgn(f,index,feval(f,midpt));
        elseif all(isinf(ends(k:k+1)))
            midpt = f.funs(k).map.par(4);
            fm = feval(f,midpt);
            funs = f.funs(1);
            funs(1) = restrict(f.funs(1),[-inf,midpt]);
            funs(2) = restrict(f.funs(1),[midpt,inf]);
            f.funs = funs;  f.nfuns = 2;  f.ends = [-inf midpt inf];
            f.imps = [f.imps(:,1) 0*f.imps(:,1) f.imps(:,2)];
            f.imps(1,2) = fm;
        end        
    end
end

ends = f.ends;

if size(f.imps,1)>1
    imps = f.imps(2,:);
else
    imps = zeros(size(ends));
end

Fb = imps(1);
funs = f.funs;
for i = 1:f.nfuns
    funs(i) = cumsum(funs(i)) + Fb;
    Fb = funs(i).vals(end) + imps(i+1);
end

vals = zeros(1,f.nfuns+1);
for i = 1:f.nfuns    
    vals(i) = get(funs(i),'lval');    
end
vals(f.nfuns+1) = get(funs(f.nfuns),'rval');

fout = set(f, 'funs', funs); 
fout.imps = [vals; f.imps(3:end,:)];

fout.jacobian = anon('@(u) cumsum(domain(f))*jacobian(f,u)',{'f'},{f});
fout.ID = newIDnum();