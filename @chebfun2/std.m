function g = std(f,varargin)
%STD Standard deviation of a chebfun2 along one variable.
%
%  G = STD(F) returns the standard deviation of F in the y-variable
%  (default). That is, if F is defined on the rectangle [a,b] x [c,d] then
%
%                         d 
%                        /
%     std(F)^2 = 1/(d-c) | ( F(x,y) - mean(F,1) )^2 dy
%                        /
%                        c
%
%  G = STD(F,FLAG,DIM) takes the standard deviation along the y-variable if
%  DIM = 1 and along the x-variable if DIM = 2.  The FLAG is ignored and
%  kept in this function so the syntax agrees with the Matlab STD command.
%
% See also CHEBFUN/STD, CHEBFUN2/MEAN.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) )   % return an empty chebfun object. 
    g = chebfun;
    return; 
end

rect = f.corners; 

if ( nargin == 1 )
    dim = 1;   % default to mean over the y-variable. 
elseif ( nargin == 2 )
    dim = 1;   % default to mean over the y-variable. 
elseif ( nargin == 3 )
    dim = varargin{2}; 
else 
   error('CHEBFUN2:STD:NARGIN','Too many input arguments.'); 
end

if ( dim == 1 ) % y-variable.
    mx = chebfun2(@(x,y) feval(mean(f,2),x), rect);
    g = 1/(rect(4)-rect(3)) * sum( ( f - mx ).^2, 1 ) ;
    % before sqrt do a transpose to get around a chebfun bug. 
    g = sqrt(g.').'; 
elseif ( dim == 2 )  %  x-variable.
    my = chebfun2(@(x,y) feval(mean(f,1),y), rect);
    g = sqrt( 1/(rect(2)-rect(1)) * sum( ( f - my ).^2, 2 ) );
else
   error('CHEBFUN2:STD:DIM','Third argument should have value 1 or 2.'); 
end

end