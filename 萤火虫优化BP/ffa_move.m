% Move all fireflies toward brighter ones
function [ns]=ffa_move(n,d,ns,Lightn,nso,Lighto,nbest,Lightbest,alpha,betamin,gamma,Lb,Ub)
% Scaling of the system
scale=abs(Ub-Lb);

% Updating fireflies
for i=1:n  
% The attractiveness parameter beta=exp(-gamma*r)
   for j=1:n
      r=sqrt(sum((ns(i,:)-ns(j,:)).^2));  %
      % Update moves
if Lightn(i)>Lighto(j) % Brighter and more attractive
        beta0=1; beta=(beta0-betamin)*exp(-gamma*r.^2)+betamin;
        tmpf=alpha.*(rand(1,d)-0.5).*scale;
        ns(i,:)=ns(i,:).*(1-beta)+nso(j,:).*beta+tmpf;
        [ns]=findlimits(n,ns,Lb,Ub);
   end
   end % end for j
end % end for i