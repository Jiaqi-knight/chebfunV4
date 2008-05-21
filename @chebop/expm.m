function E = expm(A)
% EXPM   Exponential of chebop.
% E = EXPM(A) returns a chebop representing the exponential operator
% generated by A. The chebop A should have boundary conditions appropriate
% for its definition, or else usage of E may be nonconvergent or
% unexpected. 
%
% Note that operations on chebops clear out boundary conditions, so you
% must reassign them before calling EXPM. Homogeneous (zero) boundary
% values are used, even if they are specified otherwise.
%
% EXAMPLE: Heat equation
% d = domain(-1,1);  x = chebfun('x',d);
% D = diff(d);  A = D^2;  bc = 'dirichlet';
% f = exp(-20*(x+0.3).^2);
% clf, plot(f,'r'), hold on, c = [0.8 0 0];
% for t = [0.001 0.01 0.1 0.5 1]
%    E = expm(t*A & bc);
%    plot(E*f,'color',c),  c = 0.5*c;
%  end
%
% See also CHEBOP/AND, CHEBOP/SUBSASGN.

% Copyright 2008 by Toby Driscoll.

% Check for warnings.
[L,c,rowrep] = feval(A,10);
if any(c~=0)
  warning('chebop:expm:boundarydata',...
    'Ignoring nonzero boundary data--setting to zero.')
end
if A.numbc~=A.difforder
  warning('chebop:expm:bc',...
    'Operator may not have the right number of boundary conditions.')
end

E = chebop( @evalexp, [], domain(A), 0);

  function E = evalexp(n)
    % Function may be called with n=2. Punt.
    if A.numbc==n
      E = eye(n);
      return
    end
    [L,c,rowrep] = feval(A,n);
    elim = false(n,1);  elim(rowrep) = true;
    % Use algebra with the BCs to remove degrees of freedom.
    R = -L(elim,elim)\L(elim,~elim);  % maps interior to removed values
    L = L(~elim,~elim) + L(~elim,elim)*R;  % reduced to interior DOF

    E1 = expm(L);

    % Return to full-size operator.
    E = zeros(n);
    E(~elim,~elim) = E1;
    E(elim,~elim) = R*E1;
  end

end