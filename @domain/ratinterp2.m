
function [p,q,r,mu,nu,poles,residues] = ratinterp( d , f , m , n , NN , xi_type , tol )
% RATINTERP computes a robust rational interpolation or approximation.
%
%   [P,Q,R_HANDLE] = RATINTERP(F,M,N) computes the (M,N) rational interpolant
%   of F on the M+N+1 Chebyshev points of the second kind. F can be a Chebfun,
%   a function handle or a vector of M+N+1 data points. If F is a Chebfun, the
%   rational interpolant is constructed on the domain of F. Otherwise, the
%   domain [-1,1] is used. P and Q are Chebfuns such that P(x)./Q(x) = F(x).
%   R_HANDLE is an anonymous function evaluating the rational interpolant
%   directly.
%
%   [P,Q,R_HANDLE] = RATINTERP(F,M,N,NN) computes a (M,N) rational linear
%   least-squares approximant of F over the NN Chebyshev points of the second
%   kind. If NN=M+N+1 or NN=[], a rational interpolant is computed.
%
%   [P,Q,R_HANDLE] = RATINTERP(F,M,N,NN,XI) computes a (M,N) rational
%   interpolant or approximant of F over the NN nodes XI. XI can also be one
%   of the strings 'type1', 'type2', 'unitroots' or 'equidistant', in which
%   case NN of the respective nodes are created on the interval [-1,1].
%
%   [P,Q,R_HANDLE,MU,NU] = RATINTERP(F,M,N,NN,XI,TOL) computes a robustified
%   (M,N) rational interpolant or approximant of F over the NN+1 nodes XI, in
%   which components contributing less than the relative tolerance TOL to
%   the solution are discarded. If no value of TOL is specified, a tolerance of
%   1e-14 is assumed. MU and NU are the resulting numerator and denominator
%   degrees. Note that if the degree is decreased, a rational approximation is
%   computed over the NN points. The coefficients are computed relative to the
%   orthogonal base derived from the nodes XI.
%
%   [P,Q,R_HANDLE,MU,NU,POLES,RES] = RATINTERP(F,M,N,NN,XI,TOL) returns the
%   poles POLES of the rational interpolant on the real axis as well as the
%   residues RES at those points. If any of the nodes XI lie in the complex
%   plane, the complex poles are returned as well.
%
%   [P,Q,R_HANDLE] = RATINTERP(D,F,M,N) computes the (M,N) rational interpolant
%   of F on the M+N+1 Chebyshev points of the second kind on the domain D.
%
%   See also CHEBFUN/RATINTERP, CHEBFUN/INTERP1, DOMAIN/INTERP1.

%   Based on P. Gonnet,  R. Pachon, and L. N. Trefethen, "ROBUST RATIONAL
%   INTERPOLATION AND LEAST-SQUARES", Electronic Transations on Numerical
%   Analysis (ETNA), 38:146-167, 2011,
%
%   and R. Pachon, P. Gonnet and J. van Deun, "FAST AND STABLE RATIONAL
%   INTERPOLATION IN ROOTS OF UNITY AND CHEBYSHEV POINTS", Submitted to
%   SIAM Journal on Numerical Analysis, 2011.

%   Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%   See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    % Check the inputs
    if nargin < 5 || isempty(NN)
        if nargin > 6 && ~isempty(xi_type) && ~isstr(xi_type)
            N = length( xi_type ) - 1;
        elseif isfloat( f )
            N = length( f ) - 1;
        else
            N = m + n;
        end
    else
        N = NN - 1;
        if N < m + n
            error( 'CHEBFUN:ratinterp:N' , 'The input argument NN should be at least M+N+1.' )
        end
    end
    if nargin < 6 || isempty( xi_type )
        xi_type = 'type2';
        xi = chebpts( N+1 , 2 );
    elseif ~isstr(xi_type)
        if length(xi_type) ~= N+1
            error( 'CHEBFUN:ratinterp:InputLengthX' , 'The input vector xi is of the wrong length' );
        end
        xi = xi_type;
        xi_type = 'arbitrary';
    else
        if strcmpi( xi_type , 'TYPE2' )
            xi = chebpts( N+1 , 2 );
        elseif strcmpi( xi_type , 'TYPE1' )
            xi = chebpts( N+1 , 1 );
        elseif strcmpi( xi_type , 'UNITROOTS' ) || strcmpi( xi_type , 'TYPE0' )
            xi_type = 'type0';
            xi = exp( 2i * pi * (0:N)' / (N+1) );
        elseif strncmpi( xi_type , 'EQUI' , 4 )
            xi = linspace( -1 , 1 , N+1 )';
        else
            error( 'CHEBFUN:ratinterp:XiType' , 'Unrecognized type of nodes XI.' );
        end
    end
    if nargin < 7, tol = 1.0e-14; end
    d = d.ends;
    if isa( f , 'chebfun' ) && ~(domain(f) == domain(d))
        f = f{d(1),d(2)};
    end
    if ~isfloat(f)
        f = f( 0.5*sum(d) + 0.5*diff(d)*xi );
    elseif length(f) ~= N+1
        error( 'CHEBFUN:ratinterp:InputLengthF' , 'The input vector f is of the wrong length' );
    end
    
    % Init some values that we will use often
    ts = tol * norm( f , inf );
    N1 = N + 1;
    
    % Check for odd or even f
    evenf = false; oddf = false;
    if strncmpi( xi_type , 'type' , 4 )
        if xi_type(5) == '0'
            if mod(N,2) == 1
                M = floor(N/2);
                fl = f( 2:M+1 ); fr = f( N+2-M:end );
                evenf = norm( fl - fr , inf ) < ts;
                oddf = norm( fl + fr , inf ) < ts;
            end
        else
            M = ceil(N/2);
            fl = f( 1:M ); fr = f( end:-1:N1-M+1 );
            evenf = norm( fl - fr , inf ) < ts;
            oddf = norm( fl + fr , inf ) < ts;
        end
    else
        M = floor(N/2);
        [ xs , ind ] = sort( xi );
        xl = xs( 1:M+1 ); xr = xs( end:-1:N1-M );
        if norm( xl + xr , inf ) < ts
            xi = xs; f = f( ind );
            M = ceil(N/2);
            fl = f( 1:M ); fr = f( end:-1:N1-M+1 );
            evenf = norm( fl - fr , inf ) < ts;
            oddf = norm( fl + fr , inf ) < ts;
        end
    end
    shift = xor(evenf,mod(m,2)==1);

    % Assemble the matrices Z and C
    if strncmpi( xi_type , 'type' , 4 )
        if xi_type(5) == '0'
            row = conj( fft( conj( f ) ) ) / N1;
            col = fft( f ) / N1; col(1) = row(1);
            Z = toeplitz( col , row(1:n+1) );
        elseif xi_type(5) == '1'
            D = dct1( diag( f' ) )';
            Z = dct1( D( : , 1:n+1 ) );
        else
            D = idct2( eye(N1) );
            Z = dct2( diag( f ) * D( : , 1:n+1 ) );
        end
    else
        C = ones( N1 ); C(:,2) = xi;
        for k=3:N1, C(:,k) = 2 * xi .* C(:,k-1) - C(:,k-2); end;
        [ C , R ] = qr( C );
        Z = C.' * diag( f ) * C( : , 1:n+1 );
    end

    % Main loop
    if n > 0 && ( ~( oddf || evenf ) || n > 1 )
        while true

            % Compute the SVD of the lower part of Z
            if ~oddf && ~evenf
                [ U , S , V ] = svd( Z( m+2:N1 , 1:n+1 ) , 0 );
                ns = n;
                b = V(:,end);
            else
                [U,S,V] = svd( Z( m+2+shift:2:N1 , 1:2:n+1 ) , 0 );
                ns = floor(n/2);
                b = zeros( n+1 , 1 );
                b(1:2:end) = V(:,end);
            end

            % Get the smallest singular value
            ssv = S(ns,ns);

            % Converged?x = chebfun('x');
            if ssv > ts
                break;

            % Chop off excess singular values
            else

                % Reduce n
                s = diag( S( 1:ns , 1:ns ) );
                n = n - sum( s-ssv <= ts );

                % Any denominator left?
                if n == 0
                    b = 1;
                    break;
                end

            end;

        end % Main loop
    
    % If n=0, so be it.    
    else
        b = 1;
    end
    
    % Get the coefficients a
    a = Z( 1:m+1 , 1:n+1 ) * b;
    if evenf
        a( 2:2:end ) = 0;
    elseif oddf
        a( 1:2:end ) = 0;
    end 

    % Trim coefficients a and b
    if tol > 0
        nna = abs(a)>ts; nnb = abs(b)>tol;           % nonnegligible a and b coeffs
        a = a(1:find(nna,1,'last'));                 % discard trailing zeros of a
        b = b(1:find(nnb,1,'last'));                 % discard trailing zeros of b
        while ( length(a) > 0 && length(b) > 0 && abs(a(1)) < ts && abs(b(1)) < ts )
            a = a(2:end); b = b(2:end);
        end;
    end;
    if length(a)==0 a=0; b=1; end                % special case of zero function
    mu = length(a)-1; nu = length(b)-1;          % exact numer, denom degrees

    % Assemble the anonymous function for r
    md = 0.5 * sum(d); hd = 0.5 * diff(d);
    if strncmpi( xi_type , 'type' , 4 )
        if xi_type(5) == '0'
            % For speed, compute px and qx using Horner's scheme and convert
            % to a chebfun.
            px = a(end) * ones( mu+1 , 1 ); x = chebpts( mu+1 );
            for k=mu:-1:1, px = a(k) + x .* px; end;
            p = chebfun( px , d );
            qx = b(end) * ones( nu+1 , 1 ); x = chebpts( nu+1 );
            for k=nu:-1:1, qx = b(k) + x .* qx; end;
            q = chebfun( qx , d );
            r = @(x) polyval( a(mu+1:-1:1) , hd*(x-md) ) ./ polyval( b(nu+1:-1:1) , hd*(x-md) );
        elseif xi_type(5) == '1'
            w = (-1).^(0:N)' .* sin((2*(0:N)+1)*pi/(2*N1))';
            px = idct1( [ a ; zeros( N-mu , 1 ) ] );
            qx = idct1( [ b ; zeros( N-nu , 1 ) ] );
            p = chebfun( idct1( a ) , d , 'chebkind' , 1 );
            q = chebfun( idct1( b ) , d , 'chebkind' , 1 );
            r = @(x) bary( hd*(x-md) , px./qx , xi , qx.*w );
        else
            w = (-1).^(0:N)'; w(1) = 0.5; w(end) = w(end)/2;
            p = chebfun( a(end:-1:1) , 'coeffs' , d );
            q = chebfun( b(end:-1:1) , 'coeffs' , d );
            px = idct2( [ a ; zeros( N-mu , 1 ) ] );
            qx = idct2( [ b ; zeros( N-nu , 1 ) ] );
            r = @(x) bary( hd*(x-md) , px./qx , xi , qx.*w );
        end
    else
        % Compute the basis C at the mu+1 and nu+1 Chebyshev points and
        % convert to a chebfun.
        Cf = ones(mu+1); Cf(:,2) = chebpts( mu+1 );
        for k=3:mu+1, Cf(:,k) = 2 * Cf(:,2) .* Cf(:,k-1) - Cf(:,k-2); end;
        Cf = Cf / R( 1:mu+1 , 1:mu+1 );
        p = chebfun( Cf(:,1:mu+1) * a , d );
        Cf = ones(nu+1); Cf(:,2) = chebpts( nu+1 );
        for k=3:nu+1, Cf(:,k) = 2 * Cf(:,2) .* Cf(:,k-1) - Cf(:,k-2); end;
        Cf = Cf / R( 1:nu+1 , 1:nu+1 );
        q = chebfun( Cf(:,1:nu+1) * b , d );
        r = @(x) p(x) ./ q(x);
    end

    % Does the user want the poles?
    if nargout > 5

        % get the roots of the denominator
        poles = roots( q , 'complex' );

        % Residues too?
        if nargout > 6
            residues = p( poles );
        end

    end
    
end

% Compact implementation of the barycentric interpolation formula
function y = bary ( x , fx , xi , w )
    y = zeros(size(x)); fxw = fx(:).*w(:);
    for i=1:length(x),
        dxinv = 1.0 ./ ( x(i) - xi(:) ); ind = find( ~isfinite(dxinv) );
        if length(ind)>0, y(i)=fx(ind);
        else, y(i)=(fxw.'* dxinv)/(w(:).'* dxinv); end
    end
end

% Compact implementation of the DCT for Chebyshev points of the first kind.
function y = dct1(x)
    n = size(x,1);
    w = (exp(-1i*(0:n-1)*pi/(2*n))/sqrt(2*n)).'; w(1) = w(1)/sqrt(2);
    if mod(n,2) == 1 || ~isreal(x),
    y = fft([x;x(n:-1:1,:)]); y = diag(w)*y(1:n,:);
    else y = fft([x(1:2:n,:); x(n:-2:2,:)]); y = diag(2*w)*y; end;
    if isreal(x), y = real(y); end
end

% Compact implementation of the iDCT for Chebyshev points of the first kind.
function x = idct1(y)
    n = size(y,1); w = (exp(1i*(0:n-1)*pi/(2*n)) * sqrt(2*n)).';
    if mod(n,2) == 1 || ~isreal(y), w(1) = w(1)*sqrt(2);
    x = ifft([diag(w)*y;zeros(1,size(y,2));-1i*diag(w(2:n))*y(n:-1:2,:)]);
    x = x(1:n,:); else w(1) = w(1)/sqrt(2);
    x([1:2:n,n:-2:2],:) = ifft(diag(w)*y); end;
    if isreal(y), x = real(x); end;
end

% Compact implementation of the DCT for Chebyshev points of the second kind.
function c = dct2( v )
    n = size( v , 1 );
    % v([1,end],:) = v([1,end],:) * 2;
    c = [ v(end:-1:2,:) ; v(1:end-1,:) ];
    if isreal(v)
        c = fft(c)/(2*n-2);
        c = real(c);
    elseif isreal(1i*v)
        c = fft(imag(c))/(2*n-2);
        c = 1i*real(c);
    else
        c = fft(c)/(2*n-2);
    end
    c = c(n:-1:1,:);
    if (n > 2), c(2:end-1,:) = 2*c(2:end-1,:); end
    c = c(end:-1:1,:);
end

% Compact implementation of the iDCT for Chebyshev points of the second kind.
function v = idct2( c )
    n = size( c , 1 );
    ii = 2:n-1;
    c = c(end:-1:1,:);
    c(ii,:) = c(ii,:)/2;
    v = [c(end:-1:1,:); c(ii,:)];
    if isreal(c)
        v=real(ifft(v));
    elseif isreal(1i*c)
        v=1i*real(ifft(imag(v)));
    else
        v=ifft(v);
    end
    v = (n-1)*[2*v(1,:); (v(ii,:)+v(2*n-ii,:)); 2*v(n,:)];
    v = v(end:-1:1,:);
end

