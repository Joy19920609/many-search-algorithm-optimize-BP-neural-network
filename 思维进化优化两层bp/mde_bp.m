%% 思维进化算法应用于优化bp神经网络的初始权值和阈值
%1. initpop_generate.m为初始种群产生函数，ismature.m为判断种群是否成熟函数，subpop_generate.m为子种群产生函数。
%% 清空环境变量
clear all
clc
close all
warning off
format compact
tic
%% 导入数据
load data.mat
% 训练集
Pn_train=P;
Tn_train=T;
% 测试集
Pn_test=Pt;
Tn_test=Tt;
%构建网络
S1=5;%输入层节点 
S2=10;%第一隐含层节点
S3=5;%第二隐含层节点
S4=1;%输出层节点
net=newff(Pn_train,Tn_train,[S2 S3]);view(net)
% 
%% 参数设置
popsize = 20;                      % 种群大小
bestsize = 5;                       % 优胜子种群个数
tempsize = 5;                       % 临时子种群个数
SG = popsize / (bestsize+tempsize); % 子群体大小
iter = 10;                          % 迭代次数

%% 随机产生初始种群
initpop = initpop_generate(popsize,S1,S2,S3,S4,Pn_train,Tn_train,Pn_test,Tn_test);

%% 产生优胜子群体和临时子群体
% 得分排序
[sort_val,index_val] = sort(initpop(:,end),'descend');
% 产生优胜子种群和临时子种群的中心
bestcenter = initpop(index_val(1:bestsize),:);
tempcenter = initpop(index_val(bestsize+1:bestsize+tempsize),:);
% 产生优胜子种群
bestpop = cell(bestsize,1);
for i = 1:bestsize
    center = bestcenter(i,:);
    bestpop{i} = subpop_generate(center,SG,S1,S2,S3,S4,Pn_train,Tn_train,Pn_test,Tn_test);
end
% 产生临时子种群
temppop = cell(tempsize,1);
for i = 1:tempsize
    center = tempcenter(i,:);
    temppop{i} = subpop_generate(center,SG,S1,S2,S3,S4,Pn_train,Tn_train,Pn_test,Tn_test);
end

for itr=1:iter
    itr
    %% 优胜子群体趋同操作并计算各子群体得分
    best_score = zeros(1,bestsize);
    best_mature = cell(bestsize,1);
    for i = 1:bestsize
        best_mature{i} = bestpop{i}(1,:);
        best_flag = 0;                % 优胜子群体成熟标志(1表示成熟，0表示未成熟)
        while best_flag == 0
            % 判断优胜子群体是否成熟
            [best_flag,best_index] = ismature(bestpop{i});
            % 若优胜子群体尚未成熟，则以新的中心产生子种群
            if best_flag == 0
                best_newcenter = bestpop{i}(best_index,:);
                best_mature{i} = [best_mature{i};best_newcenter];
                bestpop{i} = subpop_generate(best_newcenter,SG,S1,S2,S3,S4,Pn_train,Tn_train,Pn_test,Tn_test);
            end
        end
        % 计算成熟优胜子群体的得分
        best_score(i) = max(bestpop{i}(:,end));
    end
    % 绘图(优胜子群体趋同过程)
    if itr==1
    figure
    temp_x = 1:length(best_mature{1}(:,end))+5;
    temp_y = [best_mature{1}(:,end);repmat(best_mature{1}(end),5,1)];
    plot(temp_x,temp_y,'b-o')
    hold on
    temp_x = 1:length(best_mature{2}(:,end))+5;
    temp_y = [best_mature{2}(:,end);repmat(best_mature{2}(end),5,1)];
    plot(temp_x,temp_y,'r-^')
    hold on
    temp_x = 1:length(best_mature{3}(:,end))+5;
    temp_y = [best_mature{3}(:,end);repmat(best_mature{3}(end),5,1)];
    plot(temp_x,temp_y,'k-s')
    hold on
    temp_x = 1:length(best_mature{4}(:,end))+5;
    temp_y = [best_mature{4}(:,end);repmat(best_mature{4}(end),5,1)];
    plot(temp_x,temp_y,'g-d')
    hold on
    temp_x = 1:length(best_mature{5}(:,end))+5;
    temp_y = [best_mature{5}(:,end);repmat(best_mature{5}(end),5,1)];
    plot(temp_x,temp_y,'m-*')
    legend('子种群1','子种群2','子种群3','子种群4','子种群5')
    xlim([1 10])
    xlabel('趋同次数')
    ylabel('得分')
    title('优胜子种群趋同过程')
end
    %% 临时子群体趋同操作并计算各子群体得分
    temp_score = zeros(1,tempsize);
    temp_mature = cell(tempsize,1);
    for i = 1:tempsize
        temp_mature{i} = temppop{i}(1,:);
        temp_flag = 0;                % 临时子群体成熟标志(1表示成熟，0表示未成熟)
        while temp_flag == 0
            % 判断临时子群体是否成熟
            [temp_flag,temp_index] = ismature(temppop{i});
            % 若临时子群体尚未成熟，则以新的中心产生子种群
            if temp_flag == 0
                temp_newcenter = temppop{i}(temp_index,:);
                temp_mature{i} = [temp_mature{i};temp_newcenter];
                temppop{i} = subpop_generate(temp_newcenter,SG,S1,S2,S3,S4,Pn_train,Tn_train,Pn_test,Tn_test);
            end
        end
        % 计算成熟临时子群体的得分
        temp_score(i) = max(temppop{i}(:,end));
    end
     % 绘图(临时子群体趋同过程)
     if itr==1
    figure
    temp_x = 1:length(temp_mature{1}(:,end))+5;
    temp_y = [temp_mature{1}(:,end);repmat(temp_mature{1}(end),5,1)];
    plot(temp_x,temp_y,'b-o')
    hold on
    temp_x = 1:length(temp_mature{2}(:,end))+5;
    temp_y = [temp_mature{2}(:,end);repmat(temp_mature{2}(end),5,1)];
    plot(temp_x,temp_y,'r-^')
    hold on
    temp_x = 1:length(temp_mature{3}(:,end))+5;
    temp_y = [temp_mature{3}(:,end);repmat(temp_mature{3}(end),5,1)];
    plot(temp_x,temp_y,'k-s')
    hold on
    temp_x = 1:length(temp_mature{4}(:,end))+5;
    temp_y = [temp_mature{4}(:,end);repmat(temp_mature{4}(end),5,1)];
    plot(temp_x,temp_y,'g-d')
    hold on
    temp_x = 1:length(temp_mature{5}(:,end))+5;
    temp_y = [temp_mature{5}(:,end);repmat(temp_mature{5}(end),5,1)];
    plot(temp_x,temp_y,'m-*')
    legend('子种群1','子种群2','子种群3','子种群4','子种群5')
    xlim([1 10])
    xlabel('趋同次数')
    ylabel('得分')
    title('临时子种群趋同过程')
     end
%     
    %% 异化操作
    [score_all,index] = sort([best_score temp_score],'descend');
    % 寻找临时子群体得分高于优胜子群体的编号
    rep_temp = index(find(index(1:bestsize) > bestsize)) - bestsize;
    % 寻找优胜子群体得分低于临时子群体的编号
    rep_best = index(find(index(bestsize+1:end) < bestsize+1) + bestsize);
    
    % 若满足替换条件
    if ~isempty(rep_temp)
        % 得分高的临时子群体替换优胜子群体
        for i = 1:length(rep_best)
            bestpop{rep_best(i)} = temppop{rep_temp(i)};
        end
        % 补充临时子群体，以保证临时子群体的个数不变
        for i = 1:length(rep_temp)
            temppop{rep_temp(i)} = initpop_generate(SG,S1,S2,S3,S4,Pn_train,Tn_train,Pn_test,Tn_test);
        end
%     else
%         break;
    end
    
    %% 输出当前迭代获得的最佳个体及其得分
    if index(1) < 6
        best_individual = bestpop{index(1)}(1,:);
    else
        best_individual = temppop{index(1) - 5}(1,:);
    end
end

%% 解码最优个体

x = best_individual;

 % 前S1*S2个编码为W1（输入层与第一个隐含层间权值）
    temp = x(1:S1*S2);
    W1 = reshape(temp,S2,S1);
    
    % 接着的S2*S3个编码为W2（隐含层与第二隐含层间权值）
    temp = x(S1*S2+1:S1*S2+S2*S3);
    W2 = reshape(temp,S3,S2);
    
    % 接着的S3*S4个编码为W3（隐含层与第二隐含层间权值）
    temp = x(S1*S2+S2*S3+1:S1*S2+S2*S3+S3*S4);
    W3 = reshape(temp,S4,S3);
    
    % 接着的S2个编码为B1（第一隐含层神经元阈值）
    temp = x(S1*S2+S2*S3+S3*S4+1:S1*S2+S2*S3+S3*S4+S2);
    B1 = reshape(temp,S2,1);
    % 接着的S3个编码为B2（第2隐含层神经元阈值）
    temp = x(S1*S2+S2*S3+S3*S4+S2+1:S1*S2+S2*S3+S3*S4+S2+S3);
    B2 = reshape(temp,S3,1);
    %接着的S4个编码B3（输出层神经元阈值）
    temp = x(S1*S2+S2*S3+S3*S4+S2+S3+1:end-1);
    B3 = reshape(temp,S4,1);
  
%% 创建/训练双隐层bp神经网络
%构建网络
net_optimized=newff(Pn_train,Tn_train,[S2 S3]);
% 设置训练参数
net_optimized.trainParam.epochs = 100;
net_optimized.trainParam.show = 10;
net_optimized.trainParam.goal = 1e-4;
net_optimized.trainParam.lr = 0.1;
net_optimized.trainParam.showWindow=0;
% 设置网络初始权值和阈值
net_optimized.IW{1,1} = W1;
net_optimized.LW{2,1} = W2;
net_optimized.LW{3,2} = W3;
net_optimized.b{1} = B1;
net_optimized.b{2} = B2;
net_optimized.b{3} = B3;
% 利用新的权值和阈值进行训练
net_optimized = train(net_optimized,Pn_train,Tn_train);

%% 仿真测试
Tn_sim = sim(net_optimized,Pn_test);    
% 反归一化
%根据归一化公式将预测数据还原成股票价格
T_sim=Tn_sim*(ma-mi)+mi;
T_test=Tn_test*(ma-mi)+mi;

%% 结果对比
result = [T_test' T_sim'];

figure
plot(T_sim);hold on
plot(T_test)
legend('网络测试','真实测试集')
% end
toc
