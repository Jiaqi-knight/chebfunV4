function val = get(f, propName)
% GET Get chebfun properties.
% P = GET(F,PROP) returns the property P specified in the string PROP from
% the chebfun F. The string PROP can be 'funs', 'ends' or 'imps', to
% retrieve the cell array of funs, the vector with endpoints or the matrix
% with Dirac impulses respectively.
 
% Ricardo Pachon and Lloyd N. Trefethen, 2007, Chebfun Version 2.0
switch propName
    case 'funs'
        val = f.funs;
    case 'ends'
        val = f.ends;
    case 'imps'
        val = f.imps;
    case 'scl'
        val = f.scl;    
    case 'vals'
        funs = f.funs;
        val = [];
        for i = 1:f.nfuns
           val = [val;get(funs(i),'vals')];
        end
    otherwise
        error([propName,' Is not a valid chebfun property'])
end
