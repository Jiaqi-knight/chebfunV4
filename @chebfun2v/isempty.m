function bol = isempty(F)
%ISEMPTY empty boolean check for a chebfun2v object. 
% 
% ISEMPTY(F) returns 1 if every component of F is an empty chebfun2, and 
% return 0 otherwise. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 


bol = 0; 

if isempty(F.xcheb) || isempty(F.ycheb)
   bol = 1;  
end
end