%% ��ջ�������
tic
clc
clear
close all
format compact
%% ��������
load data1
input=In';
output=U3;
%%
% �������ѵ���������Լ�
rand('seed',0)

k = randperm(size(input,1));
m=7100;
P_train=input(k(1:m),:)';
T_train=output(k(1:m));

P_test=input(k(m+1:end),:)';
T_test=output(k(m+1:end));

%% ��һ��
% ѵ����
[Pn_train,inputps] = mapminmax(P_train,-1,1);
Pn_test = mapminmax('apply',P_test,inputps);
% ���Լ�
[Tn_train,outputps] = mapminmax(T_train,-1,1);
Tn_test = mapminmax('apply',T_test,outputps);

%% �ڵ����
inputnum=size(Pn_train,1);
hiddennum=5;
outputnum=1;
%% û���Ż���bp
net=newff(Pn_train,Tn_train,hiddennum);
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

%����ѵ��
[net,per2]=train(net,Pn_train,Tn_train);
an=sim(net,Pn_test);
error=an-Tn_test;

test_simu=mapminmax('reverse',an,outputps);
disp('�Ż�ǰ')
E1=norm(error);
E2=mse(error)
MAPE=mean(abs(error)./Tn_test);

figure
plot(test_simu)
hold on
plot(T_test)
legend('ʵ�����','�������')

%% ����Ⱥ�Ż�bp


% [bestchrom,trace]=psoforbp(inputnum,hiddennum,outputnum,Pn_train,Tn_train);%����Ⱥ�㷨
% x=bestchrom;
% save result x
load result%ֱ�ӵ���ѵ���õ�
% ��pso�Ż���BP�������ֵԤ��
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';

%% BP����ѵ��
%�����������
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

%����ѵ��
[net,per2]=train(net,Pn_train,Tn_train);

%% BP����Ԥ��
%���ݹ�һ��
an=sim(net,Pn_test);
error=an-Tn_test;

test_simu=mapminmax('reverse',an,outputps);
disp('�Ż���')
E1=norm(error);
E2=mse(error)
MAPE=mean(abs(error)./Tn_test);
toc
%%
figure
plot(test_simu)
hold on
plot(T_test)
legend('ʵ�����','�������')