function pass = scribbles
% scribblestest.m - uses "scribble" to test various things
%    related to piecewise defined complex chebfuns
%    Nick Trefethen November 2009

f = scribble('rex');
pass(1) = (norm(f)==norm(f'));
pass(2) = max(imag(f))==-min(imag(f'));
pass(3) = norm(f,inf)==norm([f;f],inf);