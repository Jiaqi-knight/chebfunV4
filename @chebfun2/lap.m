function L = lap(f)
%LAP Laplacian of a chebfun2.
%
% L = LAP(F) returns a chebfun2 representing the Laplacian of F. 
%
% This is shorthand for LAPLACIAN(F)
%
% See also LAPLACIAN.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

L = laplacian(f);

end