%% 清空环境变量 模拟退火优化优化BP
clc
clear
close all
format compact
%% 读取数据  
data= xlsread('数据.xlsx','sheet4','B2:Q22');
input=data(:,1:end-1);


label=data(:,end)+1;
for i=1:length(label)
    output(i,label(i))=1;
end
%% 选择测试集与训练集 随机选择15组作为训练数据   剩下的组作为测试数据
rand('seed',0)
[m n]=sort(rand(1,size(input,1)));
m=15;
input_train=input(n(1:m),:)';
input_test=input(n(m+1:end),:)';
outputn=output(n(1:m),:)';
output_test=output(n(m+1:end),:)';
%归一化
[inputn,inputps]=mapminmax(input_train);
inputn_test=mapminmax('apply',input_test,inputps);
%% 没优化的BP
%% 节点个数
inputnum=size(input,2);%输入 前一天7个时刻的电量+前一天的天气+预测日的天气
hiddennum=5;
outputnum=size(output,2);
%
net=newff(inputn,outputn,hiddennum);
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;
net=train(net,inputn,outputn);
simu=sim(net,input_test);
%
[I ,Tn_sim]=max(simu',[],2);
[I1 ,label_test]=max(output_test',[],2);
test_accuracy=(sum(label_test==Tn_sim))/length(label_test);
figure
stem(label_test,'*')
hold on
plot(Tn_sim,'p')
title('没有优化的BP')
legend('期望输出','实际输出')
xlabel('样本数')
ylabel('类别标签')
%% 利用模拟退火算法对BP神经网路的权值与阈值进行优化
[bestchrom,trace]=saforbp(inputnum,hiddennum,outputnum,inputn,outputn,net);%模拟退火

%% 优化后结果分析
figure
plot(trace,'b--');
title('适应度曲线图')
xlabel('进化代数');ylabel('适应度值');
x=bestchrom;
%% 把最优初始阀值权值赋予BP重新训练与预测
% 用优化的BP网络进行值预测
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);
net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';

%% BP网络训练
%网络进化参数
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;
% 网络训练
[net,per2]=train(net,inputn,outputn);

%% BP网络预测
%数据归一化
inputn_test=mapminmax('apply',input_test,inputps);
an=sim(net,inputn_test);
%%
[I ,Tn_sim]=max(an',[],2);
[I1 ,label_test]=max(output_test',[],2);

youhua_test_accuracy=(sum(label_test==Tn_sim))/length(label_test);

figure
stem(label_test,'*')
hold on
plot(Tn_sim,'p')
title('优化后的BP')
legend('期望输出','实际输出')
xlabel('样本数')
ylabel('类别标签')
%%
disp('优化前测试集分类正确率')
test_accuracy
disp('优化后测试集分类正确率')
youhua_test_accuracy

