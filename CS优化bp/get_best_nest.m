%% Find the current best nest
function [fmin,best,nest,fitness]=get_best_nest(nest,newnest,fitness,inputnum,hiddennum,outputnum,net,inputn,outputn)
% global inputnum hiddennum outputnum net inputn outputn
% Evaluating all new solutions
for j=1:size(nest,1)
    fnew=fun1(newnest(j,:),inputnum,hiddennum,outputnum,net,inputn,outputn);
    if fnew<=fitness(j)
       fitness(j)=fnew;
       nest(j,:)=newnest(j,:);
    end
end
% Find the current best
[fmin,K]=min(fitness) ;
best=nest(K,:);