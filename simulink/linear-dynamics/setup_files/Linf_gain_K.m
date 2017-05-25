function [M, K, e_max] = Linf_gain_K(A, B, C, F, rate, val_max, d_max)
% Consider dynamics of the form
%
% d/dt e = (A + B*K)*e + F*d
%
% Find Lyapunov matrix M and state feedback K to achieve a decay rate
% specified by 'rate', i.e.
% 
% find M, K
% s.t. M >= C'*C                                              (1)
%      (A + B*K)^T*M + M*(A + B*K) <= -2*rate*M               (2)
%
% furthermore, require that
%
% e^T P e >= val_max and d^T d >= d_max
%
% implies e^T*(A + B*K)^T*M*e + e^T*M*(A + B*K)*e <= 0        (3)

% define new variables M_bar = M^(-1) and K_bar = K*M^(-1)
M_bar = sdpvar(12,12,'symmetric');
K_bar = sdpvar(2,12);

% add constraint (1)
k = size(C,1);
% G = [M_bar, M_bar*C';
%     C*M_bar, eye(k)];
% cnstr = [G >= 0];
epsilon = 1e-5;
cnstr = [M_bar >= epsilon*eye(size(M_bar))];

% add constraint (2)
cnstr = [cnstr, M_bar*A' + A*M_bar + K_bar'*B' + B*K_bar <= -2*rate*M_bar];

% add constraint (3)
alpha = 1;
k = size(F,2);
H = [A*M_bar + M_bar*A' + K_bar'*B' + B*K_bar + alpha*M_bar, F;
    F', -alpha*val_max/d_max*eye(k)];
cnstr = [cnstr, H <= 0];

% add objective (maximize minimum eigenvalue)
t = sdpvar;
cnstr = [cnstr, M_bar <= -t*eye(size(M_bar))];

% call solver
bisection(cnstr, t, sdpsettings('solver','mosek'));

% get lyapunov and feedback matrices
M = inv(value(M_bar));
K = value(K_bar)*M;

% find bound
lambda_min = min(eig(M));
e_max = sqrt(val_max/lambda_min);

end