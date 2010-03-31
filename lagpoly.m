function L = lagpoly(n)
% LAGPOLY   Laguerre polynomial of degree n.
% L = LAGPOLY(N) returns the chebfun corresponding to the Laguerre polynomials 
% L_N(x) on [0,inf], where N may be a vector of positive integers.
%
% See also chebpoly, legpoly, jacpoly, and hermpoly.
%
% See http://www.maths.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2009 by The Chebfun Team. 

if nargin == 0, n = 10; end

L = chebfun; % Empty chebfun
L(:,1) = chebfun(1,[0 inf],'exps',[0 0]);
L(:,2) = chebfun(@(x) 1-x,[0 inf],'exps',[0 1]);
for k = 2:max(n) % Recurrence relation
   L(:,k+1) = chebfun(@(x) ( (2*k-1-x).*feval(L(:,k),x)-(k-1)*feval(L(:,k-1),x) )/k,[0 inf],'exps',[0 k],2*k+2);
end

% Take only the ones we want
L = L(:,n+1);