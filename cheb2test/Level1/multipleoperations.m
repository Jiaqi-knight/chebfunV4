function pass = multipleoperations

tol = chebfun2pref('eps'); j=1; 

f = chebfun2(@(x,y) sin(10*x.*y),[-1 2 -1 1]);

pass(j) = (norm(f+f+f+f+f+f+f-7*f) < 100*tol); j=j+1; 
pass(j) = (norm(f.*f-f.^2) < 100*tol); j=j+1; 
% pass(j) = (norm(f.*f.*f-f.^3) < 100*tol); j=j+1; 
% pass(j) = (norm(f.*f.*f.*f.*f-f.^5) < 100*tol); j=j+1;


f = chebfun2(@(x,y) sin(10*x.*y)+2,[-1 2 -1 1]);
pass(j) = (norm(sqrt(f.^2)-f) < 100*tol); j=j+1; 

f = chebfun2(@(x,y) sin(10*x.*y),[-1 2 -1 1]);



if all(pass) 
    pass=1; 
else
    pass=0;
end

end