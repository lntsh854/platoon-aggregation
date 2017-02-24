% Dynamics for a single platoon (NLPlatoonFull simulates 2 such platoons)
% d/dt xL = vL
% d/dt vL = -vL + v0 + u1(t)
% d/dt x1 = v1
% d/dt v1 = -v1 + v01 + g(xL - x1)
% d/dt x2 = v2
% d/dt v2 -v2 + v02 + g(x1 - x2)

% let g(x) = unidirectional spring = log(x)

x0 = [300; 0; 250; 0; 200; 0; 150; 0; 100; 0; 50; 0];
z0 = [300; 0; 150; 0]; % initial conditions

parameters = set_parameters; % set parameters for platoon

% simulate concrete platoon
[tx,x] = ode45(@(t1,x) NLPlatoonFull(t1,x,parameters), [0, 60], x0);
x = x';

% simulate abstraction platoon
[tz,z] = ode45(@(t2,z) NLPlatoonAbs(t2,z,parameters), [0, 60], z0);
z = z';

% get error(t) = norm(x(t) - (Pz(t) + omega))
[e, xl] = get_error(z,tz,x,tx,parameters);