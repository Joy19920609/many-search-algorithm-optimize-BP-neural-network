%% 清空环境变量
clc
clear
close all
format compact 
%% 网络结构建立
%% 清空环境变量
clc
clear
close all
format compact 
%% 网络结构建立
%读取数据
data=xlsread('天气_电量_数据.xlsx','C12:J70');%前7列为每个时刻的发电量 最后列为天气

for i=1:58
    input(i,:)=[data(i,:) data(i+1,end)];
    output(i,:)=data(i+1,1:7);
end

%% 节点个数
inputnum=9;%输入 前一天7个时刻的电量+前一天的天气+预测日的天气
hiddennum=5;
outputnum=7;%预测日7个时刻的发电量

%% 训练数据和预测数据 最后一天用来测试  前面的都拿来训练
input_train=input(1:57,:)';
input_test=input(58,:)';
output_train=output(1:57,:)';
output_test=output(58,:)';

%选连样本输入输出数据归一化
[inputn,inputps]=mapminmax(input_train);
[outputn,outputps]=mapminmax(output_train);
inputn_test=mapminmax('apply',input_test,inputps);
%%

%构建网络
net=newff(inputn,outputn,hiddennum);

%寻优
[bestnest,trace]=cuckoo_search_new(inputnum,hiddennum,outputnum,net,inputn,outputn);
figure
plot(trace)
title('适应度曲线')
xlabel('迭代数')
ylabel('适应度值')


%% 把最优初始阀值权值赋予网络预测
x=bestnest;
% 用CS优化的BP网络进行值预测
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
%net.trainParam.goal=0.00001;

%网络训练
[net,per2]=train(net,inputn,outputn);

%% BP网络预测
%数据归一化
load cs_bp
inputn_test=mapminmax('apply',input_test,inputps);
an=sim(net,inputn_test);
test_simu=mapminmax('reverse',an,outputps);
error=test_simu-output_test;
%%
figure
a1=output_test;
a2=test_simu;
plot(a1,'*-');hold on
plot(a2,'O-')
title('2019年3月31日各时刻发电量')
xlabel('')
legend('原始数据','bp预测数据')
set(gca,'XTick',1:7,...                                    
        'XTickLabel',{'9:00','10:00','11:00','12:00','13:00','14:00','15:00'},...
        'TickLength',[0 0]);
grid on
ylabel('发电量（KW）')







