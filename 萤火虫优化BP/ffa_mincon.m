%% Cost or Objective function 
function [nbest,trace,fbest,NumEval]=ffa_mincon(u0,Lb,Ub,para,inputnum,hiddennum,outputnum,net,inputn,outputn) % para=[20 500 0.5 0.2 1]; 
% Check input parameters (otherwise set as default values)
if nargin<5, para=[20 50 0.25 0.20 1]; end  
if nargin<4, Ub=[]; end
if nargin<3, Lb=[]; end
if nargin<2,
disp('Usuage: FA_mincon(@cost,u0,Lb,Ub,para)');
end
% n=number of fireflies
% MaxGeneration=number of pseudo time steps
% ------------------------------------------------
% alpha=0.25;      % Randomness 0--1 (highly random)
% betamn=0.20;     % minimum value of beta
% gamma=1;         % Absorption coefficient
% ------------------------------------------------
n=para(1);  
MaxGeneration=para(2);  %MaxGeneration
alpha=para(3); 
betamin=para(4); 
gamma=para(5);        
NumEval=n*MaxGeneration;
fbest=inf;
% Check if the upper bound & lower bound are the same size
if length(Lb) ~=length(Ub),
    disp('Simple bounds/limits are improper!');
    return
end

% Calcualte dimension        
d=length(u0); %
% Initial values of an array       
zn=ones(n,1)*10^100;
% ------------------------------------------------
% generating the initial locations of n fireflies       
[ns,Lightn]=init_ffa(n,d,Lb,Ub,u0);  % 
% Iterations or pseudo time marching
for k=1:MaxGeneration,     %%%%% start iterations     
k
% This line of reducing alpha is optional
 alpha=alpha_new(alpha,MaxGeneration);
% Evaluate new solutions (for all n fireflies)       
for i=1:n
   zn(i)=fun(ns(i,:),inputnum,hiddennum,outputnum,net,inputn,outputn);               
   Lightn(i)=zn(i);
end
% Display the shape of the objective function
% Ranking fireflies by their light intensity/objectives 
[Lightn,Index]=sort(zn);
         ns_tmp=ns;
for i=1:n
 ns(i,:)=ns_tmp(Index(i),:);
end
%% Find the current best  
nso=ns; 
Lighto=Lightn;
Lightbest=Lightn(1);

% update the global best
if fbest>Lightbest
    fbest=Lightbest;
    nbest=ns(1,:);
end

% Move all fireflies to the better locations 
[ns]=ffa_move(n,d,ns,Lightn,nso,Lighto,nbest,Lightbest,alpha,betamin,gamma,Lb,Ub);
trace(k)=fbest;
end   %%%%% end of iterations