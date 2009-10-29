function g = cumsum(g)
% CUMSUM	Indefinite integral
% CUMSUM(G) is the indefinite integral of the fun G.
% If the fun G of length n is represented as
%
%       SUM_{r=0}^{n-1} c_r T_r(x)
%
% its integral is represented with a fun of length n+1 given by
%
%       SUM_{r=0}^{n} C_r T_r (x)
% 
% where C_0 is determined from the constant of integration as
% 
%       C_0 = SUM_{r=1}^{n} (-1)^(r+1) C_r;
%
% C_1 = c_0 - c_2/2, and for r > 0,
%
%       C_r = (c_{r-1} - c_{r+1})/(2r),
%
% with c_{n+1} = c_{n+2} = 0.
%
% See "Chebyshev Polynomials" by Mason and Handscomb, CRC 2002, pg 32-33.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team. 
% Last commit: $Author$: $Rev$:
% $Date$:

% linear map (simplest case)
if strcmp(g.map.name,'linear')
    
    if isempty(g), return, end
    
    if ~any(g.exps)  
        g.vals = g.vals*g.map.der(0); % From change of variables to [-1,1]
        g = cumsum_unit_interval(g);
    elseif any(g.exps<=-1)
        error('chebfun:fun:cumsum','cumsum does not yet support exponents <= 1');
    else
        g = jacsum(g);
    end
        
    
% Infinite intervals    
elseif norm(g.map.par(1:2),inf) == inf
    
    % constant case
    if g.n == 1
        if abs(g.vals) <= chebfunpref('eps')*10*g.scl.v
            g.vals = 0; g.n = 1; g.scl.v = 0;
        else
            warning('fun:cumsum','Integral seems to diverge')
            g.vals = nan; g.n = 1; g.scl.v = inf;
        end
        return
    end

    % non-constant case
    g = cumsum_unit_interval(changevar(g));
    
% General map case    
else
    
    map = g.map; g.map = linear([-1 1]);
    g = cumsum_unit_interval(g.*fun(map.der,g.map));
    g.map = map;
   
end

end

function g = cumsum_unit_interval(g)

    n = g.n;
    c = [0;0;chebpoly(g)];                        % obtain Cheb coeffs {c_r}
    cout = zeros(n-1,1);                          % initialize vector {C_r}
    cout(1:n-1) = (c(3:end-1)-c(1:end-3))./...    % compute C_(n+1) ... C_2
        (2*(n:-1:2)');
    cout(n,1) = c(end) - c(end-2)/2;              % compute C_1
    cout(n+1,1) = (-1).^(n+1:-1:2)*cout;          % compute C_0
    g.vals = chebpolyval(cout);
    g.scl.v = max(g.scl.v, norm(g.vals,inf));
    g.n = n+1;
    
end

function f = jacsum(f)
if f.map.par(1:2) ~= [-1 1]
    error('CHEBFUN:fun:cumsum',['Cumsum cannot deal with functions which have ',...
    'endpoint singularities on intervals other than [-1,1] yet']);
end

% for testing - delete this eventually
h = f; h.exps = [0 0];

% Get the exponents
exps = f.exps;
a = exps(2); b = exps(1);

% Compute Jacobi coefficients of F
j = jacpoly(chebfun(f),a,b).';

% Integrate the nonconstant terms exactly to get new coefficients
k = (length(j)-1:-1:1).';
jhat = -.5*j(1:end-1)./k;

% Convert back to Chebyshev series
c = jac2cheb2(a+1,b+1,jhat);

% Construct fun
f.vals = chebpolyval(c);
f.exps = f.exps + 1;
f.scl.v = max(f.scl.v, norm(f.vals,inf));

% Deal with the constant part
if exps(2)
    G = j(end)*2^(a+b+1)*beta(b+1,a+1)*chebfun(@(x) betainc(.5*(x+1),b+1,a+1),'map',{'sing',0},'exps',{exps(1) exps(2)},'splitting','off');
else
    G = fun(j(end)/(1+exps(1)),[-1,1]);
    G.scl.h = 2; G.scl.v = G.vals; 
    G.n = 1; G.exps = [exps(1)+1 0];
end

% For testing when the righthand exponent is nonzero
if exps(2)
    figure
    F = chebfun(f);
    plot(F,'-b'); hold on
    xx = linspace(-1,1,1000);
    plot(G,'--b')
    plot(xx,F(xx)+feval(G,xx),'k','linewidth',2)

    % % testing for others within interval
    h = @(x) feval(h,x);
    ff = chebfun(@(x) h(x).*((1-x).^a.*(x+1).^b),[-.9,.9]);
    gg = cumsum(ff)+feval(F,ff.ends(1))+feval(G,ff.ends(1));
    xx = linspace(ff.ends(1),ff.ends(2),100000);
    plot(xx,gg(xx),'--r')

    xx = linspace(-ff.ends(1),ff.ends(2),1000);
    norm(F(xx)+feval(G,xx)-gg(xx),inf)
    legend('F','G','F+G','''true''')

    figure
    subplot(2,1,1)
    plot(G)
    legend('G')
    subplot(2,1,2)
    chebpolyplot(chebfun(G))
    legend('chebpolyploy(G)')
    A = get(gcf,'position'); 
    A(1) = A(1)+.6*A(3); 
    set(gcf,'position',A)
    A(1) = A(1)-1.2*A(3);
    set(1,'position',A)
end

if ~exps(2)
    fexps = f.exps; f.exps = [0 0];
    pref.exps = {0 0}; pref.n = 2;
    if all(f.vals==0), f.vals = 0; F.n = 0; end
    f = f.*fun(@(x) 1-x,[-1,1],pref); 
    f.exps(1) = fexps(1);
    f = f + G;
end

end

function cheb = jac2cheb2(a,b,jac)
N = length(jac)-1;

if ~N, cheb = jac; return, end

% Chebyshev-Gauss-Lobatto nodes
x = chebpts(N+1);

apb = a + b;

% Jacobi Vandermonde Matrix
P = zeros(N+1,N+1);
P(:,1) = 1;    
P(:,2) = 0.5*(2*(a+1)+(apb+2)*(x-1));    
for k = 2:N
    k2 = 2*k;
    k2apb = k2+apb;
    q1 =  k2*(k + apb)*(k2apb - 2);
    q2 = (k2apb - 1)*(a*a - b*b);
    q3 = (k2apb - 2)*(k2apb - 1)*k2apb;
    q4 =  2*(k + a - 1)*(k + b - 1)*k2apb;
    P(:,k+1) = ( (q2+q3*x).*P(:,k) - q4*P(:,k-1) ) / q1;
end

f = fun;
f.vals = P*flipud(jac(:)); f.n = length(f.vals);
cheb = chebpoly(f);

end
