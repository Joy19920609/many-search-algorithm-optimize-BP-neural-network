%% ��ջ�������
clc
clear
close all
format compact 
%% ����ṹ����
%% ��ջ�������
clc
clear
close all
format compact 
%% ����ṹ����
%��ȡ����
data=xlsread('����_����_����.xlsx','C12:J70');%ǰ7��Ϊÿ��ʱ�̵ķ����� �����Ϊ����

for i=1:58
    input(i,:)=[data(i,:) data(i+1,end)];
    output(i,:)=data(i+1,1:7);
end

%% �ڵ����
inputnum=9;%���� ǰһ��7��ʱ�̵ĵ���+ǰһ�������+Ԥ���յ�����
hiddennum=5;
outputnum=7;%Ԥ����7��ʱ�̵ķ�����

%% ѵ�����ݺ�Ԥ������ ���һ����������  ǰ��Ķ�����ѵ��
input_train=input(1:57,:)';
input_test=input(58,:)';
output_train=output(1:57,:)';
output_test=output(58,:)';

%ѡ����������������ݹ�һ��
[inputn,inputps]=mapminmax(input_train);
[outputn,outputps]=mapminmax(output_train);
inputn_test=mapminmax('apply',input_test,inputps);
%%

%��������
net=newff(inputn,outputn,hiddennum);

%Ѱ��
[bestnest,trace]=cuckoo_search_new(inputnum,hiddennum,outputnum,net,inputn,outputn);
figure
plot(trace)
title('��Ӧ������')
xlabel('������')
ylabel('��Ӧ��ֵ')


%% �����ų�ʼ��ֵȨֵ��������Ԥ��
x=bestnest;
% ��CS�Ż���BP�������ֵԤ��
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
%net.trainParam.goal=0.00001;

%����ѵ��
[net,per2]=train(net,inputn,outputn);

%% BP����Ԥ��
%���ݹ�һ��
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
title('2019��3��31�ո�ʱ�̷�����')
xlabel('')
legend('ԭʼ����','bpԤ������')
set(gca,'XTick',1:7,...                                    
        'XTickLabel',{'9:00','10:00','11:00','12:00','13:00','14:00','15:00'},...
        'TickLength',[0 0]);
grid on
ylabel('��������KW��')







