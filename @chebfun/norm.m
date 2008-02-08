function F = norm(f,n)
% NORM	Chebfun norm
%	NORM(F) = NORM(F,2).
%	NORM(F,2) = sqrt(integral from -1 to 1 F^2)).
%	NORM(F,1) = integral from -1 to 1 abs(F).
%	NORM(F,inf) = max(abs(F)).
%	NORM(F,-inf) = min(abs(F)).
%

% Ricardo Pachon and Lloyd N. Trefethen, 2007, Chebfun Version 2.0
% Rodrigo Platte, Feb. 2008

if (nargin==1), n=2; elseif strcmp(n,'inf'), n=inf; elseif strcmp(n,'-inf'), n=-inf; end

if n==2
    F=0;
    for k=1:length(f.ends)-1
        F = F+ .5*(f.ends(k+1)-f.ends(k))*norm(f.funs{k})^2;
    end
    F=sqrt(F);
elseif n==1
    F = sum(abs(f));
elseif n==inf
    F = max(max(f),-min(f));
elseif n==-inf
    F = min(abs(f));
else
    error('Unknown norm');
end
F = real(F);   % discard possible imaginary rounding errors
