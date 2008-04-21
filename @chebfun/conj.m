function F = conj(F)
% CONJ	Complex conjugate 
% CONJ(F) is the complex conjugate  of F.

% Chebfun Version 2.0

for k = 1:numel(F)
    funs = F(k).funs;
    for j = 1:numel(funs)
        funs(j) = conj(funs(j));
    end
    F(k).funs = funs;
end
