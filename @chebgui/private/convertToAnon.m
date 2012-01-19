function varargout = convertToAnon(guifile,str)
% CONVERTTOANON Converts a string on 'natural syntax form' to an anonymous
% function Matlab can work with.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% In Matlab2007a and previous versions, the code runs into error if we
% don't clear the functions cache before running the code. Contacting
% technical support at Mathworks, they told me that this bug has been fixed
% for versions 2007b and onwards.
if verLessThan('matlab','7.5')
    clear functions
end

% Put the original string through the lexer
[lexOut varNames pdeVarNames eigVarNames indVarNames] = lexer(guifile,str);

% Make sure we have enough variables!
if isempty(varNames)
    if numel(indVarNames) > 1 && ~isempty(indVarNames{2})
        str = sprintf('Variables ''%s'' and ''%s'' ', indVarNames{1:2});
    else
        str = sprintf('Variable ''%s'' ', indVarNames{1});
    end
    error('Chebgui:chebgui:depvars',...
        ['No dependent variables detected. ' str 'treated as independent.']);
end 
% Check whether we have something like u" = u_t+v_t which we don't allow
if length(pdeVarNames) > 1
    error('Chebgui:convertToAnon:pdeVariables',...
        'Only one time derivative per line is allowed');
end
% Parse the output from the lexer, looking for syntax errors.
syntaxTree = parse(guifile,lexOut);


if strcmp(guifile.type,'bvp')
    % Convert a potential = at the top of the tree to a -.
    syntaxTree = splitTree_bvp(guifile,syntaxTree);
    % Obtain the prefix form.
    prefixOut = tree2prefix(guifile,syntaxTree);
elseif strcmp(guifile.type,'pde')
    % Convert a potential = at the top of the tree to a -.
    [syntaxTree pdeSign] = splitTree_pde(guifile,syntaxTree);
    % Obtain the prefix form.
    prefixOut = tree2prefix(guifile,syntaxTree);
    % pdeSign tells us whether we need to flip the signs. Add a unitary -
    % at the beginning of the expression
    if pdeSign == 1
        prefixOut = [{'-', 'UN-'}; prefixOut];
    end
elseif strcmp(guifile.type,'eig')
    anFunLambda = '';
    % Convert a potential at the top of the tree = to a -.
    [syntaxTree lambdaTree lambdaSign] = splitTree_eig(guifile,syntaxTree);
    % Obtain the prefix form.
    prefixOut = tree2prefix(guifile,syntaxTree);
    
    % If lambdaTree is not empty, we convert that tree to prefix-form as
    % well
    if ~isempty(lambdaTree)
        prefixOutLambda = tree2prefix(guifile,lambdaTree);
        
        % If the lambda part is on the LHS, we need to add a - in front of
        % the prefix expression.
        if lambdaSign == -1
            prefixOutLambda = [{'-', 'UN-'}; prefixOutLambda];
        end
        
        % If we're in EIG mode, we want to replace lambda by 1
        if ~isempty(eigVarNames)
            eigvarLoc = find(ismember(prefixOutLambda(:,2), 'LAMBDA')==1);
            prefixOutLambda(eigvarLoc,1) = cellstr(repmat('1',length(eigvarLoc),1));
            prefixOutLambda(eigvarLoc,2) = cellstr(repmat('NUM',length(eigvarLoc),1));
        end
        % Change it to infix form and remove uneccessary parenthesis.
        infixOutLambda = prefix2infix(guifile,prefixOutLambda);
        anFunLambda = parSimp(guifile,infixOutLambda);
    end
end

% Return the derivative on infix form
% infixOut = prefix2infix(guifile,prefixOut);
% Finally, remove unneeded parenthesis.
% anFun = parSimp(guifile,infixOut);

% Check whether we have equations divided by commas. This will only have
% happened if we have any commas left in the prefix expression
commaSeparated = any(strcmp(prefixOut(:,2),'COMMA'));

[infixOut notaVAR] = prefix2infix(guifile,prefixOut);
anFun = parSimp(guifile,infixOut);

% Remove misinterpreted VARs (from Fred, Volt, etc)
for k = numel(varNames):-1:1
    if any(strcmp(varNames{k},notaVAR))
        varNames(k) = [];
    end
end 
 
% Convert the cell array varNames into one string
varString = varNames{1};
for varCounter = 2:length(varNames)
    varString = [varString,',',varNames{varCounter}];
end
anFunComplete = ['@(', varString ') ' anFun];

% Also return the lambda part if we are in EIG mode
if strcmp(guifile.type,'eig') && ~isempty(anFunLambda)
    anFunLambdaComplete = ['@(', varString ') ' anFunLambda];
    anFunComplete = {anFunComplete;anFunLambdaComplete};
    anFun = {anFun; anFunLambda};
end

switch nargout
    case 1
        varargout{1} = anFunComplete;
    case 2
        varargout{1} = anFunComplete;
        varargout{2} = indVarNames;
    case 3
        varargout{1} = anFun;
        varargout{2} = indVarNames;
        varargout{3} = varNames;
    case 4
        varargout{1} = anFun;
        varargout{2} = indVarNames;
        varargout{3} = varNames;
        varargout{4} = pdeVarNames;
    case 5
        varargout{1} = anFun;
        varargout{2} = indVarNames;
        varargout{3} = varNames;
        varargout{4} = pdeVarNames;
        varargout{5} = commaSeparated;
end
end