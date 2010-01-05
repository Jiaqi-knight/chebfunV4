function uu = pde15s( pdefun, t, u0, bc, opt)
%PDE15S  Solve PDEs using the chebfun system
% UU = PDE15s(PDEFUN, T, U0, BC) where PDEFUN is a handle to a function with 
% arguments u, t, x, and D, T is a vector, U0 is a chebfun, and BC is a 
% chebop boundary condition structure will solve the PDE dUdt = PDEFUN(U,t,x)
% with the initial condition U0 and boundary conditions BC over the time
% interval T. D in PDEFUN represents the differential operator of U, and
% D(u,K) will represent the Kth derivative of u.
%
% Example 1: Nonlinear Advection
%   [d,x] = domain(-1,1);
%   u = exp(3*sin(pi*x));
%   f = @(u,t,x,D) -(1+0.6*sin(pi*x)).*D(u);
%   u = pde15s(f,0:.05:3,u,'periodic');
%   surf(u,0:.05:3)
%
% Example 2: Kuramoto-Sivashinsky
%   [d,x] = domain(-1,1);
%   I = eye(d); D = diff(d);
%   u = 1 + 0.5*exp(-40*x.^2);
%   bc.left = struct('op',{I,D},'val',{1,2});
%   bc.right = struct('op',{I,D},'val',{1,2});
%   f = @(u,D) u.*D(u)-D(u,2)-0.006*D(u,4);
%   u = pde15s(f,0:.01:.5,u,bc);
%   surf(u,0:.01:.5)
% 
% Example 3: Chemical reaction (system)
%    [d,x] = domain(-1,1);  
%    u = [ 1-erf(10*(x+0.7)) , 1 + erf(10*(x-0.7)) , chebfun(0,d) ];
%    f = @(u,t,x,D)  [ 0.1*D(u(:,1),2) - 100*u(:,1).*u(:,2) , ...
%                      0.2*D(u(:,2),2) - 100*u(:,1).*u(:,2) , ...
%                     .001*D(u(:,3),2) + 2*100*u(:,1).*u(:,2) ];
%    bc = 'neumann';     
%    uu = pde15s(f,0:.1:3,u,bc);
%
% UU = PDE15s(PDEFUN, T, U0, BC, OPTS) will use nondefault options as
% defined by the structure returned from OPTS = PDESET.
%
% There is some support for nonlinear boundary conditions, such as
%    BC.LEFT = @(u,t,x,D) D(u) + u - (1+2*sin(10*t));
%    BC.RIGHT = struct( 'op', 'dirichlet', 'val', @(t) .1*sin(t));
%
% See also chebfun/examples/pde15s_demos, pdeset, ode15s
%
% See http://www.maths.ox.ac.uk/chebfun for chebfun information.

global order
order = 0; % Initialise to zero

% Default options
tol = 1e-5;             % 'eps' in chebfun terminology
doplot = 1;             % plot after every time chunk?
dohold = 0;             % plot after every time chunk?

% No options given
if nargin < 5 || isempty(opt), opt = pdeset; end

% PDE solver options
if ~isempty(opt.Eps), tol = opt.Eps; end
if ~isempty(opt.Plot), doplot = strcmpi(opt.Plot,'on'); end
if ~isempty(opt.HoldPlot), dohold = strcmpi(opt.HoldPlot,'on'); end

% ODE tolerances
atol = odeget(opt,'AbsTol',1e-6);
rtol = odeget(opt,'RelTol',1e-5);

% AbsTol and RelTol must be <= Tol
if tol < atol, opt = tol/10; end
if tol < rtol, opt = tol/10; end

% Get the domain
d = domain(u0);

% Determine the size of the system
syssize = min(size(u0));

% If the differential operator is passed, redefine the anonymous function
if nargin(pdefun) == 2
    pdefun = @(u,t,x) pdefun(u,@Diff);
    % get the order (a global variable) by evaluating the RHS with NaNs
    tmp = repmat(NaN,1,syssize);
    pdefun(tmp);
elseif nargin(pdefun) == 4
    pdefun = @(u,t,x) pdefun(u,t,x,@Diff);
    tmp = repmat(NaN,1,syssize);
    pdefun(tmp,NaN,NaN); % (as above)
end

% some error checking on the bcs
if ischar(bc) && (strcmpi(bc,'neumann') || strcmpi(bc,'dirichlet'))
    if order > 2
        error('CHEBFUN:pde15s:bcs',['Cannot assign "', bc, '" boundary conditions to a ', ...
        'RHS with differential order ', int2str(order),'.']);
    end
    bc = struct( 'left', bc, 'right', bc);
end
if iscell(bc) && numel(bc) == 2
    bc = struct( 'left', bc{1}, 'right', bc{2});
end

% Shorthand bcs
if isfield(bc,'left') && ischar(bc.left)
    if strcmpi(bc.left,'dirichlet'),    A = eye(d);
    elseif strcmpi(bc.left,'neumann'),  A = diff(d);
    end
    Z = zeros(d);        op = cell(1,syssize);
    for k = 1:syssize,   op{k} = [repmat(Z,1,k-1) A repmat(Z,1,syssize-k)];  end
    bc.left = struct('op',op,'val',repmat({0},1,syssize));
end
if isfield(bc,'right') && ischar(bc.right)
    if strcmpi(bc.right,'dirichlet'),    A = eye(d);
    elseif strcmpi(bc.right,'neumann'),  A = diff(d);
    end
    Z = zeros(d);        op = cell(1,syssize);
    for k = 1:syssize,   op{k} = [repmat(Z,1,k-1) A repmat(Z,1,syssize-k)];  end
    bc.right = struct('op',op,'val',repmat({0},1,syssize));
end

% Sort out boundary conditions (Left)
nllbc = []; nlbcs = {}; nlrbc = []; rhs = {};
if isfield(bc,'left') && numel(bc.left) > 0
    if isa(bc.left,'function_handle')
        bc.left = struct( 'op', bc.left, 'val', 0);
    elseif isa(bc.left,'linop')
        bc.left = struct( 'op', bc.left, 'val', 0);
    elseif iscell(bc.left)
        bc.left = struct( 'op', bc.left);
    end
    % Extract nonlinear conditions
    for k = 1:numel(bc.left)
        opk = bc.left(k).op;
        if isnumeric(opk) && syssize == 1
            bc.left(k).op = repmat(eye(d),1,syssize);
            bc.left(k).val = opk;
        end
        if isa(opk,'function_handle')
            nllbc = [nllbc k];             % Store positions
            if     nargin(opk) == 2,  nlbcs = [nlbcs {@(u,t,x) opk(u,@Diff)} ];
            elseif nargin(opk) == 4,  nlbcs = [nlbcs {@(u,t,x) opk(u,t,x,@Diff)} ]; 
            end
            bc.left(k).op = repmat(eye(d),1,syssize);
        end
        if isfield(bc.left(k),'val') && ~isempty(bc.left(k).val)
                rhs{k} = bc.left(k).val;
        else    rhs{k} = 0; end
        bc.left(k).val = 0;  % set to homogenious (to remove function handles
    end     
elseif isfield(bc,'right') 
    bc.left = [];
end
% (Right)
numlbc = numel(rhs);
if isfield(bc,'right') && numel(bc.right) > 0% && syssize == 1 % as above for rhs
    if isa(bc.right,'function_handle')
        bc.right = struct( 'op', bc.right, 'val', 0);
    elseif isa(bc.right,'linop')
        bc.right = struct( 'op', bc.right, 'val', 0);
    elseif iscell(bc.right)
        bc.right = struct( 'op', bc.right);
    end
    for k = 1:numel(bc.right)
        opk = bc.right(k).op;
        if isnumeric(opk) && syssize == 1
            bc.right(k).op = eye(d);
            bc.right(k).val = opk;
        end
        if isa(opk,'function_handle')
            nlrbc = [nlrbc k];
            if     nargin(opk) == 2,  nlbcs = [nlbcs {@(u,t,x) opk(u,@Diff)} ];
            elseif nargin(opk) == 4,  nlbcs = [nlbcs {@(u,t,x) opk(u,t,x,@Diff)} ]; 
            end
            bc.right(k).op = repmat(eye(d),1,syssize);
        end
        if isfield(bc.right(k),'val') && ~isempty(bc.right(k).val)
                rhs{numlbc+k} = bc.right(k).val;
        else    rhs{numlbc+k} = 0; end
        bc.right(k).val = 0;
    end          
elseif isfield(bc,'left') 
    bc.right = [];
end

% Support for user-defined mass matrices - experimental!
if ~isempty(opt.Mass) && isnumeric(opt.Mass)
    usermass = true;
    userM = opt.Mass;
else
    usermass = false; 
end

% This is needed inside the nested function onestep()
diffop = diff(d,order);
if syssize > 1
    diffop = repmat(diffop,syssize,syssize);
end

% simplify initial condition  to tolerance
u0 = simplify(u0,tol);

% The vertical scale of the intial condition
vscl = u0.scl;

% Plotting setup
if doplot
    cla, shg, set(gcf,'doublebuf','on')
    plot(u0,'.-'), drawnow,
    if dohold, ish = ishold; hold on, end
end

% initial condition
ucur = u0;
if syssize == 1
    uu = repmat(chebfun(0,d),1,length(t));
    uu(:,1) = ucur;
else
    uu = cell(length(t),1);
    uu{1} = ucur;
end

% initialise variables for onestep()
B = []; q = []; rows = []; M = []; n = [];

% Begin time chunks
for nt = 1:length(t)-1
    
    % size of current length
    curlen = 0;
    for k = 1:syssize, curlen = max(curlen,length(ucur(:,k))); end
    
    % solve one chunk
    chebfun( @(x) vscl+onestep(x), d, 'eps', tol, 'minsamples',curlen, ...
        'resampling','on','splitting','off','sampletest','off','blowup','off') - vscl;  

    % get chebfun of solution from this time chunk
    for k = 1:syssize, ucur(:,k) = chebfun(unew(:,k),d); end
    
    % store in uu
    if syssize == 1,  uu(:,nt) = ucur;
    else              uu{nt+1} = ucur;
    end
    
    % plotting
    if doplot
        cla, plot(ucur,'.-')
        title(sprintf('t = %.3f,  len = %i',t(nt+1),curlen)), drawnow
    end
end

if dohold && ~ish, hold off, end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    ONESTEP   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constructs the result of one time chunk at fixed discretization
    function U = onestep(y)
        global x

        if length(y) == 2, U = [0;0]; return, end
        
        % set the global variable x
        x = y;
        
        % Evaluate the chebfun at discrete points
        U0 = feval(ucur,y);

        % This depends only on the size of n. If this is the same, reuse
        if isempty(n) || n ~= length(y)
            n = length(y);
            % See what the boundary replacement actions will be.
            [ignored,B,q,rows] = feval( diffop & bc, n, 'bc' );
            % Mass matrix is I except for algebraic rows for the BCs.
            M = speye(syssize*n);    M(rows,:) = 0;
        
            % Multiply by user-defined mass matrix
            if usermass, M = userM*M; end
            
        end
        
        % ODE options (mass matrix)
        opt = odeset(opt,'mass',M,'masssing','yes','initialslope',odefun(t(nt),U0));

        % Solve ODE over time chunk with ode15s
        [ignored,U] = ode15s(@odefun,t(nt:nt+1),U0,opt);
        
        % Reshape solution
        U = reshape(U(end,:).',n,syssize);
        
        % The solution we'll take out and store
        unew = U;
        
        % Collapse systems to single chebfun for constructor (is addition right?)
        U = sum(U,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    ODEFUN   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This is what ode15s calls.
        function F = odefun(t,U)
            % Reshape to n by syssize
            U = reshape(U,n,syssize);
            
            % Evaluate the PDEFUN
            F = pdefun(U,t,x);
            
            % Get the algebraic righthandsides (may be time-dependent)
            for l = 1:numel(rhs)
                if isa(rhs{l},'function_handle')
                    q(l,1) = feval(rhs{l},t);
                else
                    q(l,1) = rhs{l};
                end
            end

            % replacements for the BC algebraic conditions           
            F(rows) = B*U(:)-q; 
            
            % replacements for the nonlinear BC conditions
            j = 0;
            for kk = 1:length(nllbc)
                j = j + 1;
                tmp = feval(nlbcs{j},U,t,x);
                F(rows(kk)) = tmp(1)-q(kk);
            end
            for kk = numel(rhs)+1-nlrbc
                j = j + 1;
                tmp = feval(nlbcs{j},U,t,x);
                F(rows(kk)) = tmp(end)-q(kk);
            end
            
            % Reshape to single column
            F = F(:);

        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   DIFF   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% The differential operators
function up = Diff(u,k)
    % Computes the k-th derivative of u using Chebyshev differentiation
    % matrices defined by barymat. The matrices are stored for speed.
    
    global x order
    persistent storage
    if isempty(storage), storage = struct([]); end

    % Assume first-order derivative
    if nargin == 1, k = 1; end
    
    % For finding the order of the RHS
    if any(isnan(u)) 
        if isempty(order), order = k;
        else order = max(order,k); end
        up = [];
        return
    end
    
    N = length(u);
    
    % Retrieve or compute matrix.
    if N > 5 && length(storage) >= N && numel(storage(N).D) >= k && ~isempty(storage(N).D{k})
        % Matrix is already in storage
    else
        % Which differentiation matrices do we need?
        switch order
            case 1
                storage(N).D{1} = barymat(x);
            case 2
                [storage(N).D{1} storage(N).D{2}] = barymat(x);
            case 3
                [storage(N).D{1} storage(N).D{2} storage(N).D{3}] = barymat(x);
            case 4
                [storage(N).D{1} storage(N).D{2} storage(N).D{3} storage(N).D{4}] = barymat(x);
            otherwise
                error('CHEBFUN:Diff:order','Diff can only produce matrices upto 4th order');
        end

    end

    % Find the derivative by muliplying by the kth-order differentiation matrix
    up = storage(N).D{k}*u;
end       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    BARMAT   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D1 D2 D3 D4] = barymat(x,w)
% BARYMAT  Barycentric differentiation matrix with arbitrary weights/nodes.
%  D = BARYMAT(X,W) creates the first-order differentiation matrix with
%       nodes X and weights W.
%  D = BARYMAT(X) assumes Chebyshev weights.
%  [D1 D2 D3 D4] = BARYMAT(X,W) returns differentiation matrices of upto
%  order 4.
%  All inputs should be column vectors.
%  See http://www.maths.ox.ac.uk/chebfun for chebfun information.
%
%  Taken from T. W. Tee's Thesis.

N = length(x)-1;
if N == 0
    N = x;
    x = chebpts(N);
end

if nargin < 2           % Default to Chebyshev weights
    w = [.5 ; ones(N,1)]; 
    w(2:2:end) = -1;
    w(end) = .5*w(end);
end

if nargout > 4
    error('chebfun:barymat:nargout',['barymat only supports differentiation ', ...
        'matrices upto and including order 4']);
end

ii = (1:N+2:(N+1)^2)';
Dw = repmat(w',N+1,1) ./ repmat(w,1,N+1) - eye(N+1);
Dx = repmat(x ,1,N+1) - repmat(x',N+1,1) + eye(N+1);

D1 = Dw ./ Dx;
D1(ii) = 0; D1(ii) = - sum(D1,2);
if (nargout == 1), return; end
D2 = 2*D1 .* (repmat(D1(ii),1,N+1) - 1./Dx);
D2(ii) = 0; D2(ii) = - sum(D2,2);
if (nargout == 2), return; end
D3 = 3./Dx .* (Dw.*repmat(D2(ii),1,N+1) - D2);
D3(ii) = 0; D3(ii) = - sum(D3,2);
if (nargout == 3), return; end
D4 = 4./Dx .* (Dw.*repmat(D3(ii),1,N+1) - D3);
D4(ii) = 0; D4(ii) = - sum(D4,2);
end

