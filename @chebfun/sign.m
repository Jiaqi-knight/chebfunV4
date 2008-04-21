function Fout = sign(F)
% SIGN  Sign function.
% G = SIGN(F) returns a piecewise constant chebfun G such that G(x) = 1 in
% the interval where F(x)>0, G(x) = -1 in the interval where F(x)<0 and
% G(x) = 0  in the interval where F(x) = 0. The breakpoints of H are
% introduced at zeros of F.

% Chebfun Version 2.0

Fout = F;
for k = 1:numel(F)
    Fout(k) = signcol(F(k));
end

% ----------------------------------
function fout = signcol(f)

if isempty(f), fout = chebfun; return, end

% If f is not real, sign returns f.
if ~isreal(get(f,'vals'))
    fout = f; return
end

r = roots(f);
ends = f.ends;
hs = norm(f.ends,inf);
if isempty(r), 
    fout = chebfun(sign(feval(f.funs,rand)),[ends(1) ends(end)]);
    return;
else
    if abs(r(1)  - ends(1)  ) > 1e-14*hs, r = [ends(1); r  ]; end 
    if abs(r(end)- ends(end)) > 1e-14*hs, r = [r; ends(end)];  end
end
nr = length(r);
newints = zeros(1,nr);
newints(1) = ends(1);
ff = [];
for i = 1:nr-1
    a = r(i); b = r(i+1);
    ff = [ff fun(sign(feval(f,(a+b)/2)))];
    newints(i+1) = b;
end
fout = set(f,'funs',ff,'ends',newints,'scl',1,'imps',zeros(1,length(newints)));
fout.imps(1,1) = sign(feval(f,ends(1)));
fout.imps(1,end) = sign(feval(f,ends(end)));