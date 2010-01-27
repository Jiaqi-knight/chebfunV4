function pass = jacptstest

tol = chebfunpref('eps');

a = 1; 
b = 5; 
alpha = .3; 
beta = -.4;

f = @(x)sin(x);
F = @(x)(x-a).^beta.*(b-x).^alpha.*f(x);

warnstate = warning; warning off
vquadgk = quadgk(F,a,b,'abstol',1e-10,'reltol',1e-10);
warning(warnstate);

njac=20; c1=(b+a)/2; c2=(b-a)/2;

[s,w] = jacpts(njac,alpha,beta);
v1jac = c2^(alpha+beta+1)*w*f(c1+c2*s);

[S,W] = jacpts(njac,alpha,beta,[a,b]);
v2jac = W*f(S);

% Check the scaling of the points
pass(1) = ~norm(v1jac-v2jac,inf);

% Check the accuracy of the quadrature against quadgk
pass(2) = abs(vquadgk-v2jac) < max(10*tol,1e-8);

% Check accuracy of sum
pass(3) = abs( sum(chebfun(F,[a b],'exps',[beta alpha])) - v2jac) < 100*tol;