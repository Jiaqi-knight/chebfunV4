function varargout = surf(f,varargin)
%SURF  Surface plot of a chebfun2.
%
% SURF(F,C) plots the colored parametric surface defined by F and the
% matrix C. The matrix C, defines the colouring of the surface.
%
% SURF(F) uses colors proportional to surface height.
%
% SURF(X,Y,F,...) is the same as SURF(F,...) when X and Y are chebfun2
% objects except X and Y supplies the plotting locations are  mapped by
% X and Y.
%
% SURF(...,'PropertyName',PropertyValue,...) sets the value of the
% specified surface property.  Multiple property values can be set
% with a single statement.
%
% SURF returns a handle to a surface plot object.
%
% See also PLOT, SURFC.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) ) % check for empty chebfun2.
    h=surf([]);  % call the empty surf command.
    if nargout == 1
        varargout = {h};
    end
    return;
end

pref2 = chebfun2pref;
minplotnum = pref2.plot_numpts; % How dense to make the samples.
defaultopts = {'facecolor','interp','edgealpha',.5,'edgecolor','none'};

% Number of points to plot
j = 1; argin = {};
while ( ~isempty(varargin) )
    if strcmpi(varargin{1},'numpts')
        minplotnum = varargin{2};
        varargin(1:2) = [];
    else
        argin{j} = varargin{1};
        varargin(1) = [];
        j = j+1;
    end
end

if isempty(argin)
    argin = {};
end

if ( isa(f,'chebfun2') )
    if ( ( nargin == 1 ) || ( nargin > 1 && ~isempty(argin) && ~isa(argin{1},'chebfun2') ) || ( nargin == 3 && isempty(argin))) % surf(f,...)
        % Get domain.
        rect = f.corners;
        x = chebfun2(@(x,y) x,rect); y = chebfun2(@(x,y) y,rect);
        h = surf(x,y,f,defaultopts{:},argin{:},'numpts',minplotnum);
    elseif ( nargin > 2)                    %surf(x,y,f,...), with x, y, f chebfun2 objects
        x = f; y = argin{1};
        if isa(y,'chebfun2')
            % check domains of x and y are the same.
            rect = x.corners; rectcheck = y.corners;
            if any(rect - rectcheck)
                error('CHEBFUN2:SURF:DATADOMAINS','Domains of chebfun2 objects do not match.');
            end
        end
        xdata = linspace(rect(1),rect(2),minplotnum);
        ydata = linspace(rect(3),rect(4),minplotnum);
        [xx,yy] = meshgrid(xdata,ydata);
        x = feval(x,xx,yy); 
        y = feval(y,xx,yy);
        if ( isa(argin{2},'chebfun2') )      % surf(x,y,f,...)
            vals = feval(argin{2},xx,yy);
            if nargin < 4   % surf(x,y,f)
                C = vals;
            elseif ( isa(argin{3},'double') )    % surf(x,y,f,C,...)
                C = argin{3};
                argin(3)=[];
            elseif ( isa(argin{3},'chebfun2'))  % colour matrix given as a chebfun2.
                C = feval(argin{3},xx,yy);
                argin(3)=[];
            else
                C = vals;
            end
            
            % make some correct to C, for prettier plotting.
            if ( norm(C - C(1,1),inf) < 1e-10 )
                % If vals are very close up to round off then the color scale is
                % hugely distorted.  This fixes that.
                [n,m]=size(C);
                C = C(1,1)*ones(n,m);
            end
            
            h = surf(x,y,vals,C,defaultopts{:},argin{3:end});
            xlabel('x'), ylabel('y')
            
            % There is a bug in matlab surf plot when vals are very nearly a constant.
            % Fix this manually by resetting axis scaling.
            if norm(vals - vals(1,1),inf)<1e-10*norm(vals,inf) && ~(norm(vals - vals(1,1),inf)==0)
                v = vals(1,1); absv = abs(v);
                zlim([v-.5*absv v+.5*absv])
            end
            
        else
            error('CHEBFUN2:SURF:INPUTS','The third argument should be a chebfun2 if you want to supply chebfun2 data.')
        end
    else  %surf(f,C)
        rect = f.corners;
        x = chebfun2(@(x,y) x,rect); y = chebfun2(@(x,y) y,rect);
        h = surf(x,y,f,argin{1},defaultopts{:},argin{2:end});
    end
else     % surf(X,Y,f,...)
    error('CHEBFUN2:SURF:INPUTS','Data should be given as chebfun2 objects \n For example: \n x = chebfun2(@(x,y)x); y = chebfun2(@(x,y)y);\n surf(x,y,f)');
end


if nargout > 0
    varargout = {h};
end

end