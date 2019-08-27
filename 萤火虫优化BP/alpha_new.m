% convergence can occur. So use with care.
function alpha=alpha_new(alpha,NGen) %
% alpha_n=alpha_0(1-delta)^NGen=0.005
% alpha_0=0.9
delta=1-(10^(-4)/0.9)^(1/NGen);
alpha=(1-delta)*alpha;