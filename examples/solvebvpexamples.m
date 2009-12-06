%% Solving BVPs with Newton iteration
% Below is shown how we can solve the BVP eps*u'' + u'+sin(u) = 0,
% u(0) = 0, u(1) = 1/2 using Newton iteration directly, creating the
% Jacobian explicitly.

[d,x] = domain(0,1);
D = diff(d,1); D2 = diff(d,2);
tic;
nrmduvec = [];
nrmdu = Inf; u = x/2;
eps = 0.03;
counter = 0;
while nrmdu > 1e-10
    u = jacvar(u);    
    r = eps*D2*u + D*u + sin(u);
    A = eps*D2 + D + jacobian(sin(u),u) & 'dirichlet';
    A.scale = norm(u);
    delta = -(A\r);
    u = u + delta;
    nrmdu = norm(delta);
    counter = counter +1;
    nrmduvec(counter) = nrmdu;
end
disp(['Converged in ', num2str(counter), ' iterations']);
figure;plot(u);title('Solution');
figure;semilogy(nrmduvec);title('Norm of update');
toc;

%% Using solveTAD to take care of all the iteration steps

f = @(u) 0.03*diff(u,2) + diff(u,1) + sin(u);
g.left = @(u) u;
g.right = @(u) u-1/2;
[u nrmduvec] = solvebvp(f,g,domain(0,1));
% figure;plot(u);title('Solution');
figure;subplot(1,2,1),plot(u),title('u(x) vs. x');
box on, grid on, xlabel('x'), ylabel('u(x)'), ylim([0 1.2]), set(gca,'Ytick',[0:0.2:1.2])
subplot(1,2,2),semilogy(nrmduvec,'-*');title('Norm of update vs. iteration no.');
box on, grid on, xlabel('Iteration no.'), ylabel('Norm of update');
set(gca,'XTick',[1:4])

%% Fourth order problem
[d,x,N] = domain(0,1);
N.op = @(u) 0.01*diff(u,4) + 10.*diff(u,2) + 100*sin(u);
N.lbc = 1;
N.rbc = { @(u) u, @(u) diff(u), @(u) diff(u,2) };
[u nrmduvec] = N\0;
figure;subplot(1,2,1),plot(u),title('u(x) vs. x');
box on, grid on, xlabel('x'), ylabel('u(x)'), %set(gca,'Ytick',[0:0.2:1.2])
subplot(1,2,2),semilogy(nrmduvec,'-*');title('Norm of update vs. iteration no.');
box on, grid on, xlabel('Iteration no.'), ylabel('Norm of update');
xlim([0 20]),set(gca,'XTick',[0:4:20])

%% Systems of equations
[d,x,N] = domain(-1,1);
N.op = @(u) [ diff(u(:,1)) - sin(u(:,2)), diff(u(:,2)) + cos(u(:,1)) ];
N.lbc = @(u) u(:,1)-1;
N.rbc = @(u) u(:,2);
u = N\0;
figure;plot(u)

%%
cheboppref('tol',5e-9);
[d,x,N] = domain(-1,1);
N.op = @(u) [ diff(u(:,1),2) - sin(u(:,2)), diff(u(:,2),2) + cos(u(:,1)) ];
N.lbc = {@(u) u(:,1)-1, @(u) diff(u(:,2))};
N.rbc = {@(u) u(:,2), @(u) diff(u(:,1))};

[u nrmduvec] = N\0;
figure;subplot(1,2,1),plot(u(:,1)),hold on, plot(u(:,2),'-.r'),hold off
title('u_1(x) and u_2(x) vs. x'); legend('u_1','u_2')
box on, grid on, xlabel('x'), ylabel('u_1(x) and u_2(x)')
subplot(1,2,2),semilogy(nrmduvec,'-*');title('Norm of update vs. iteration no.');
box on, grid on, xlabel('Iteration no.'), ylabel('Norm of update');

