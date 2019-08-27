%% ��ջ������� ģ���˻��Ż��Ż�BP
clc
clear
close all
format compact
%% ��ȡ����  
data= xlsread('����.xlsx','sheet4','B2:Q22');
input=data(:,1:end-1);


label=data(:,end)+1;
for i=1:length(label)
    output(i,label(i))=1;
end
%% ѡ����Լ���ѵ���� ���ѡ��15����Ϊѵ������   ʣ�µ�����Ϊ��������
rand('seed',0)
[m n]=sort(rand(1,size(input,1)));
m=15;
input_train=input(n(1:m),:)';
input_test=input(n(m+1:end),:)';
outputn=output(n(1:m),:)';
output_test=output(n(m+1:end),:)';
%��һ��
[inputn,inputps]=mapminmax(input_train);
inputn_test=mapminmax('apply',input_test,inputps);
%% û�Ż���BP
%% �ڵ����
inputnum=size(input,2);%���� ǰһ��7��ʱ�̵ĵ���+ǰһ�������+Ԥ���յ�����
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
title('û���Ż���BP')
legend('�������','ʵ�����')
xlabel('������')
ylabel('����ǩ')
%% ����ģ���˻��㷨��BP����·��Ȩֵ����ֵ�����Ż�
[bestchrom,trace]=saforbp(inputnum,hiddennum,outputnum,inputn,outputn,net);%ģ���˻�

%% �Ż���������
figure
plot(trace,'b--');
title('��Ӧ������ͼ')
xlabel('��������');ylabel('��Ӧ��ֵ');
x=bestchrom;
%% �����ų�ʼ��ֵȨֵ����BP����ѵ����Ԥ��
% ���Ż���BP�������ֵԤ��
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
net.trainParam.goal=0.00001;
% ����ѵ��
[net,per2]=train(net,inputn,outputn);

%% BP����Ԥ��
%���ݹ�һ��
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
title('�Ż����BP')
legend('�������','ʵ�����')
xlabel('������')
ylabel('����ǩ')
%%
disp('�Ż�ǰ���Լ�������ȷ��')
test_accuracy
disp('�Ż�����Լ�������ȷ��')
youhua_test_accuracy

