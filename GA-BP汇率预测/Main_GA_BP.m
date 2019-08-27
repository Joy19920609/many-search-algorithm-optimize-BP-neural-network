%% 基于遗传算法优化BP神经网络的汇率预测
clear all
clc
close all
warning off
%% 导入数据---我已经把数据从csv文件中复制到数据.xlsx中了。第一列是房价 后面是特征,matlab处理csv文件听麻烦的  一般都是先弄成excel文件
% data0=importdata('数据.xlsx');
data0=xlsread('数据.xlsx');

data0=data0(1:1000,:);%有2万组样本  取1000组出来  ，你要想用完这2万组的话 可以把这句程序注释掉--就是前面加个 % 符号
% 筛选出需要的特征
input=data0(:,2:end);
output=data0(:,1);
% 1-18个特征分别为：bedrooms	bathrooms	sqft_living	sqft_lot	floors	waterfront	view	condition	grade	sqft_above	sqft_basement	yr_built	yr_renovated	zipcode	lat	long	sqft_living15	sqft_lot15

n=[2 3 6 7 9 10 15 17];
%需要的我是把这些特征进行了分类的：
%可以看到主要的影响因素是grade、view 、waterfront(房屋的条件）
%房屋的空间（sqft_living客厅面积，sqft_living1515年客厅面积，
%bathrooms浴室数目,sqft_above），然后可能还是需要考虑房屋位置的影响（lat)@技术人员 

%%对应就这些个特征
input=input(:,n);


%训练集——800个样本
tr_len=800;
input_train = input(1:tr_len, :)';
output_train = output(1:tr_len)';
%测试集——200个样本
input_test = input(tr_len+1:end, :)';
output_test = output(tr_len+1:end)';

%% BP网络设置
%节点个数
[inputnum,N]=size(input_train);%输入节点数量
outputnum=size(output_train,1);%输出节点数量
hiddennum=10;
%选连样本输入输出数据归一化
[inputn,inputps]=mapminmax(input_train,0,1);
[outputn, outputps]=mapminmax(output_train,0,1);% 归一化到【0 1】之间

%构建网络
net=newff(inputn,outputn,hiddennum);
%网络进化参数
net.trainParam.epochs=100;
net.trainParam.lr=0.1;
net.trainParam.mc = 0.8;%动量系数，[0 1]之间
net.trainParam.goal=0.001;
%网络训练
%网络训练
net=train(net,inputn,outputn);
%% BP训练集预测
BP_sim=sim(net,inputn);
%网络输出反归一化
T_sim=mapminmax('reverse',BP_sim,outputps);
% 
 figure
 plot(1:length(output_train),output_train,'b-','linewidth',1)
 hold on
 plot(1:length(T_sim),T_sim,'r-.','linewidth',1)
 axis tight
 xlabel('训练样本','FontSize',12);
 ylabel('房价','FontSize',12);
 legend('实际值','预测值');
 string={'BP预测'};
 title(string);
%% 测试数据归一化
  inputn_test=mapminmax('apply',input_test,inputps);
% %预测输出
  an=sim(net,inputn_test);
  BPsim=mapminmax('reverse',an,outputps);
 figure
 plot(1:length(output_test), output_test,'b-','linewidth',1)
 hold on
 plot(1:length(BPsim),BPsim,'r-.','linewidth',1)
 xlabel('测试样本','FontSize',12);
 ylabel('房价','FontSize',12);
 axis tight
 legend('实际值','预测值');
  string={'BP预测'};
 title(string);

% % 评价
ae= abs(BPsim - output_test);
rmse = (mean(ae.^2)).^0.5;
mae = mean(ae);
mape = mean(100*ae./BPsim);

disp('优化前预测结果评价指标：')
disp(['RMSE = ', num2str(rmse)])
disp(['MAE  = ', num2str(mae)])
disp(['MAPE = ', num2str(mape)])


%% GA算法参数初始化
nvar=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;

%% 遗传算法参数初始化
maxgen=100;                         %进化代数，即迭代次数
sizepop=10;                        %种群规模
pcross=0.8;                       %交叉概率选择，0和1之间
pmutation=0.1;                    %变异概率选择，0和1之间

lenchrom=ones(1,nvar);        %个体长度   
bound=[-1*ones(nvar,1) 1*ones(nvar,1)];  %个体范围


%------------------------------------------------------种群初始化--------------------------------------------------------
individuals=struct('fitness',zeros(1,sizepop), 'chrom',[]);  %将种群信息定义为一个结构体
avgfitness=[];                      %每一代种群的平均适应度
bestfitness=[];                     %每一代种群的最佳适应度
bestchrom=[];                       %适应度最好的染色体
%初始化种群
for i=1:sizepop
    %随机产生一个种群
    individuals.chrom(i,:)=Code(lenchrom,bound);    %编码（binary和grey的编码结果为一个实数，float的编码结果为一个实数向量）
    x=individuals.chrom(i,:);
    %计算适应度
    individuals.fitness(i)=objfun_BP(x,inputnum,hiddennum,outputnum,net,inputn,outputn);

end

%找最好的染色体
[bestfitness bestindex]=min(individuals.fitness);  %[m n]=min(b) m最小值 n列号
bestchrom=individuals.chrom(bestindex,:);  %最好的染色体
avgfitness=sum(individuals.fitness)/sizepop; %染色体的平均适应度
% 记录每一代进化中最好的适应度和平均适应度
trace=[avgfitness bestfitness]; 
 
%% 迭代求解最佳初始阀值和权值
% 进化开始
start_time_train=cputime;
for i=1:maxgen
  %  i
    % 选择
    individuals=Select(individuals,sizepop); 
    avgfitness=sum(individuals.fitness)/sizepop;
    %交叉
    individuals.chrom=Cross(pcross,lenchrom,individuals.chrom,sizepop,bound);
    % 变异
    individuals.chrom=Mutation(pmutation,lenchrom,individuals.chrom,sizepop,i,maxgen,bound);
    
    % 计算适应度 
    for j=1:sizepop
        x=individuals.chrom(j,:); %解码
        individuals.fitness(j)=objfun_BP(x,inputnum,hiddennum,outputnum,net,inputn,outputn);
    end
    
  %找到最小和最大适应度的染色体及它们在种群中的位置
    [newbestfitness,newbestindex]=min(individuals.fitness);
    [worestfitness,worestindex]=max(individuals.fitness);
    % 代替上一次进化中最好的染色体
    if bestfitness>newbestfitness
        bestfitness=newbestfitness;
        bestchrom=individuals.chrom(newbestindex,:);
    end
    individuals.chrom(worestindex,:)=bestchrom;
    individuals.fitness(worestindex)=bestfitness;
    
    avgfitness=sum(individuals.fitness)/sizepop;
    
    trace=[trace;avgfitness bestfitness]; %记录每一代进化中最好的适应度和平均适应度

end
%% 遗传算法结果分析 
figure
plot(trace(:,2),'b-*','linewidth',2)
xlabel('迭代次数')
ylabel('适应度')
%legend('平均适应度','最佳适应度')
grid on
x=bestchrom;
%% 把最优初始阀值权值赋予网络预测
% %用遗传算法优化的BP网络进行值预测
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2;

%% BP网络训练
%网络进化参数
net.trainParam.epochs=100;
net.trainParam.lr=0.1;
net.trainParam.mc = 0.8;%动量系数，[0 1]之间
net.trainParam.goal=0.001;
%网络训练
net=train(net,inputn,outputn);
%% BP训练集预测
BP_sim=sim(net,inputn);
%网络输出反归一化
T_sim=mapminmax('reverse',BP_sim,outputps);
% 
 figure
 plot(1:length(output_train),output_train,'b-','linewidth',1)
 hold on
 plot(1:length(T_sim),T_sim,'r-.','linewidth',1)
 axis tight
 xlabel('训练样本','FontSize',12);
 ylabel('房价','FontSize',12);
 legend('实际值','预测值');
 string={'GA-BP预测'};
 title(string);
%% 测试数据归一化
  inputn_test=mapminmax('apply',input_test,inputps);
% %预测输出
  an=sim(net,inputn_test);
  BPsim=mapminmax('reverse',an,outputps);
 figure
 plot(1:length(output_test), output_test,'b-','linewidth',1)
 hold on
 plot(1:length(BPsim),BPsim,'r-.','linewidth',1)
 xlabel('测试样本','FontSize',12);
 ylabel('房价','FontSize',12);
 axis tight
 legend('实际值','预测值');
  string={'GA-BP预测'};
 title(string);

% % 评价
ae= abs(BPsim - output_test);
rmse = (mean(ae.^2)).^0.5;
mae = mean(ae);
mape = mean(100*ae./BPsim);

disp('优化后预测结果评价指标：')
disp(['RMSE = ', num2str(rmse)])
disp(['MAE  = ', num2str(mae)])
disp(['MAPE = ', num2str(mape)])
