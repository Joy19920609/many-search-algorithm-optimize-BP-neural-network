function [y,trace]=antforelm(inputnum,hiddennum,outputnum,net,inputn_train,label_train);%��Ⱥ�㷨%%%%%%%%%%%%%%%%%%%%��Ⱥ�㷨������ֵ%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%��ʼ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m=5;                    %���ϸ���
G_max=100;               %����������
Rho=0.5;                 %��Ϣ������ϵ��
P0=0.5;                  %ת�Ƹ��ʳ���
XMAX= 1;                 %��������x���ֵ
XMIN=-1;                %��������x��Сֵ
d=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;    
%%%%%%%%%%%%%%%%%����������ϳ�ʼλ��%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
    X(i,:)=(XMIN+(XMAX-XMIN).*rand(1,d));
    Tau(i)=fun(X(i,:),inputnum,hiddennum,outputnum,net,inputn_train,label_train); 
end

bestfitness=inf;
bestfitness_position=inf*ones(1,d);

step=0.1;                %�ֲ���������
for NC=1:G_max
    NC
    lamda=1/NC;
    [Tau_best,BestIndex]=min(Tau);
    %%%%%%%%%%%%%%%%%%����״̬ת�Ƹ���%%%%%%%%%%%%%%%%%%%%
    for i=1:m
        P(NC,i)=(Tau(BestIndex)-Tau(i))/Tau(BestIndex);
    end
    %%%%%%%%%%%%%%%%%%%%%%λ�ø���%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:m
        fun_i=fun(X(i,:),inputnum,hiddennum,outputnum,net,inputn_train,label_train);
           %%%%%%%%%%%%%%%%%�ֲ�����%%%%%%%%%%%%%%%%%%%%%%
        if P(NC,i)<P0
            temp1=X(i,:)+(rand(1,d))*step*lamda;
           
        else
            %%%%%%%%%%%%%%%%ȫ������%%%%%%%%%%%%%%%%%%%%%%%
             temp1=X(i,:)+(XMAX-XMIN)*(rand(1,d));
        end
        %%%%%%%%%%%%%%%%%%%%%�߽紦��%%%%%%%%%%%%%%%%%%%%%%%
        for j=1:d
            if temp1(j)<XMIN
                temp1(j)=rand;
            end
            if temp1(j)>XMAX
                temp1(j)=rand;
            end
        end
        fun_temp=fun(temp1,inputnum,hiddennum,outputnum,net,inputn_train,label_train);
        %%%%%%%%%%%%%%%%%%�����ж��Ƿ��ƶ�%%%%%%%%%%%%%%%%%%
        if fun_temp<fun_i
            X(i,:)=temp1;
            Tau(i)=fun_temp;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%������Ϣ��%%%%%%%%%%%%%%%%%%%%%%%
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
y=bestfitness_position;                           %���ű���

