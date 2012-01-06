function pass = intops
% Test integral operators
% 
% Toby Driscoll 28 May 2009
% Nick Hale 6 Jan 2012

tol = chebfunpref('eps');

tic
% Fredholm
[d,x] = domain(0,1); 
F = fred(@(x,y) sin(2*pi*(x-y)),d);
A = eye(d)+F;
u = x.*exp(x);
f = A*u;
pass(1) = norm(u-A\f) < 1e6*tol;

% Volterra
[d,x] = domain(0,pi);
V = volt( @(x,y) x.*y, d );
f = x.^2.*cos(x) + (1-x).*sin(x);
u = (1-V)\f;
pass(2) = norm( u - sin(x) ) < 1e6*tol;
pass(3) = norm( (1-V)*u - f ) < 1e4*tol;
toc

%% Now available as chebops!
tic
% Fredholm
[d,x] = domain(0,1); 
K = @(x,y) sin(2*pi*(x-y));
A = chebop(@(u) u + fred(K,u), d);
u = x.*exp(x);
f = A*u;
pass(4) = norm(u-A\f) < 1e6*tol;

% Volterra
[d,x] = domain(0,pi);
K = @(x,y) x.*y;
A = chebop(@(u) u - volt(K,u), d);
f = x.^2.*cos(x) + (1-x).*sin(x);
u = A\f;

pass(5) = norm( u - sin(x) ) < 1e6*tol;
pass(6) = norm( A*u - f ) < 1e4*tol;
toc
