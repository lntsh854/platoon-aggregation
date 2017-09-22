function [M, K, e_max] = Linf_gain_K(A, B, C, F, alpha)
% Consider dynamics of the form
%
% d/dt e = (A + B*K)*e + F*d
%
% Find Lyapunov matrix M and state feedback K such that
%
% e^T P e >= val_max and d^T d >= d_max
%
% implies e^T*(A + B*K)^T*M*e + e^T*M*(A + B*K)*e <= 0
%
% also add output constraint which ensures
%
% M >= C^T C

% define new variables M_bar = M^(-1) and K_bar = K*M^(-1)
M_bar = sdpvar(12,12,'symmetric');
K_bar = sdpvar(2,12);

% ensure M is positive definite
cnstr = (M_bar >= 0);

% add decay constraint
k = size(F,2);
H = [A*M_bar + M_bar*A' + K_bar'*B' + B*K_bar + alpha*M_bar, F;
    F', -alpha*eye(k)];
cnstr = [cnstr, H <= 0];

% add objective (maximize minimum eigenvalue)
t = sdpvar;
cnstr = [cnstr, M_bar <= t*eye(size(M_bar))];

% bisection(cnstr, t, sdpsettings('solver','mosek'));
optimize(cnstr, t, sdpsettings('solver','mosek'));

% get lyapunov and feedback matrices
M = inv(value(M_bar));
K = value(K_bar)*M;

% find bound
lambda_min = min(eig(M));
e_max = sqrt(1/lambda_min);

end