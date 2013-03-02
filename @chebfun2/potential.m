function G = potential(f)
%POTENTIAL  2D vector potential of a chebfun2.
%
% G = POTENTIAL(F) where F is a chebfun2 returns a vector-valued
% chebfun2v with two components such that F = curl(G).  
% 
% Note this is NOT the 3D vector potential because Chebfun2 represents
% functions with two variables.
%
% This function is slow and requires improvements.  It works for small
% degree bivariate polynomials.
% 
% See also CHEBFUN2V/CURL.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if ( isempty(f) )   % empty check.
    G = chebfun2v; 
    return; 
end

rect = f.corners; 
x = chebfun2(@(x,y) x, rect); 
y = chebfun2(@(x,y) y, rect); 

% One can show that:
%      f(x,y) = dQ/dx - dP/dy, 
% where Q = x.*S(x,y), P = -y.*S(x,y), and 
%  S(x,y) = integral( s.*f(s.*x,s.*y), [0 1] ) 
S = chebfun2(@(x,y) sum( chebfun(@(s) feval(f, s.*x, s.*y).*s, [0 1] )), rect,...
                                                              'vectorize');

Q = x.*S; P = -y.*S; 
G = [P; Q];

end