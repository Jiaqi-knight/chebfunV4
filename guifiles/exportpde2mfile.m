function exportpde2mfile(pathname,filename,handles)

fullFileName = [pathname,filename];
fid = fopen(fullFileName,'wt');

if ispc
    userName = getenv('UserName');
else
    userName = getenv('USER');
end

fprintf(fid,'%% %s - Executable .m file for solving a PDE.\n',filename);
fprintf(fid,'%% Automatically created from chebgui by user %s\n',userName);
fprintf(fid,'%% %s, %s.\n\n',datestr(rem(now,1),13),datestr(floor(now)));

% Extract information from the GUI fields
a = get(handles.dom_left,'String');
b = get(handles.dom_right,'String');
deInput = get(handles.input_DE,'String');
lbcInput = get(handles.input_LBC,'String');
rbcInput = get(handles.input_RBC,'String');
deRHSInput = get(handles.input_DE_RHS,'String');
lbcRHSInput = get(handles.input_LBC_RHS,'String');
rbcRHSInput = get(handles.input_RBC_RHS,'String');
guessInput = get(handles.input_GUESS,'String');
tolInput = get(handles.input_tol,'String');
tt = get(handles.timedomain,'String');

% Wrap all input strings in a cell (if they're not a cell already)
if isa(deInput,'char'), deInput = cellstr(deInput); end
if isa(lbcInput,'char'), lbcInput = cellstr(lbcInput); end
if isa(rbcInput,'char'), rbcInput = cellstr(rbcInput); end
if isa(deRHSInput,'char'), deRHSInput = cellstr(deRHSInput); end
if isa(lbcRHSInput,'char'), lbcRHSInput = cellstr(lbcRHSInput); end
if isa(rbcRHSInput,'char'), rbcRHSInput = cellstr(rbcRHSInput); end

% [deString indVarName] = setupFields(deInput,deRHSInput,'DE');
[deString indVarName pdeflag] = setupFields(deInput,deRHSInput,'DE');  
if ~pdeflag
    error('CHEBFUN:chebpde:notapde','Input does not appear to be a PDE, ', ...
        'or at least is not a supported type.');
end
idx = strfind(deString, ')');
deString = [deString(1:idx(1)-1), ',t,x,diff', deString(idx(1):end)];

fprintf(fid,['%% Create a domain and the linear function on it.\n']);
fprintf(fid,'[d,%s] = domain(%s,%s);\n',indVarName,a,b);

fprintf(fid,['\n%% Construct a discretisation of the time domain to solve on.\n']);
fprintf(fid,'tt = %s;\n',tt);

fprintf(fid,'\n%% Make the rhs of the PDE.\n');
fprintf(fid,'pdefun = %s;\n',deString);

% Make assignments for left and right BCs.
fprintf(fid,'\n%% Assign boundary conditions.\n');
if ~isempty(lbcInput{1})
    [lbcString indVarName] = setupFields(lbcInput,lbcRHSInput,'BC');
    idx = strfind(lbcString, ')');
    if ~isempty(idx)
        lbcString = [lbcString(1:idx(1)-1), ',t,x,diff', lbcString(idx(1):end)];
%             lbcString = strrep(lbcString,'diff','D');
    end
    fprintf(fid,'bc.left = %s;\n',lbcString);
end

if ~isempty(rbcInput{1})
    [rbcString indVarName] = setupFields(rbcInput,rbcRHSInput,'BC');
    idx = strfind(rbcString, ')');
    if ~isempty(idx)
        rbcString = [rbcString(1:idx(1)-1), ',t,x,diff', rbcString(idx(1):end)];
%             rbcString = strrep(rbcString,'diff','D');
    end
    fprintf(fid,'bc.right = %s;\n',rbcString);
end

% Set up the initial condition
fprintf(fid,'\n%% Create a chebfun of the initial condition(s).\n');
if ischar(guessInput)
    % Get the strings of the dependant variable.
    idx = strfind(deString,')');
    tmp = deString(3:idx(1)-10);
    idx = strfind(tmp,',');
    if isempty(idx)
        s = tmp;
    else
        s = tmp(1:idx(1)-1);
    end 
    sol = s; sol0 = [sol '0'];
    findx = strfind(guessInput,'x');
    if isempty(findx)
        fprintf(fid,'%s = chebfun(%s,d);\n',sol0,guessInput);
    else
        fprintf(fid,'%s = %s;\n',sol0,guessInput);
    end        
else
    % Get the strings of the dependant variables.
    idx = strfind(deString,')');
    tmp = deString(3:idx(1)-10);
    idx = strfind(tmp,',');
    if isempty(idx)
        s = {tmp};
    else
        s = cell(1,length(idx)+1);
        s{1} = tmp(1:idx(1)-1);
        for k = 2:length(idx)
            s{k} = tmp(idx(k-1)+1:idx(k)-1);
        end
        if isempty(k), k = 1; end
        s{k+1} = tmp(idx(k)+1:end);
    end    
    
    % If the initial guesses are all constants, we need to wrap them in a
    % chebfun call.
    for k = 1:numel(guessInput)
        findx = strfind(guessInput{k},'x');
        if ~isempty(findx), break, end
    end
    % Print the conditions.
    catstr = [];
    for k = 1:numel(guessInput)
        if ~isempty(findx)
            fprintf(fid,'%s = %s;\n',s{k},guessInput{k});
        else
            fprintf(fid,'%s = chebfun(%s,d);\n',s{k},guessInput{k});
        end
        catstr = [catstr ', ' s{k}];
    end
    sol0 = 'sol0'; sol = 'sol';
    fprintf(fid,'%s = [%s];\n',sol0,catstr(3:end));
end

% Option for tolerance
opts = [];
tolInput = get(handles.input_tol,'String');
opts = [opts,'''Eps'',',tolInput];

% Options for plotting
doplot = get(handles.button_pdeploton,'Value');
if ~doplot
    opts = [opts,''',Plot,''','''off'''];
else
    dohold = get(handles.button_holdon,'Value');
    if dohold
        opts = [opts,',''HoldPlot'',','''on'''];
    end
    ylim1 = get(handles.ylim1,'String');
    ylim2 = get(handles.ylim2,'String');
    if ~isempty(ylim1) && ~isempty(ylim2)
        opts = [opts,',''Ylim'',[',ylim1,',',ylim2,']'];
    end
    plotstyle = get(handles.input_plotstyle,'String');
    if ~isempty(plotstyle)
        opts = [opts,',''PlotStyle'',''',plotstyle,''''];
    end
end

% Options for fixed N
if get(handles.checkbox_fixN,'Value')
    N = get(handles.input_N,'String');
    if isempty(N), error('CHEBFUN:exportpde2mfile:N','N must be given.'); end
    opts = [opts,',''N'',',N];
end        

% Set up preferences
fprintf(fid,'\n%% Setup preferences for solving the problem.\n');
fprintf(fid,'opts = pdeset');
if isempty(opts)
    fprintf(fid,';\n',opts);
else
    fprintf(fid,'(%s);\n',opts);
end

fprintf(fid,['\n%% Solve the problem using pde15s.\n']);
fprintf(fid,'[tt %s] = pde15s(pdefun,tt,%s,bc,opts);\n',sol,sol0);

% Conver sol to variable names
if numel(deInput) > 1
    fprintf(fid,'\n%% Recover variable names.\n');
    for k = 1:numel(s)
        fprintf(fid,'%s = %s{%d};\n',s{k},sol,k);
    end
end

% plotting
if numel(deInput) == 1
    fprintf(fid,'\n%% Create plot of the solution.\n');
%     fprintf(fid,'surf(%s,tt,''facecolor'',''interp'')\n',sol);
    fprintf(fid,'waterfall(%s,tt,''simple'',''linewidth'',2)\n',sol);
else
    fprintf(fid,'\n%% Create plots of the solutions.\n');
%     fprintf(fid,'for k = 1:numel(%s)\n',sol);
%     fprintf(fid,'   subplot(1,numel(%s),k)\n',sol);
%      fprintf(fid,'   surf(sol{k},tt,''facecolor'',''interp'')\n');
%     fprintf(fid,'end\n');
    M = numel(deInput);
    for k = 1:numel(deInput)
        fprintf(fid,'subplot(1,%d,%d)\n',M,k);
        fprintf(fid,'waterfall(%s,tt,''simple'',''linewidth'',2)\n',s{k});
        fprintf(fid,'xlabel(''x''), ylabel(''t''), title(''%s'')\n',s{k});
    end
end

fclose(fid);
end