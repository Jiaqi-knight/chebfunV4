%% CHEBFUN GUIDE 4: CHEBFUNS AND APPROXIMATION THEORY
% Lloyd N. Trefethen, December 2007

%% 4.1  Chebyshev series and interpolants
% The chebfun system is founded on the mathematical
% subject of approximation theory, and in particular, on 
% Chebyshev series and interpolants.  
% Conversely, it provides a simple environment in
% which to demonstrate these approximants.

%%
% The history of "Chebyshev technology" goes back to
% the 19th century Russian mathematician P. L. Chebyshev (1821-1894)
% and his mathematical descendants such as Zolotarev, Achieser, and
% Bernstein (1880-1968).  These men realized that
% just as Fourier series provide an efficient way to represent
% a smooth periodic function, series of Chebyshev polynomials can
% do the same for a smooth nonperiodic function.  A number
% of excellent textbooks and monographs have been published on approximation
% theory, including [Davis 1963], [Cheney 1966], [Meinardus 1967], and [Lorentz 1986],
% and in addition there are books devoted entirely to Chebyshev polynomials:
% [Rivlin 1974] and [Mason & Handscomb 2003].

%%
% From these dates of publication it will be clear that
% approximation theory flourished in the early computer era, and
% in the 1950s and 1960s a number of numerical methods were developed based
% on Chebyshev polynomials by Lanczos [Lanczos 1957], Fox [Fox & Parker 1966],
% Clenshaw, Elliott, Mason, Good, and others.  The Fast Fourier Transform
% came in 1965 and Salzer's barycentric interpolation formula for
% Chebyshev points in 1972 [Salzer 1972].  Then in the 1970s Orszag
% and Gottlieb introduced spectral methods, based on the
% application of Chebyshev and Fourier technology to the solution of
% PDEs.  The subject grew rapidly, and it is in the context of spectral
% methods that Chebyshev techniques are best known today
% [Boyd 2000], ]Trefethen 2000], [Canuto et al. 2006/7].

%%
% We must be clear about terminology.  We shall rarely use the
% term *Chebyshev approximation*, for that expression refers specifically to
% an approximation that is optimal in the minimax sense.
% Chebyshev approximations are fascinating, but 
% the chebfun system is built on the different techniques of polynomial
% interpolation in Chebyshev points and expansion in Chebyshev
% polynomials.  These approximations are not quite optimal, but
% they are nearly optimal and much easier to compute.

%%
% By *Chebyshev points* we shall mean the set of points in
% [-1,1] defined by
%
%         x(j) = cos(j pi/N),    0 <= j <= N,
%
% where N is an integer >= 1.  (If N=0, we take x(0)=1.)
% Through any data values f(j) at these points there is a unique
% polynomial interpolant p(x) of degree <= N, which we call
% the *Chebyshev interpolant*.
% In particular, if the data are f(j) = (-1)^j, then p(x) is
% T_N, the Nth Chebyshev polynomial, which can also be defined
% by the formula T_N(x) = cos(N acos(x)).  In the chebfun system,
% the command "chebpoly(N)" returns a chebfun corresponding to T_N, and
% "poly" returns coefficients in the monomial basis 1,x,x^2,....
% Thus we can print the coefficients of the first few Chebyshev
% polynomials like this:

  for N = 0:8
    disp(poly(chebpoly(N)))
  end

%%
% Note that that output of "poly" follows the pattern for Matlab's standard "poly"
% command: it is a row vector, and the high-order coefficients come first.
% Thus, for example, the fourth row above tells us the T_3(x) = 4x^3 - 3x.

%%
% Here are plots of T_2, T_3, T_15, and T_50:

  subplot(2,2,1), plot(chebpoly(2))
  subplot(2,2,2), plot(chebpoly(3))
  subplot(2,2,3), plot(chebpoly(15))
  subplot(2,2,4), plot(chebpoly(50))

%%
% A *Chebyshev series* is an expansion
%
%     f(x) = SUM'_{k=0}^infty a_k T_k(x),
%
% and the a_k are known as *Chebyshev coefficients*.  
% The notation SUM' indicates that the term with k=0 is
% to be multiplied by 1/2.  So long
% as f is continuous and at least a little bit smooth (Lipschitz
% continuity is enough), it has a unique expansion of
% this form, which converges absolutely and
% uniformly, and the coefficients are given by the integral
%
%     a_k = (2/pi) INT_{-1}^1 f(x) T_k(x) dx / sqrt(1-x^2).
%
% One way to approximate a function is to form 
% the polynomials obtained by truncating its Chebyshev expansion,
%
%     f_N(x) = SUM'_{k=0}^N a_k T_k(x).

%%
% This isn't quite what the chebfun system does, however, since it
% does not compute exact Chebyshev coefficients.   Instead chebfuns are based
% on Chebyshev interpolants, which can also be regarded as
% finite series in Chebyshev polynomials for some coefficients c_k:
%
%     p_N(x) = SUM'_{k=0}^N c_k T_k(x).
%
% Each coefficient c_k will converge to a_k as N->infty (apart from the
% effects of rounding errors), but for finite N, c_k and a_k are different.
% The system actually stores a function by its values at the Chebyshev
% points rather than its Chebyshev coefficients, but this hardly matters
% to the user, and both representations are exploited for various
% purposes internally in the system.

%% 4.2 chebpoly and poly
%
% Throughout this section of the guide, we set

splitting off
%%
% since our purpose is to explore global Chebyshev interpolants
% without any division into subintervals.

%%
% We have just seen that the command chebpoly(N) returns a chebfun
% corresponding to the Chebyshev polynomial T_N.  Conversely, if f is a 
% chebfun, then chebpoly(f) is the vector of its Chebyshev coefficients.
% For example, here are the Chebyshev coefficients of x^3:

x = chebfun('x');
c = chebpoly(x.^3)

%%
% Like "poly", "chebpoly" returns a row vector with the high-order coefficients first.
% Thus this computation reveals the identity x^3 = (1/4)*T_3(x) + (3/4)*T_1(x).

%%
% If we apply chebpoly to a function that is not
% "really" a polynomial, we will usually get a vector whose first
% entry (i.e., highest order) is just above machine precision.
% This reflects the adaptive nature of the chebfun
% constructor, which always seeks to use a minimal number of points.

chebpoly(sin(x))

%%
% Of course, machine precision is defined relative to the scale of
% the function:

chebpoly(1e100*sin(x))

%%
% By using "poly" we can print the coefficients of such a chebfun
% in the monomial basis.  Here for example are the coefficients
% of the Chebyshev interpolant of exp(x) compared with the
% Taylor series coefficients:

cchebfun = flipud(poly(exp(x))');
ctaylor = 1./gamma(1:length(cchebfun))';
disp('        chebfun              Taylor')
disp([cchebfun ctaylor])

%%
% The fact that these differ is not an indication of an
% error in the chebfun approximation.  On the contrary, the chebfun
% coefficients do a better job of approximating than the truncated
% Taylor series.  If f were a function like 1/(1+25x^2), the
% Taylor series would not converge at all.

%% 4.3 chebfun(...,N) and the Gibbs phenomenon

%%
% We can examine the approximation qualities of Chebyshev interpolants
% by means of a command of the form "chebfun(...,N)".  When an integer
% N is specified in this manner, it indicates that a Chebyshev interpolant
% is to be constructed of precisely length N rather than by the usual
% adaptive process.

%%
% Let us begin with a function that cannot be well approximated
% by polynomials, the step function sign(x).  To start with we
% interpolate it in 9 or 19 points, taking N to be odd
% to avoid including a value 0 at the middle of the step.

f = chebfun('sign(x)',9);
subplot(1,2,1), plot(f,'.-'), grid on
f = chebfun('sign(x)',19);
subplot(1,2,2), plot(f,'.-'), grid on

%%
% There is an overshoot problem here, known as the Gibbs phenomenon,
% that does not go away as N -> infty.
% We can zoom in on the overshoot region by resetting the axes:

subplot(1,2,1), axis([0 .4 .5 1.5])
subplot(1,2,2), axis([0 .2 .5 1.5])

%%
% Here are analogous results with N=99 and 999.

f = chebfun('sign(x)',99);
subplot(1,2,1), plot(f,'.-'), grid on, axis([0 .04 .5 1.5])
f = chebfun('sign(x)',999);
subplot(1,2,2), plot(f,'.-'), grid on, axis([0 .004 .5 1.5])

%%
% The second plot is jagged, not because there is anything wrong with
% the underlying chebfun but because we have zoomed in very closely on the result
% of a "plot" command.  One way to get it right is as follows:

clf
subplot(1,2,2), plot(f,'.'), grid on, axis([0 .004 .5 1.5])
hold on, ff = chebfun(@(x) f(x),[0 .004]); plot(ff)

%%
% What is the amplitude of the Gibbs overshoot for Chebyshev
% interpolation of a step function?  We can find out by using "max":

for N = 2.^(1:8)-1
  gibbs = max(chebfun('sign(x)',N));
  fprintf('%5d  %13.8f\n', N, gibbs)
end

%%
% This gets a bit slow for larger N, but knowing that the maximum occurs
% around x = 3/N, we can speed it up by repeating the scaling trick above.

for N = 2.^(4:12)-1
  f = chebfun('sign(x)',N);
  ff = chebfun(@(x) f(x),[0 5/N]);
  fprintf('%5d  %13.8f\n', N, max(ff))
end

%%
% Evidently the overshoot converges to a number approximately 1.2822834.
% The exact limit is presumably known, but I haven't yet found a reference.

%% 4.4 Smoothness and rate of convergence
% The most basic principle in approximation theory is this:
% the smoother the function, the faster the convergence as N -> infty.
% What this means for the chebfun system is that so long
% as a function is twice continuously differentiable, it can usually
% be approximated to machine precision for a workable value of N, even
% without subdivision of the interval.

%%
% After the step function, a function with "one more derivative" of smoothness
% would be the absolute value.  Here if we interpolate in N points, the
% errors decrease at the rate O(N^(-1)).  For example:

clf
f10 = chebfun('abs(x)',10);
subplot(1,2,1), plot(f10,'.-'), grid on
f20 = chebfun('abs(x)',20);
subplot(1,2,2), plot(f20,'.-'), grid on

%%
% The chebfun system has no difficulty computing interpolants of much higher order:

f100 = chebfun('abs(x)',100);
subplot(1,2,1), plot(f100), grid on
f1000 = chebfun('abs(x)',1000);
subplot(1,2,2), plot(f1000), grid on

%%
% Such plots look good to the eye, but they do not achieve machine precision.
% We can confirm this by setting "splitting on" for a moment
% to compute a true absolute value and then measuring some norms.

splitting on, fexact = chebfun('abs(x)'); splitting off
err10 = norm(f10-fexact,inf)
err100 = norm(f100-fexact,inf)
err1000 = norm(f100-fexact,inf)

%%
% Notice the clean linear decrease of the error as N increases.

%%
% If f is a bit smoother, polynomial approximations to machine precision
% become practical:

  length(chebfun('abs(x).*x'))
  length(chebfun('abs(x).*x.^2'))
  length(chebfun('abs(x).*x.^3'))
  length(chebfun('abs(x).*x.^4'))

%%
% Of course, these particular functions are easily
% approximated by piecewise smooth chebfuns.

%%
% It is interesting to plot convergence as a function of N.  Here
% is an example from [Battles & Trefethen 2004] involving the
% next function from the sequence above.

s = 'abs(x).^5';
exact = chebfun(s);
NN = 1:100; e = [];
for N = NN
  e(N) = norm(chebfun(s,N)-exact);
end
clf
subplot(1,2,1)
loglog(e), ylim([1e-10 10])
hold  on, loglog(NN,NN.^(-5),'--r'), grid on
text(6,4e-7,'N^{-5}','color','r','fontsize',16)
subplot(1,2,2)
semilogy(e), ylim([1e-10 10]), grid on

%%
% The figure reveals very clean convergence at the rate
% N^(-5).  According to Theorem 2 to the next section, this
% happens because f has a fifth derivative of
% bounded variation.

%%
% Here is an example of a smoother function, one that is in
% fact analytic.  According to Theorem 3 of the next section, if
% f is analytic, its Chebyshev interpolants converge geometrically.
% In this example we take f to be the Runge function, for which
% interpolants in equally spaced points would not converge at all
% (in fact they would diverge exponentially).

%%
s = '1./(1+25*x.^2)';
exact = chebfun(s);
for N = NN
  e(N) = norm(chebfun(s,N)-exact);
end
clf, subplot(1,2,1)
loglog(e), ylim([1e-10 10]), grid on
subplot(1,2,2)
semilogy(e), ylim([1e-10 10])
c = 1/5 + sqrt(1+1/25);
hold  on, semilogy(NN,c.^(-NN),'--r'), grid on
text(45,1e-3,'C^{-N}','color','r','fontsize',16)

%%
% This time the convergence is equally clean but quite different in
% nature.  Now the straight line appears on the semilogy axes rather
% than the loglog axes, revealing the geometric convergence. 

%% 4.5 Five theorems
%
% The mathematics of the chebfun system can be captured in five
% theorems about interpolants in Chebyshev points.  The first three
% can be found in [Battles & Trefethen 2004], and all will be
% discussed in [Trefethen 2008].  Let f be a
% continuous function on [-1,1], and let p denote its interpolant
% in N Chebyshev points and p* its best degree N approximation with
% respect to the maximum norm *||* *||*.

%%
% The first theorem asserts that Chebyshev interpolants are "near-best"
% [Ehlich & Zeller 1966].

%%
% *THEOREM 1.*  *||* f - p *||* <= (2 + (2/pi)log(N)) *||* f - p* *||*.

%%
% This theorem implies that even if N is as large as 100,000, one can lose
% no more than one digit by using p instead of p*.  Whereas the chebfun system
% will readily compute such a p, it is unlikely that anybody has ever computed
% a nontrivial p* for a value of N so large.

%%
% The next theorem asserts that if f is k times differentiable, roughly
% speaking, then the Chebyshev interpolants converge at the algebraic rate
% 1/N^k [Mastroianni & Szabados 1995].

%%
% *THEOREM 2*.  If Let f, f', ..., f^(k-1) be absolutely continuous for some
% k >=1, and let f^(k) be a function of bounded variation.  Then
% *||* f - p *||* = O(N^(-k)) as N -> infty.

%%
% Smoother than this would be a C-infty function, i.e. infinitely differentiable,
% and smoother still would be a function analytic on [-1,1], i.e.,
% one whose Taylor series at each point of [-1,1] converges at least in a small
% neighborhood of that point.  In such a case the convergence is geometric.
% The essence of the following theorem is due to Bernstein in 1912, though
% I do not know where an explicit statement first appeared in print.

%%
% *THEOREM 3*.  If f is analytic in the closed ellipse of foci 1 and -1 with
% semimajor axis M and semiminor axis m, then
% *||* f - p *||* = O((M+m)^(-N)) as N -> infty.

%%
% The next theorem asserts that Chebyshev interpolants can be computed
% by the barycentric formula [Salzer 1972].  The notation SUM" denotes a
% sum from k=0 to k=N, with both terms k=0 and k=N multiplied by 1/2.

%%
% *THEOREM 4*.  p(x) = SUM" (-1)^k f(x_k)/(x-x_k) / SUM" (-1)^k/(x-x_k).

%%
% See [Berrut & Trefethen 2005] for general information
% about barycentric interpolation.

%%
% The final theorem asserts that the barycentric formula has no difficulty with
% rounding errors.  Our "theorem" is really just a placeholder; see
% [Higham 2004] for a precise statement and proof.

%%
% *THEOREM 5*.  The barycentric formula of Theorem 4 is numerically stable.

%%
% In finishing this chapter we should restore the chebfun system to its usual state:

  splitting on


%% 4.6  References
% 
% [Battles & Trefethen 2004] Z. Battles and L. N. Trefethen,
% "An extension of Matlab to continuous functions and
% operators", SIAM Journal on Scientific Computing 25 (2004),
% 1743-1770.
%
% [Berrut & Trefethen 2005] J.-P. Berrut and L. N. Trefethen,
% "Barycentric Lagrange interpolation", SIAM Review 46 (2004),
% 501-517.
%
% [Boyd 2000] J. P. Boyd, Chebyshev and Fourier Spectral Methods,
% 2nd ed., Dover, 2000.
%
% [Canuto et al. 2006/7] C. Canuto, M. Y. Hussaini, A. Quarteroni
% and T. A. Zang, Spectral Methods, 2 vols., Springer, 2006 and 2007.
%
% [Cheney 1966] E. W. Cheney, Introduction to Approximation
% Theory, McGraw-Hill 1966 and AMS/Chelsea, 1999.
%
% [Davis 1963] P. J. Davis, Interpolation and Approximation,
% Blasdell, 1963 and Dover, 1975.
%
% [Ehlich & Zeller 1966] H Ehlich and K. Zeller, "Auswertung der
% Normen von Interpolationsoperatoren," Math. Annalen 164 (1966), 105-112.
%
% [Fox & Parker 1966] L. Fox and I. B. Parker,
% Chebyshev Polynomials in Numerical Analysis, Oxford U. Press, 1968.
%
% [Higham 2004] N. J. Higham, "The numerical stability
% of barycentric Lagrange interpolation", IMA Journal of
% Numerical Analysis 24 (2004), 547-556.
%
% [Lanczos 1956] C. Lanczos, Applied Analysis, Prentice-Hall,
% 1956 and Dover, 1988.
%
% [Lorentz 1986] G. G. Lorentz, The Approximation of Functions,
% American Mathematical Society, 1986.
%
% [Mason & Handscomb 2003] J. C. Mason and D. C. Handscomb,
% Chebyshev Polynomials, CRC Press, 2003.
%
% [Mastroianni & Szabados 1995] G. Mastroianni and J. Szabados,
% "Jackson order of approximation by Lagrange interpolation,"
% Acta. Math. Hungar. 69 (1995), 73-82.
%
% [Meinardus 1967] G. Meinardus, Approximation of Functions:
% Theory and Numerical Methods, Springer, 1967.
%
% [Rivlin 1974] T. J. Rivlin, The Chebyshev Polynomials, Wiley, 1974 and 1990.
%
% [Salzer 1972] H. E. Salzer, "Lagrangian interpolation at the 
% Chebyshev points cos(nu pi/n), nu = 0(1)n; some unnoted
% advantages", Computer Journal 15 (1972),156-159.
%
% [Trefethen 2000] L. N. Trefethen, Spectral Methods in Matlab,  SIAM, 2000.
%
% [Trefethen 2008] L. N. Trefethen, Neoclassical Numerics, book
% in preparation.

