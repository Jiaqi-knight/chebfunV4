function [p,q,s] = cf(f,m,n,M)
% Caratheodory-Fejer approximation
%
% [P,Q] = CF(F,M,N): degree (M/N) rational CF approximant to chebfun F
%         defined in [a b] (which must consist of just a single fun)
%
% [P,Q,S] = CF(F,M,N): same plus S, the associated CF
%           singular value, an approximation to the minimax error
%
% ... = CF(F,M,N,K): use only K-th partial sum in Chebyshev expansion of F
%
% For polynomial CF approximation, use N = 0 or N = [] or only provide two
% input arguments.
%
% Example:
%   f = chebfun('log(1.2+cos(exp(2*x)))');
%   [p,q] = cf(f,10,10);
%   plot(f-p./q)
%
% CF = Caratheodory-Fejer approximation is a near-best approximation
% that is often indistinguishable from the true best approximation
% as computed by REMEZ(F,M), but often much faster to compute. 
% See M. H. Gutknecht and L. N. Trefethen, "Real polynomial Chebyshev
% approximation by the Caratheodory-Fejer method", SIAM J. Numer.
% Anal. 19 (1982), 358-371, and L. N. Trefethen and M. H. Gutknecht, 
% "The Caratheodory-Fejer method for real rational approximation", SIAM J.
% Numer. Anal. 20 (1983), 420-436.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2009 by The Chebfun Team. 

if numel(f) > 1, error('CHEBFUN:cf:quasi',...
  'CF does not currently support quasimatrices'); end

if any(get(f,'exps')), error('CHEBFUN:cf:inf',...
  'CF does not currently support functions with nonzero exponents'); end

if (nargin < 4), M = length(f) - 1; end
if (nargin < 3), n = 0; end

d = domain(f);

if m >= M,
  p = f; q = chebfun(1,d);
  return
end

a = chebpoly(f); a = a(end-M:end);

if (n == 0) | isempty(n),         % polynomial case
  if m==M-1
    p = chebfun(chebpolyval(a(2:M+1)),d); q = chebfun(1,d);
    return
  end
  c = a(M-m:-1:1);
  [V,D] = eig(hankel(c));
  [s,i] = max(abs(diag(D)));
  u = V(:,i);
  u1 = u(1); uu = u(2:M-m);
  b = c;
  for k = m:-1:-m
    b = [-(b(1:M-m-1)*uu)/u1 b];
  end
  pk = a(M-m+1:M+1) - [b(1:m) 0] - b(2*m+1:-1:m+1);
  p = chebfun(chebpolyval(pk),d);
  q = chebfun(1,d);
else                              % rational case
  a(end) = 2*a(end);
  c = a(M+1-abs(m-n+1:M));
  [U,S,V] = svd(hankel(c));
  s = S(n+1,n+1); v = V(:,n+1); u = U(:,n+1);
  
  zr = roots(v); zr = zr(abs(zr)>1); zr = .5*(zr+1./zr);
  qt = chebfun(@(x) real(prod(x-zr)/prod(-zr)),length(zr)+1,'vectorise');
  q = chebfun; q = define(q,d,qt); n = length(zr);

  u = u(end:-1:1);
  bt = chebfun(@(x) real(exp(1i*acos(x)*M).*polyval(u,exp(1i*acos(x))) ...
    ./polyval(v,exp(1i*acos(x))))); b = chebfun; b{d,:} = bt;
  Rt = f - s*b;
  ct = chebpoly(Rt);
  ct = ct(end:-1:end-m); ct(1) = 2*ct(1);

% The code below computes the first chebcoeffs of 1./q by solving a linear
%  system. Does not work because of ill-conditioning...
%  
%   qtc = chebpoly(qt); qtc = qtc(end:-1:1); qtc(1) = 2*qtc(1);
%   qtc = [qtc, zeros(1,2*m)];
%   A = [qtc(1)/2, qtc(2:end)];
%   for i = 1:n-1,
%     tmp = [qtc(i+1:-1:2), qtc(1:n+1+min(0,2*m-i)), zeros(1,2*m-i)] + ...
%       [0, qtc(i+2:n+1), zeros(1,2*m+i)];
%     A = [A; tmp];
%   end
%   for i = n:2*m+n,
%     tmp = [qtc(i+1:-1:2), qtc(1:min(2*m+n-i,i)+1), zeros(1,2*m+n-2*i)];
%     A = [A; tmp];
%   end
%   gam = A\[2;zeros(2*m+n,1)]; gam = gam(1:2*m+1).';
  
  gam = chebpoly(1./q); gam = [zeros(1,2*m+1-length(gam)),gam];
  gam = gam(end:-1:end-2*m); gam(1) = 2*gam(1);
  gam = toeplitz(gam);
  bc = 2*[ct(m+1:-1:2) ct(1:m+1)]/gam;
  bc = bc(m+1:2*m+1); bc(1) = bc(1)/2;
  p = chebfun(chebpolyval(bc(end:-1:1)),d);
end
