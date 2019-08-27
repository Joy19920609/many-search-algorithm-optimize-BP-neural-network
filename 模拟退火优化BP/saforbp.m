function [h,trace]=saforbp(inputnum,hiddennum,outputnum,inputn_train,label_train,net)
%% �����趨  
%%%��ȴ�����%%%%%%%%%%
L=10;      %����Ʒ�������
K=0.9;    %˥������
S=0.01;     %��������
T=100;      %��ʼ�¶�
P=0;        %Metroppolis�������ܽ��ܵ�
max_iter=100;%����˻����                  
%% �������10����ʼֵ������10����ֵ�в���1���������Ž�
Xs=1;
Xx=0;
pop=20;
D=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;
Prex=(rand(D,pop)*(Xs-Xx)+Xx);
for i=1:pop
   funt(i)=fun(Prex(:,i)',inputnum,hiddennum,outputnum,inputn_train,label_train,net); 
end
[sort_val,index_val] = sort(funt,'descend');
Prebestx=Prex(:,index_val(end));
Prex=Prex(:,index_val(end-1));
Bestx=Prex;
bestfit=zeros(1,max_iter);
%ÿ����һ���˻�һ��(����)��ֱ�������������Ϊֹ
for iter=1:max_iter
    iter
    T=K*T;%�ڵ�ǰ�¶�T�µ�������
    for i=1:L
        %�ڸ������ѡ��һ��
        Nextx=Prex+S*(rand(D,1)*(Xs-Xx)+Xx);
        %�߽���������
        for ii=1:D
            if Nextx(ii)>Xs | Nextx(ii)<Xx
                Nextx(ii)=rand*(Xs-Xx)+Xx;
            end
        end
        %%�Ƿ�ȫ�����Ž�
        a=fun(Bestx',inputnum,hiddennum,outputnum,inputn_train,label_train,net); 
        b=fun(Nextx',inputnum,hiddennum,outputnum,inputn_train,label_train,net); 
        if a<b
           prebest=a;
           Prebestx=Bestx;%������һ�����Ž�
           Bestx=Nextx;%�������Ž�
           a=b;
        end%����½���ã����½�������Ž⣬ԭ���Ž��Ϊǰ���Ž�
%%%%%%%%%%%%Metropolis����
        c=fun(Prex',inputnum,hiddennum,outputnum,inputn_train,label_train,net); 
        if c<b 
            %%%�����½�
            Prex=Nextx;
            P=P+1;
        else
            changer=-1*(b-c)/T;
            p1=exp(changer);
            %%%��һ�����ʽ��ܽϲ�Ľ�
            if p1>rand
                Prex=Nextx;
                P=P+1;
            end
        end
       trace(P+1)=a;    
    end
end
h=Bestx';
end
%
