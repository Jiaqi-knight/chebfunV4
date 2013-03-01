function varargout = sphere(r)
%SPHERE Generate sphere
%
%  SPHERE(R), where R is a chebfun2 on the domain [0 pi]x[0 2*pi] plots 
%  the "sphere" of radius R(th,phi).
%
%  [X Y Z]=SPHERE(R) returns X, Y, and Z as chebfun2 objects such that
%  SURF(X,Y,Z) plots a sphere of radius R(th,phi). 
% 
%  F = SPHERE(R) returns the chebfun2v representing the sphere of radius R.
%  SURF(F) plots a sphere of radius R. 
%
% For the sphere: 
%   r = chebfun2(@(th,phi) 1+0*th,[0 pi 0 2*pi]);
%   sphere(r)
%
% For a sea shell:
%   r = chebfun2(@(th,phi) phi,[0 pi 0 2*pi]);
%   sphere(r)
% 
% See also CYLINDER.

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Sphere with radius r(th,phi).  
rect = [0 pi 0 2*pi]; 
th = chebfun2(@(th,phi) th,rect);
phi = chebfun2(@(th,phi) phi,rect);

x = r.*sin(th).*cos(phi);
y = r.*sin(th).*sin(phi);
z = r.*cos(th);

if ( nargout == 0 )
    surf(x,y,z); axis equal
elseif ( nargout == 1 )
    varargout = { [x; y; z] };
else
    varargout = { x, y, z };
end
    
end