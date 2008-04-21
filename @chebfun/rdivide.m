function Fout = rdivide(F1,F2)
% ./	Right chebfun division
% F./G is the chebfun division of G into F.

% Chebfun Version 2.0

if (isempty(F1) || isempty(F2)), Fout = chebfun; return; end

if isa(F1,'chebfun')&&isa(F2,'chebfun')
    if size(F1)~=size(F2)
        error('Quasi-matrix dimensions must agree')
    end
    Fout = F1;
    for k = 1:numel(F1)
        Fout(k) = rdividecol(F1(k),F2(k));
    end
elseif isa(F1,'chebfun')
    Fout = F1;
    for k = 1:numel(F1)
        Fout(k) = rdividecol(F1(k),F2);
    end
else
    Fout = F2;
    for k = 1:numel(F2)
        Fout(k) = rdividecol(F1,F2(k));
    end
end
    
% ----------------------------------------------------
function fout = rdividecol(f1,f2)

if (isempty(f1) || isempty(f2)), fout=chebfun; return; end

if isa(f2,'double')
    if f2 ==  0, error('Division by zero'), end
    fout = f1*(1/f2);  
    
elseif ~isempty(roots(f2))
       error('Division by zero')
elseif isa(f1,'double')    
    if f1 == 0, fout =chebfun(0); 
    else
        fout = chebfun(@(x) f1./feval(f2,x), f2.ends);
    end
else
    fout = chebfun(@(x) feval(f1,x)./feval(f2,x), union(f1.ends,f2.ends));
end
    