function [a b t DE DErhs LBC LBCrhs RBC RBCrhs guess tol name] = bvpexamples(exampleNumber,mode)
if nargin < 2
    mode = 'start';
end

numberOfExamples = 9;

% If called with a 0, open with an empty gui. If called with a number less
% than 0, bigger than the number of available examples, or no argument,
% start with a random example.
if exampleNumber < 0 || exampleNumber > numberOfExamples
    exampleNumber = ceil(numberOfExamples*rand(1));
    % If we call the function with the Demos button, we want to notify the
    % code that we have extracted information about all examples.
    if strcmp(mode,'demo')
        a = 0; b = 0; t = 0; DE = '0'; DErhs = '0'; LBC = 0; LBCrhs = 0;
        RBC = 0; RBCrhs = 0; guess = 0; tol = 0; name = '0';
        return
    end
end

switch exampleNumber
    case 0
        a = '';
        b = '';
        t = '';
        DE = '';
        DErhs = '';
        LBC = '';
        LBCrhs = '';
        RBC = '';
        RBCrhs = '';
        guess = '';
        tol = '';
        name = '';
    case 1
        a = '-3*pi/4';
        b = 'pi';
        t = '0:.05:2';
        DE = '0.1*u"+u''';
        DErhs = 'u_t';
        LBC = 'neumann';
        LBCrhs = '';
        RBC = 'dirichlet';
        RBCrhs = '';
        guess = 'sin(2*x)';
        tol = '1e-6';
        name = DE;
    case 2
        a = '-1';
        b = '1';
        t = 'linspace(0,5,50)';
        DE = 'u.*(1-u.^2) + 5e-4*u"';
        DErhs = 'u_t';
        LBC = 'neumann';
        LBCrhs = '';
        RBC = 'neumann';
        RBCrhs = '';
        guess = '(1-x.^2).^2.*(1+sin(12*x))/2';
        tol = '1e-6';
        name = 'Allen-Cahn (neumann)';
    case 3
        a = '-1';
        b = '1';
        t = 'linspace(0,5,50)';
        DE = 'u.*(1-u.^2) + 5e-4*u"';
        DErhs = 'u_t';
        LBC = 'u';
        LBCrhs = '-1';
        RBC = 'u';
        RBCrhs = '1';
        guess = '0.53*x-.47*sin(1.5*pi*x)';
        tol = '1e-6';
        name = 'Allen-Cahn (dirichlet)';
    case 4
        a = '-1';
        b = '1';
        t = '0:.1:4';
        DE = '-(u.^2)''+.01*u"';
        DErhs = 'u_t';
        LBC = 'dirichlet';
        LBCrhs = '';
        RBC = 'dirichlet';
        RBCrhs = '';
        guess = '(1-x.^2).*exp(-30*(x+.5).^2)';
        tol = '1e-6';
        name = 'Burgers''';
    case 5
        a = '-1';
        b = '1';
        t = 'linspace(0,2,200)';
        DE = 'u.*u''-u"-0.006*u""';
        DErhs = 'u_t';
        LBC = {'u','u'''};
        LBCrhs = {'1','2'};
        RBC = {'u','u'''};
        RBCrhs = {'1','2'};
        guess = '1 + 0.5*exp(-40*x.^2)';
        tol = '1e-6';
        name = 'KS';
	case 6
        a = '-1';
        b = '1';
        t = '0:.05:2';
        DE = {'-u + (x + 1).*v + 0.1*u"'; 'u - (x + 1).*v + 0.2*v"'};
        DErhs = {'u_t';'v_t'};
        LBC = {'u''';'v'''};
        LBCrhs = {'0';'0'};
        RBC = {'u''';'v'''};
        RBCrhs = {'0';'0'};
        guess = {'1';'1'};
        tol = '1e-6';
        name = 'System 1';
    case 7
        a = '-1';
        b = '1';
        t = '0:.05:2';
        DE = {'u - (x + 1).*v + 0.2*v"' ; '-u + (x + 1).*v + 0.1*u"'};
        DErhs = {'v_t';'u_t'};
        LBC = {'u''';'v'''};
        LBCrhs = {'0';'0'};
        RBC = {'u''';'v'''};
        RBCrhs = {'0';'0'};
        guess = {'1';'1'};
        tol = '1e-6';
        name = 'System 1 (flipped)';
    case 8
        a = '-1';
        b = '1';
        t = '0:.1:2';
        DE = {'0.1*u"-100*u*v' ; '0.2*v"-100*u*v' ; '0.001*w"+200*u*v'};
        DErhs = {'u_t';'v_t';'w_t'};
        LBC = {'neumann'};
%         LBC = {'u'''; 'v''' ; 'w'''};
        LBCrhs = {'0' ; '0' ; '0'};
        RBC = {'neumann'};
%         RBC = {'u'''; 'v''' ; 'w'''};
        RBCrhs = {'0' ; '0' ; '0'};
        guess = {'1-erf(10*(x+0.7))' ; '1 + erf(10*(x-0.7))' ; '0'};
        tol = '1e-6';
        name = 'System 2 (3 eqns)';
    case 9
        a = '-1';
        b = '1';
        t = '0:.1:2';
        DE = {'0.1*u"-100*u*v' ; '0.2*v"-100*u*v' ; '0.001*w"+200*u*v'};
        DErhs = {'u_t';'v_t';'w_t'};
%         LBC = {'neumann'};
        LBC = {'u'''; 'v''' ; 'w'''};
        LBCrhs = {'0' ; '0' ; '0'};
%         RBC = {'neumann'};
        RBC = {'u'''; 'v''' ; 'w'''};
        RBCrhs = {'0' ; '0' ; '0'};
        guess = {'1-erf(10*(x+0.7))' ; '1+erf(10*(x-0.7))' ; '0'};
        tol = '1e-6';
        name = 'System 2 (3 eqns alt)';        
end