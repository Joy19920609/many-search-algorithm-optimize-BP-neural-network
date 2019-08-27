function [y,trace]=antforelm(inputnum,hiddennum,outputnum,net,inputn_train,label_train);%蚁群算法%%%%%%%%%%%%%%%%%%%%蚁群算法求函数极值%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%初始化%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m=5;                    %蚂蚁个数
G_max=100;               %最大迭代次数
Rho=0.5;                 %信息素蒸发系数
P0=0.5;                  %转移概率常数
XMAX= 1;                 %搜索变量x最大值
XMIN=-1;                %搜索变量x最小值
d=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;    
%%%%%%%%%%%%%%%%%随机设置蚂蚁初始位置%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
    X(i,:)=(XMIN+(XMAX-XMIN).*rand(1,d));
    Tau(i)=fun(X(i,:),inputnum,hiddennum,outputnum,net,inputn_train,label_train); 
end

bestfitness=inf;
bestfitness_position=inf*ones(1,d);

step=0.1;                %局部搜索步长
for NC=1:G_max
    NC
    lamda=1/NC;
    [Tau_best,BestIndex]=min(Tau);
    %%%%%%%%%%%%%%%%%%计算状态转移概率%%%%%%%%%%%%%%%%%%%%
    for i=1:m
        P(NC,i)=(Tau(BestIndex)-Tau(i))/Tau(BestIndex);
    end
    %%%%%%%%%%%%%%%%%%%%%%位置更新%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:m
        fun_i=fun(X(i,:),inputnum,hiddennum,outputnum,net,inputn_train,label_train);
           %%%%%%%%%%%%%%%%%局部搜索%%%%%%%%%%%%%%%%%%%%%%
        if P(NC,i)<P0
            temp1=X(i,:)+(rand(1,d))*step*lamda;
           
        else
            %%%%%%%%%%%%%%%%全局搜索%%%%%%%%%%%%%%%%%%%%%%%
             temp1=X(i,:)+(XMAX-XMIN)*(rand(1,d));
        end
        %%%%%%%%%%%%%%%%%%%%%边界处理%%%%%%%%%%%%%%%%%%%%%%%
        for j=1:d
            if temp1(j)<XMIN
                temp1(j)=rand;
            end
            if temp1(j)>XMAX
                temp1(j)=rand;
            end
        end
        fun_temp=fun(temp1,inputnum,hiddennum,outputnum,net,inputn_train,label_train);
        %%%%%%%%%%%%%%%%%%蚂蚁判断是否移动%%%%%%%%%%%%%%%%%%
        if fun_temp<fun_i
            X(i,:)=temp1;
            Tau(i)=fun_temp;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%更新信息素%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:m
        Tau(i)=(1-Rho)*Tau(i)+Tau(i); 
    end
    [value,index]=min(Tau);
    %%
    if value<bestfitness
        bestfitness=value;
        bestfitness_position=X(index,:);
    end
    trace(NC)=bestfitness;  
    
end
y=bestfitness_position;                           %最优变量

