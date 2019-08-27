function [y ,trace]=psoforbp(inputnum,hiddennum,outputnum,inputn_train,label_train,Pn_test,Tn_test)
d=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;%优化bp各层权重与阈值
N=20;                  %群体粒子个数
D=d;                   %粒子维数
T=100;                  %最大迭代次数
c1=1.5;                 %学习因子1
c2=1.5;                 %学习因子2
w=0.8;                  %惯性权重

Xmax=1;                %位置最大值
Xmin=-1;               %位置最小值
Vmax=1;                %速度最大值
Vmin=0;               %速度最小值
%%
%%%%%%%%%%%%%%%%初始化种群个体（限定位置和速度）%%%%%%%%%%%%%%%%
x=rand(N,D) * (Xmax-Xmin)+Xmin;
v=rand(N,D) * (Vmax-Vmin)+Vmin;
%%%%%%%%%%%%%%%%%%初始化个体最优位置和最优值%%%%%%%%%%%%%%%%%%%
p=x;
pbest=ones(N,1);
for i=1:N
    pbest(i)=fun1(x(i,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test); 
end
%%%%%%%%%%%%%%%%%%%初始化全局最优位置和最优值%%%%%%%%%%%%%%%%%%
g=ones(1,D);
gbest=inf;
for i=1:N
    if(pbest(i)<gbest)
        g=p(i,:);
        gbest=pbest(i);
    end
end
%%%%%%%%%%%按照公式依次迭代直到满足精度或者迭代次数%%%%%%%%%%%%%
for i=1:T
    i
    for j=1:N
        %%%%%%%%%%%%%%更新个体最优位置和最优值%%%%%%%%%%%%%%%%%
        if (fun1(x(j,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test)) <pbest(j)
            p(j,:)=x(j,:);
            pbest(j)=fun1(x(j,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test); 
        end
        %%%%%%%%%%%%%%%%更新全局最优位置和最优值%%%%%%%%%%%%%%%
        if(pbest(j)<gbest)
            g=p(j,:);
            gbest=pbest(j);
        end
        %%%%%%%%%%%%%%%%%跟新位置和速度值%%%%%%%%%%%%%%%%%%%%%
        v(j,:)=w*v(j,:)+c1*rand*(p(j,:)-x(j,:))...
            +c2*rand*(g-x(j,:));
        x(j,:)=x(j,:)+v(j,:);
        %%%%%%%%%%%%%%%%%%%%边界条件处理%%%%%%%%%%%%%%%%%%%%%%
        for ii=1:D
            if (v(j,ii)>Vmax)  |  (v(j,ii)< Vmin)
                v(j,ii)=rand * (Vmax-Vmin)+Vmin;
            end
            if (x(j,ii)>Xmax)  |  (x(j,ii)< Xmin)
                x(j,ii)=rand * (Xmax-Xmin)+Xmin;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%记录历代全局最优值%%%%%%%%%%%%%%%%%%%%%
    gb(i,1)=gbest;%记录训练集的适应度值
    gb(i,2)=fun1(g,inputnum,hiddennum,outputnum,inputn_train,label_train);%记录测试集的适应度值

end
trace=gb;
y=g;
end