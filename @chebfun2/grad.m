function varargout=grad(f)
%GRAD Numerical gradient of a chebfun2. 
%
%  [FX FY]=GRAD(F) returns the numerical gradient of the chebfun2 F.
%  FX is the derivative of F in the x direction and
%  FY is the derivative of F in the y direction. Both derivatives
%  are returned as chebfun2 objects. 
%
%  G = GRAD(F) returns a chebfun2v which represents
% 
%            G = (F_x ; F_y )
%
%  This command is shorthand for GRADIENT(F).
% 
%  See also GRADIENT. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if ( nargout <= 1 ) 
  out=gradient(f); varargout={out};
else
  [fx fy]=gradient(f); varargout = {fx, fy};
end

end