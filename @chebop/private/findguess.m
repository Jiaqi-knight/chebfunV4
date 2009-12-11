function guess = findguess(N)
% FINDGUESS Constructs initial guess for the solution of BVPs
%
% FINDGUESS starts with a quasimatrix with one column (the zero chebfun),
% then adds another column with the zero function to the quasimatrix until
% it's able to apply the operator to the quasimatrix (which means that the
% quasimatrix is then of the correct size).

guess = [];
dom = N.dom;
success = 0;
counter = 0;


while ~success && counter < 10
    % Need to create new chebfun at each step in order to have the
    % correct ID of the chebfun
    cheb0 = chebfun(0,dom);
    guess = [guess cheb0];
    % Check whether we are successful in applying the operator to the
    % function.
    try
        feval(N.op,guess);
        success = 1;
        counter = counter+1;
    catch % Should do some more accurate error catching
        counter = counter+1;
    end
end

if counter == 10
    error(['Chebop:solve:findguess: Initial guess seems to have 10 or more ' ...
        'columns in the quasimatrix. If this is really the case, set the ' ...
        'initial guess using N.guess.']);
end
% Once we have found the correct dimensions of the initial guess, try to
% find a linear function that fulfills (potentially) the Dirichlet BC
% imposed.
% Check whether a boundary happens to have no BC attached

% Extract BC functions
bcFunLeft = N.lbc;
bcFunRight = N.rbc;

if counter == 1 && ~any(strcmpi(bcFunLeft,'periodic')) && ~any(strcmpi(bcFunRight,'periodic'))
    guess = tryInterpGuess();
elseif xor(strcmpi(bcFunLeft,'periodic'),strcmpi(bcFunRight,'periodic'))
    error('Nonlinop:mldivide:findguess: BC is periodic at one end but not at the other.');
end

    function intGuess = tryInterpGuess()
        % For some type of problems (nonperiodic problems where the
        % solution is a single chebfun rather then quasimatrix) we can try
        % to construct an initial guess such that it fullfills
        % (potentially) non-homogenous Dirichlet BCs.

        leftEmpty = isempty(bcFunLeft);
        rightEmpty = isempty(bcFunRight);
        
        if ~iscell(bcFunLeft), bcFunLeft = {bcFunLeft}; end
        if ~iscell(bcFunRight), bcFunRight = {bcFunRight}; end
        
        
        
        % Store information about the endpoints of the domain
        ab = dom.ends;
        a = ab(1);  b = ab(end);
        
        
        % Get values of BCs at the endpoints
        leftVals = zeros(length(bcFunLeft),1);
        rightVals = zeros(length(bcFunRight),1);
        if leftEmpty
            leftVals = 0;
        else
            for j = 1:length(bcFunLeft)
                v = feval(bcFunLeft{j},guess);
                leftVals(j) = v(a);
            end
        end
        
        if rightEmpty
            rightVals = 0;
        else
            for j = 1:length(bcFunRight)
                v = feval(bcFunRight{j},(guess));
                rightVals(j) = v(b);
            end
        end
        % If we just have one column in our guess, perform a linear interpolation
        leftY = leftVals(min(find(leftVals ~= 0)));
        rightY = rightVals(min(find(rightVals ~= 0)));
        
        if isempty(leftY)
            leftY = 0;
        end
        if isempty(rightY)
            rightY = 0;
        end
        
        intGuess = chebfun(-[leftY rightY],dom);
    end

end