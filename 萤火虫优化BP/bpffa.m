%% this code for regression based on fa-bp
%% initiate 
clc
clear
close all
tic
% load data
input=xlsread('16组数据','B2:F17');
output=xlsread('16组数据','G2:G17');
%% normlization
[inputn,inputps] = mapminmax(input',0,1);
[outputn,outputps]=mapminmax(output',0,1);
Pn_train=inputn;
Tn_train=outputn;
Pn_test=inputn;
T_test=outputn;

% number of node
inputnum=size(Pn_train,1);
hiddennum=3;
outputnum=1;
net=newff(Pn_train,Tn_train,hiddennum);
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;
[net,per2]=train(net,Pn_train,Tn_train);
an=sim(net,Pn_test);
test_simu=mapminmax('reverse',an,outputps);
figure
plot(test_simu);hold on;plot(output);legend('预测数据','期望数据');title('优化前')
%% 
d=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;% 
Lb=zeros(1,d);  % lower
Ub=ones(1,d); % upper
u0=Lb+(Ub-Lb).*rand(1,d);
para=[20 50 0.25 0.20 1];
% n=para(1);             % number of fireflies
% MaxGeneration=para(2); %number of pseudo time steps
% ------------------------------------------------
% alpha=para(3);         % Randomness 0--1 (highly random)
% betamn=para(4);        % minimum value of beta
% gamma=para(5);         % Absorption coefficient
[nbest,trace]=ffa_mincon(u0,Lb,Ub,para,inputnum,hiddennum,outputnum,net,inputn,outputn);
figure
plot(trace)
xlabel('迭代次数')
ylabel('适应度值')
title('萤火虫优化BP适应度曲线')
x=nbest;
%%
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2;

net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;

[net,per2]=train(net,Pn_train,Tn_train);
% 反归一化
an=sim(net,Pn_test);
test_simu=mapminmax('reverse',an,outputps);
error=test_simu-output;
E=mean(abs(error./output))

figure
plot(test_simu,'b-*')
hold on;
plot(output,'-o')
title('萤火虫优化bp后的结果','fontsize',12)
legend('预测数据','期望数据')
xlabel('样本编号')
ylabel('比较')
toc