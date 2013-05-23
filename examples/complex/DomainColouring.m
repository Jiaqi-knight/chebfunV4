%% Phase Portrait Plots
% Alex Townsend, March 2013

%%
% (Chebfun2 example ComplexAnalysis/phasePortraitPlots.m)
% [Tag: #complex, #plotting]

%% Phase portrait plots for complex functions 
% Phase portrait plotting is a technique for visualising complex valued functions 
% of a single complex variable. It relies on the visual encoding of complex
% numbers: if z=r*exp(1i*t) then the rainbow colours represents the
% argument of z. Red indicates an argument of 0 and the rainbow goes 
% through red, yellow, green, blue, violet as the argument increases. For 
% example 

FS = 'FontSize'; fs=16; d = pi*[-1 1 -1 1];
f = chebfun2(@(z) sin(z),d); 
plot(f), title('Phase portrait for sin(z)',FS,fs);

%% One complex variable, two real variables
% A complex valued function $f(z)$ of one complex variable can be thought
% of as a complex valued function of two variables. This is what is going
% on in the example above. 

%% Uniqueness
% If two complex valued functions $f(z)$ and $g(z)$ have the same phase 
% portrait plot then there is a real constant c such that 
% $f(z) = cg(z)$.  Therefore, one can tell a huge amount about a function 
% $f(z)$ just by considering its domain colouring plot [1]. 

%% Some more pretty plots
% We find these plots addictive to draw. Here are our two favourites:

f = chebfun2(@(z) cos(z.^2), d);
plot(f), title('cos(z^2)',FS,fs)

%%
g = chebfun2(@(z) sum(z.^(0:9)),d./2,'vectorise');
plot(g), title('Nearly the ten roots of unity',FS,fs)

%% And one more... just for fun
f = chebfun2(@(z) sin(z)-sinh(z),2*d);
plot(f), title('Phase portrait plot for sin(z)-sinh(z)',FS,fs)

%% References 
% [1] E. Wegert, Visual Complex Functions: An Introduction with Phase
% Portraits, Springer Basel, 2012. 