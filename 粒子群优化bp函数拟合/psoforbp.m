function [y ,trace]=psoforbp(inputnum,hiddennum,outputnum,inputn_train,label_train,Pn_test,Tn_test)
d=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;%�Ż�bp����Ȩ������ֵ
N=20;                  %Ⱥ�����Ӹ���
D=d;                   %����ά��
T=100;                  %����������
c1=1.5;                 %ѧϰ����1
c2=1.5;                 %ѧϰ����2
w=0.8;                  %����Ȩ��

Xmax=1;                %λ�����ֵ
Xmin=-1;               %λ����Сֵ
Vmax=1;                %�ٶ����ֵ
Vmin=0;               %�ٶ���Сֵ
%%
%%%%%%%%%%%%%%%%��ʼ����Ⱥ���壨�޶�λ�ú��ٶȣ�%%%%%%%%%%%%%%%%
x=rand(N,D) * (Xmax-Xmin)+Xmin;
v=rand(N,D) * (Vmax-Vmin)+Vmin;
%%%%%%%%%%%%%%%%%%��ʼ����������λ�ú�����ֵ%%%%%%%%%%%%%%%%%%%
p=x;
pbest=ones(N,1);
for i=1:N
    pbest(i)=fun1(x(i,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test); 
end
%%%%%%%%%%%%%%%%%%%��ʼ��ȫ������λ�ú�����ֵ%%%%%%%%%%%%%%%%%%
g=ones(1,D);
gbest=inf;
for i=1:N
    if(pbest(i)<gbest)
        g=p(i,:);
        gbest=pbest(i);
    end
end
%%%%%%%%%%%���չ�ʽ���ε���ֱ�����㾫�Ȼ��ߵ�������%%%%%%%%%%%%%
for i=1:T
    i
    for j=1:N
        %%%%%%%%%%%%%%���¸�������λ�ú�����ֵ%%%%%%%%%%%%%%%%%
        if (fun1(x(j,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test)) <pbest(j)
            p(j,:)=x(j,:);
            pbest(j)=fun1(x(j,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test); 
        end
        %%%%%%%%%%%%%%%%����ȫ������λ�ú�����ֵ%%%%%%%%%%%%%%%
        if(pbest(j)<gbest)
            g=p(j,:);
            gbest=pbest(j);
        end
        %%%%%%%%%%%%%%%%%����λ�ú��ٶ�ֵ%%%%%%%%%%%%%%%%%%%%%
        v(j,:)=w*v(j,:)+c1*rand*(p(j,:)-x(j,:))...
            +c2*rand*(g-x(j,:));
        x(j,:)=x(j,:)+v(j,:);
        %%%%%%%%%%%%%%%%%%%%�߽���������%%%%%%%%%%%%%%%%%%%%%%
        for ii=1:D
            if (v(j,ii)>Vmax)  |  (v(j,ii)< Vmin)
                v(j,ii)=rand * (Vmax-Vmin)+Vmin;
            end
            if (x(j,ii)>Xmax)  |  (x(j,ii)< Xmin)
                x(j,ii)=rand * (Xmax-Xmin)+Xmin;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%��¼����ȫ������ֵ%%%%%%%%%%%%%%%%%%%%%
    gb(i,1)=gbest;%��¼ѵ��������Ӧ��ֵ
    gb(i,2)=fun1(g,inputnum,hiddennum,outputnum,inputn_train,label_train);%��¼���Լ�����Ӧ��ֵ

end
trace=gb;
y=g;
end