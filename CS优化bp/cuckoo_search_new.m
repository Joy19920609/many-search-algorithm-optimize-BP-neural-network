function [bestnest,yy]=cuckoo_search_new(inputnum,hiddennum,outputnum,net,inputn,outputn)
% Number of nests (or different solutions)
n=10;% Äñ³²
% Discovery rate of alien eggs/solutions
pa=0.25;
% Change this if you want to get better results
N_IterTotal=100;
%% Simple bounds of the search domain
% Lower bounds
global nd;
nd=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum; 
Lb=-1*ones(1,nd); 
% Upper bounds
Ub=1*ones(1,nd);

% Random initial solutions
for i=1:n
nest(i,:)=Lb+(Ub-Lb).*rand(size(Lb));

end

% Get the current best
fitness=10^10*ones(n,1);
[fmin,bestnest,nest,fitness]=get_best_nest(nest,nest,fitness,inputnum,hiddennum,outputnum,net,inputn,outputn);

N_iter=0;
%% Starting iterations
for iter=1:N_IterTotal,
    iter
    % Generate new solutions (but keep the current best)
     new_nest=get_cuckoos(nest,bestnest,Lb,Ub);   
     [fnew,best,nest,fitness]=get_best_nest(nest,new_nest,fitness,inputnum,hiddennum,outputnum,net,inputn,outputn);
    % Update the counter
      N_iter=N_iter+n; 
    % Discovery and randomization
      new_nest=empty_nests(nest,Lb,Ub,pa) ;
    
    % Evaluate this set of solutions
      [fnew,best,nest,fitness]=get_best_nest(nest,new_nest,fitness,inputnum,hiddennum,outputnum,net,inputn,outputn);
    % Update the counter again
      N_iter=N_iter+n;
    % Find the best objective so far 
    if fnew<fmin
        fmin=fnew;
        bestnest=best;
    end
    yy(iter)=fmin;
end %% End of iterations


bestnest;