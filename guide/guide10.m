%% CHEBFUN GUIDE 10: NONLINEAR ODES AND AUTOMATIC DIFFERENTIATION
% Lloyd N. Trefethen, November 2009

%%
% Chapter 7 described the "chebop" capability for solving
% linear ODEs (ordinary differential equations) by a backslash command.
% The chebfun system also offers several options for nonlinear ODEs:
%
%   Initial-value problems:  ODE45, ODE113, ODE15S
%
%   Boundary-value problems: BVP4C, BVP5C
%
%   Both kinds of problems:  nonlinear backslash ( = SOLVEBVP)
%
% In this chapter we outline the use of
% these methods; for fuller details, see the "help"
% documentation.  The last of the methods listed, nonlinear backslash
% and SOLVEBVP, is an experimental "pure chebfun" approach in which Newton's method
% is applied on chebfuns, with the necessary derivative operators calculated
% by chebfun's built-in capabilities of Automatic Differentiation (AD).

%%
% We use the abbreviations IVP for initial-value
% problem and BVP for boundary-value problem, as well as BC for
% boundary condition.

%%
% For time-dependent PDEs, try PDE15S.

%% 10.1 ODE45, ODE15S, ODE113
% Matlab has a highly successful suite of
% ODE IVP solvers introduced originally by Shampine
% and Reichelt [Shampine & Reichelt 1997].
% The codes are called ODE23, ODE45, ODE113,
% ODE15S, ODE23S, ODE23T, and ODE23TB, and are adapted to various
% mixes of accuracy requirements and stiffness.

%%
% Chebfun contains overloads of ODE45 (for medium
% accuracy), ODE113 (for high accuracy), and ODE15S (for stiff problems)
% created by Toby Driscoll and Rodrigo Platte.
% These codes operate by calling their
% Matlab counterparts, then converting the result to a chebfun.
% Thanks to the chebfun framework of dealing with functions,
% their use is very natural and simple.

%%
% For example, here is a solution of u' = u^2 over [0,1] with
% initial condition u(0) = 0.9. 
fun = @(t,u) u.^2;  
u = ode45(fun,domain(0,1),0.9);
LW = 'linewidth'; lw = 2;
plot(u,LW,lw)

%%
% The first argument to ODE45 defines the equation, the second
% defines the domain for the independent variable, and the third
% provides the initial condition.  The second argument takes the
% form of a chebfun domain as described in Chapter 7, and it is
% the presence of this object that directs Matlab to use the chebfun
% overload of ODE45 rather than the Matlab original. 

%%
% To find out where the solution takes the value 4, for
% example, we can write
roots(u-4)

%%
% As a second example let us consider
% the linear second-order equation u"=-u, whose solutions are
% sines and cosines.  We convert this to 
% first-order form by using a vector v with v(1)=u
% and v(2)=u', and solve the problem again using ode45:
fun = @(t,v) [v(2); -v(1)];
v = ode45(fun,domain(0,10*pi),[1 0]);
plot(v,LW,lw)

%%
% Here are the minimum and maximum values attained by u:
u = v(:,1); uprime = v(:,2);
minandmax(u)

%%
% Evidently the accuracy is only 
% around five digits.  The reason is that the chebfun ODE45 code uses the
% same default tolerances as the original ODE45.  
% We can tighten the tolerance using the standard Matlab
% ODESET command, switching also to ODE113 since it is more
% efficient for high-accuracy computations:
opts = odeset('abstol',3e-14,'reltol',3e-14);
v = ode113(fun,domain(0,10*pi),[1 0],opts);
minandmax(v(:,1))

%%
% As a third example we solve the van der Pol equation
% for a nonlinear oscillator.  Following the example
% in Matlab's ODE documentation, we take u" = 1000(1-u^2)u'-u
% with initial conditions u=2, u'=0.  This is a highly stiff
% problem whose solution contains very rapid transitions,
% so we use ode15s with splitting on:
opts = odeset('abstol',1e-8,'reltol',1e-8);
fun = @(t,v) [v(2); 1000*(1-v(1)^2)*v(2)-v(1)];
splitting on
v = ode15s(fun,domain(0,3000),[2 0],opts);
splitting off
u = v(:,1); plot(u,LW,lw)

%%
% Here is a pretty good estimate of the period of
% the oscillator:
diff(roots(u))

%%
% Finally here is an illustration of the Lorenz equations:
fun = @(t,u) [10*(u(2)-u(1)); 28*u(1)-u(2)-u(1)*u(3); u(1)*u(2)-(8/3)*u(3)];
u = ode15s(fun,domain(0,30),[-5 -7 21],opts);
plot3(u(:,1),u(:,2),u(:,3)), view(-5,9)
axis([-30 30 -50 50 5 45])
xlabel x, ylabel y, zlabel z

%% 10.2 BVP4C, BVP5C
% Matlab also has well-established codes BVP4C and BVP5C for solving BVPs,
% and these too have been overloaded in the chebfun system.
% Again the chebfun usage becomes somewhat simpler than the
% original.  In particular, there is no need to call BVPINIT;
% the initial guess and associated mesh are both determined by
% an input initial guess u0. 

%%
% For example, here is the problem labeled "twoode" in the Matlab
% BVP4C documentation.  The domain is [0,4], the
% equation is u'' + abs(u) = 0, and the boundary conditions are
% u(0)=0, u(4)=-2.  We get one solution from the initial condition u=1:

twoode = @(x,v) [v(2); -abs(v(1))];
twobc = @(va,vb) [va(1); vb(1)+2];
[d,x] = domain(0,4);
one = chebfun(1,d);
v0 = [one 0*one];
v = bvp4c(twoode,twobc,v0);
u = v(:,1); plot(u,LW,lw)

%%
% The initial guess u=-1 gives another valid solution:
v0 = [-one 0*one];
v = bvp4c(twoode,twobc,v0);
u = v(:,1); plot(u,LW,lw)

%%
% Here is an example with a variable coefficient, a problem due to George
% Carrier described in Sec. 9.7 of the book by Bender and
% Orszag [Bender & Orzsag 1978].  On [-1,1], we seek a function u satisfying
%
%   ep u" + 2(1-x^2)u + u^2 = 1 ,  u(-1) = u(1) = 0.
%
% with ep=0.01.  Here is a solution with BVP5C, just one of many
% solutions of this problem.
ep = 0.01;
ode = @(x,v) [v(2); (1-v(1)^2-2*(1-x^2)*v(1))/ep];
bc = @(va,vb) [va(1); vb(1)];
[d,x] = domain(-1,1);
one = chebfun(1,d);
v0 = [0*one 0*one];
v = bvp5c(ode,bc,v0);
u = v(:,1); plot(u,LW,lw)

%% 10.3 Automatic Differentiation
% The options described in the last two sections rely on
% standard numerical discretizations, whose results are then converted
% to chebfun form.  It is natural, however, to want to be able to try solving
% ODEs fully within the chebfun context, operating always at the level
% of functions.  If the ODE is nonlinear, this will lead to Newton
% iterations for functions, also known as Newton-Kantorovich
% iterations.  As with any Newton method, this will require a 
% derivative, which in this case becomes a linear
% operator: an infinite-dimensional Jacobian, or more properly a
% Frechet derivative.

%%
% The chebfun system contains experimental codes for making such
% explorations possible.  So far, at least, what we offer probably does not compete
% in speed and robustness with BVP4C/BVP5C.  Even so, it offers the
% entirely new possibility of enabling one to explore iterations at the function level.
% The crucial tool for making all this possible is the chebfun
% capability for Automatic Differentiation (AD) introduced in
% 2009 by Toby Driscoll and Asgeir Birkisson.

%%
% To illustrate chebfun AD, consider the sequence of computations
[d,x] = domain(0,1);
u = x.^2;
v = exp(x) + u.^3;
w = u + diff(v);
%%
% Suppose we ask, how does one of these variables 
% depend on another one earlier in the sequence?  If the function
% u is perturbed by an infinitesimal function du, for example, what
% will the effect be on v? 

%%
% As mathematicians we can answer this question as follows.
% The variation takes the form dv/du = 3u^2 = 3x^4.  In other
% words, dv/du is the linear operator that multiplies a function on [0,1]
% by 3x^4.  In chebfun, we can compute this operator automatically by
% typing diff with two arguments:
dvdu = diff(v,u)

%%
% The result dvdu is a chebop, just as described in Chapter 7.

%%
% For example, dvdu*x is 3x^4 times x, or 3x^5:
plot(dvdu*x,LW,lw)

%%
% Notice that dvdu is a "diagonal operator", acting on a
% function just by pointwise multiplication.  (The proper term
% is "multiplier operator".  You can
% extract the chebfun corresponding to its diagonal part with
% the command f=diag(dvdu).)  This will not be
% true of dw/dv, however.  If w = u+diff(v), then w+dw = u+diff(v+dv),
% so dw/dv must be the differentiation operator with respect to the
% variable x:
dwdv = diff(w,v)

%%
% We can verify for example that dwdv*x is 1:
plot(dwdv*x,LW,lw)

%%
% What about dw/du?  Here we must think a little more carefully and compute
%
%   dw/du = (partial w/partial u) + (partial w/partial v)*(partial v/partial u)
%
%         = I + D*3u^2  =  I + D*3x^4 ,
%
% where I is the identity operator and D is the differentiation operator with
% respect to x.  If we apply dw/du to x, for example, the result will be 
% x + (3x^5)' = x + 15x^4.  The following computation confirms that chebfun
% reaches this result automatically.
dwdu = diff(w,u);
norm(dwdu*x - (x+15*x.^4))

%%
% All these AD calculations are built into chebfun's diff(f,g) command,
% making available in principle the linear operator representing the 
% Jacobian (Frechet derivative) of any chebfun with respect to any other
% chebfun.  The details of this implementation contain some features that
% may be new to the AD field, and will be described in a future publication by 
% Birkisson and Driscoll.  We now look at how AD enables chebfun users to
% solve nonlinear ODE problems using an overloaded backslash.

%% 10.4 Nonlinear backslash and SOLVEBVP
% In Chapter 7, we realized linear operators as chebops constructed
% by commands like these:
%
[d,x] = domain(-1,1);
L = 0.0001*diff(d,2) + diag(x);

%%
% We could then solve a BVP:
L.lbc = 0;
L.rbc = 1;
u = L\0; plot(u,'m',LW,lw)
%%
% What's going on in such a calculation is that L is a prescription for
% constructing matrices of arbitrary dimensions which are spectral
% approximations to the operator in question.  When backslash is
% executed, the problem is solved on successively finer grids until
% convergence is achieved.

%%
% Chebfun can also solve problems specified by nonlinear operators, which
% may also have nonlinear boundary conditions.  Now instead of using
% diff and diag and eye we specify the problem by anonymous functions:
[d,x,N] = domain(-1,1);
N.op = @(u) 0.0001*diff(u,2) + x.*u;
N.lbc = @(u) u;
N.rbc = @(u) u-1;
u = N\0; plot(u,'m',LW,lw)

%%
% (More simply we could also have written N.lbc=0 and N.rbc=1.)
% The object N we have created is called a nonlinop.
% Here are its pieces (subject to change as the code is further
% developed in the future):
struct(N)

%%
% We have a domain, three anonymous functions defining the differential
% operator and the boundary conditions, and a fifth field for an initial
% guess in the form of a chebfun.  If this is not specified then
% the initial guess is taken as the zero function.

%%
% The example just given is linear, but the point is that we can
% also handle nonlinear problems.  To do this, the chebfun system uses
% a Newton iteration starting at the given initial guess.  Each step of
% the iteration requires the solution of a linear problem specified by a
% Jacobian operator (Frechet derivative) evaluated at the current estimated
% solution.  This is provided by the AD facility, and the linear problem
% is then solved by chebops.

%%
% Let us reconsider some of the examples of the last two sections.  First in
% Section 10.1 we had the nonlinear IVP u' = u^2, u(0)=0.9.  This can
% be solved in nonlinop formulation like this:
[d,x,N] = domain(0,1);
N.op = @(u) diff(u)-u.^2;  
N.lbc = @(u) u-0.9;
u = N\0;                 
plot(u,'m',LW,lw)

%%
% Next came the linear equation u"=-u.  With nonlinops, there is
% no need to reformulate the problem as a first-order system.  There
% are two boundary conditions at the left, which can be imposed
% by making N.lbc a cell array.
[d,t,N] = domain(0,10*pi);
N.op = @(u) diff(u,2)+u;
N.lbc = {@(u) u-1, @(u) diff(u) };
u = N\0;
plot(u,'m',diff(u),'c',LW,lw)

%%
% The van der Pol problem of Section 10.1 cannot be solved by
% nonlinops; the stiffness quickly causes failure of the Newton
% iteration.

%%
% Now we come to the BVPs of Section 10.2.
% First came the "twoode" problem u"+abs(u)=0, u(0)=0, u(4)=-2.  
% If we start from the initial guess u=1 as before, there is
% no convergence; nonlinop currently uses a pure Newton iteration,
% which is more fragile than the methods of BVP4C/BVP5C.
% On the other hand we converge to a solution if we start
% from the guess u(x)=-x/2:
[d,x,N] = domain(0,4);
N.op = @(u) diff(u,2)+abs(u);
N.lbc = @(u) u;
N.rbc = @(u) u+2;
N.guess = -x/2;
u = N\0;
plot(u,'m',LW,lw)

%%
% Finally here again is the Carrier problem of section 10.2:
ep = 0.01;
[d,x,N] = domain(-1,1);
N.op = @(u) ep*diff(u,2) + 2*(1-x.^2).*u + u.^2;
N.bc = 'dirichlet';
N.guess = 2*(x.^2-1).*(1-2./(1+20*x.^2));
u = N\1; plot(u,'m',LW,lw)

%%
% We get a different solution from the one we got before!
% This one is correct too; the Carrier problem has many solutions. 
% We can verify its validity like this:
norm(N(u)-1)

%%
% If we multiply this solution by
% sin(x) and take the result as a new initial guess,
% we converge to another new solution:
N.guess = u.*sin(x);
u = N\1; plot(u,'m',LW,lw)

%%
% If we negate this solution we converge to the solution found by BVP5C.
N.guess = -u;
[u,nrmdu] = N\1; plot(u,'m',LW,lw)

%%
% This time, we executed the backslash command with
% two output arguments.  The second
% contains data showing the norms of the updates during the Newton iteration,
% revealing in this case a troublesome initial phase followed by eventual
% rapid convergence.
semilogy(nrmdu,'.-k',LW,lw), ylim([1e-14,1e2])

%%
% Another way to get information about the Newton iteration with
% nonlinop backlash is by setting
nonlinoppref('plotting',1)

%%
% Type help nonlinoppref for details.  Here we shall not pursue this
% option and thus return the system to its factory state:
nonlinoppref('plotting',0)

%%
% Notice that if N is a nonlinop and u is a chebfun on the same domain,
% we can write N(u) to get the chebfun corresponding to N's action on u.
% In developing the nonlinop class we
% could have overloaded N*u also, giving it the same meaning as
% N(u), but it seemed wiser to keep with the familiar usage of L*u
% for a linear operator and N(u) for a nonlinear one.  

%%
% The heading of this section refers to the command SOLVEBVP.
% When you apply backslash to a nonlinop, it invokes the overloaded
% Matlab command mldivide; this in turn calls a command
% SOLVEBVP to do the actual work.
% By calling SOLVEBVP directly, you can control the
% computation in ways not accessible
% through backslash.
% This situation is just like the relationship
% in standard Matlab between \ and LINSOLVE.
% See the help documentation for details.

%% 10.5 References
%
% [Bender & Orszag 1978] C. M. Bender and S. A. Orszag,
% Advanced Mathematical Methods for Scientists and Engineers,
% McGraw-Hill, 1978.
%
% [Shampine & Reichelt 1997] L. F. Shampine and M. W. Reichelt,
% "The Matlab ODE suite", SIAM Journal on Scientific Computing
% 18 (1997), 1-12.
