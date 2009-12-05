function pass = normtests

% Nick Trefethen  22 March 2009
tol = 100*chebfunpref('eps');
x = chebfun('x');
absx = abs(x);
pass1 = (norm(absx,1)==1);
pass9 = norm(2^(-500)*x)==2^(-500)*norm(x);

dabsx = diff(abs(x));
pass2 = (norm(dabsx,1)==2);
pass3 = (norm(dabsx,inf)==1);
pass4 = (norm(-dabsx,inf)==1);

ddabsx = diff(dabsx);
pass5 = (norm(ddabsx,1)==2);
pass6 = (norm(-ddabsx,1)==2);
pass7 = (norm(ddabsx,inf)==inf);
pass8 = (norm(-ddabsx,inf)==inf);
pass10 = (abs(norm([1 x])-sqrt(8/3)) < tol);
pass11 = (abs(norm([1 x],2)-sqrt(2)) < tol);
pass = pass1 && pass2 && pass3 && pass4 && pass5 && pass6 && pass7 && pass8 && pass9 && pass10 && pass11;
