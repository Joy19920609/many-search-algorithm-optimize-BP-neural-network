
function [ns]=findlimits(n,ns,Lb,Ub)
for i=1:n
     % Apply the lower bound
  ns_tmp=ns(i,:);
  I=ns_tmp<Lb;
  ns_tmp(I)=Lb(I);
  % Apply the upper bounds
  J=ns_tmp>Ub;
  ns_tmp(J)=Ub(J);
  % Update this new move 
  ns(i,:)=ns_tmp;
end
