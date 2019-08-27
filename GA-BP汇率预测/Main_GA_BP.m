%% �����Ŵ��㷨�Ż�BP������Ļ���Ԥ��
clear all
clc
close all
warning off
%% ��������---���Ѿ������ݴ�csv�ļ��и��Ƶ�����.xlsx���ˡ���һ���Ƿ��� ����������,matlab����csv�ļ����鷳��  һ�㶼����Ū��excel�ļ�
% data0=importdata('����.xlsx');
data0=xlsread('����.xlsx');

data0=data0(1:1000,:);%��2��������  ȡ1000�����  ����Ҫ��������2����Ļ� ���԰�������ע�͵�--����ǰ��Ӹ� % ����
% ɸѡ����Ҫ������
input=data0(:,2:end);
output=data0(:,1);
% 1-18�������ֱ�Ϊ��bedrooms	bathrooms	sqft_living	sqft_lot	floors	waterfront	view	condition	grade	sqft_above	sqft_basement	yr_built	yr_renovated	zipcode	lat	long	sqft_living15	sqft_lot15

n=[2 3 6 7 9 10 15 17];
%��Ҫ�����ǰ���Щ���������˷���ģ�
%���Կ�����Ҫ��Ӱ��������grade��view ��waterfront(���ݵ�������
%���ݵĿռ䣨sqft_living���������sqft_living1515����������
%bathroomsԡ����Ŀ,sqft_above����Ȼ����ܻ�����Ҫ���Ƿ���λ�õ�Ӱ�죨lat)@������Ա 

%%��Ӧ����Щ������
input=input(:,n);


%ѵ��������800������
tr_len=800;
input_train = input(1:tr_len, :)';
output_train = output(1:tr_len)';
%���Լ�����200������
input_test = input(tr_len+1:end, :)';
output_test = output(tr_len+1:end)';

%% BP��������
%�ڵ����
[inputnum,N]=size(input_train);%����ڵ�����
outputnum=size(output_train,1);%����ڵ�����
hiddennum=10;
%ѡ����������������ݹ�һ��
[inputn,inputps]=mapminmax(input_train,0,1);
[outputn, outputps]=mapminmax(output_train,0,1);% ��һ������0 1��֮��

%��������
net=newff(inputn,outputn,hiddennum);
%�����������
net.trainParam.epochs=100;
net.trainParam.lr=0.1;
net.trainParam.mc = 0.8;%����ϵ����[0 1]֮��
net.trainParam.goal=0.001;
%����ѵ��
%����ѵ��
net=train(net,inputn,outputn);
%% BPѵ����Ԥ��
BP_sim=sim(net,inputn);
%�����������һ��
T_sim=mapminmax('reverse',BP_sim,outputps);
% 
 figure
 plot(1:length(output_train),output_train,'b-','linewidth',1)
 hold on
 plot(1:length(T_sim),T_sim,'r-.','linewidth',1)
 axis tight
 xlabel('ѵ������','FontSize',12);
 ylabel('����','FontSize',12);
 legend('ʵ��ֵ','Ԥ��ֵ');
 string={'BPԤ��'};
 title(string);
%% �������ݹ�һ��
  inputn_test=mapminmax('apply',input_test,inputps);
% %Ԥ�����
  an=sim(net,inputn_test);
  BPsim=mapminmax('reverse',an,outputps);
 figure
 plot(1:length(output_test), output_test,'b-','linewidth',1)
 hold on
 plot(1:length(BPsim),BPsim,'r-.','linewidth',1)
 xlabel('��������','FontSize',12);
 ylabel('����','FontSize',12);
 axis tight
 legend('ʵ��ֵ','Ԥ��ֵ');
  string={'BPԤ��'};
 title(string);

% % ����
ae= abs(BPsim - output_test);
rmse = (mean(ae.^2)).^0.5;
mae = mean(ae);
mape = mean(100*ae./BPsim);

disp('�Ż�ǰԤ��������ָ�꣺')
disp(['RMSE = ', num2str(rmse)])
disp(['MAE  = ', num2str(mae)])
disp(['MAPE = ', num2str(mape)])


%% GA�㷨������ʼ��
nvar=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;

%% �Ŵ��㷨������ʼ��
maxgen=100;                         %��������������������
sizepop=10;                        %��Ⱥ��ģ
pcross=0.8;                       %�������ѡ��0��1֮��
pmutation=0.1;                    %�������ѡ��0��1֮��

lenchrom=ones(1,nvar);        %���峤��   
bound=[-1*ones(nvar,1) 1*ones(nvar,1)];  %���巶Χ


%------------------------------------------------------��Ⱥ��ʼ��--------------------------------------------------------
individuals=struct('fitness',zeros(1,sizepop), 'chrom',[]);  %����Ⱥ��Ϣ����Ϊһ���ṹ��
avgfitness=[];                      %ÿһ����Ⱥ��ƽ����Ӧ��
bestfitness=[];                     %ÿһ����Ⱥ�������Ӧ��
bestchrom=[];                       %��Ӧ����õ�Ⱦɫ��
%��ʼ����Ⱥ
for i=1:sizepop
    %�������һ����Ⱥ
    individuals.chrom(i,:)=Code(lenchrom,bound);    %���루binary��grey�ı�����Ϊһ��ʵ����float�ı�����Ϊһ��ʵ��������
    x=individuals.chrom(i,:);
    %������Ӧ��
    individuals.fitness(i)=objfun_BP(x,inputnum,hiddennum,outputnum,net,inputn,outputn);

end

%����õ�Ⱦɫ��
[bestfitness bestindex]=min(individuals.fitness);  %[m n]=min(b) m��Сֵ n�к�
bestchrom=individuals.chrom(bestindex,:);  %��õ�Ⱦɫ��
avgfitness=sum(individuals.fitness)/sizepop; %Ⱦɫ���ƽ����Ӧ��
% ��¼ÿһ����������õ���Ӧ�Ⱥ�ƽ����Ӧ��
trace=[avgfitness bestfitness]; 
 
%% ���������ѳ�ʼ��ֵ��Ȩֵ
% ������ʼ
start_time_train=cputime;
for i=1:maxgen
  %  i
    % ѡ��
    individuals=Select(individuals,sizepop); 
    avgfitness=sum(individuals.fitness)/sizepop;
    %����
    individuals.chrom=Cross(pcross,lenchrom,individuals.chrom,sizepop,bound);
    % ����
    individuals.chrom=Mutation(pmutation,lenchrom,individuals.chrom,sizepop,i,maxgen,bound);
    
    % ������Ӧ�� 
    for j=1:sizepop
        x=individuals.chrom(j,:); %����
        individuals.fitness(j)=objfun_BP(x,inputnum,hiddennum,outputnum,net,inputn,outputn);
    end
    
  %�ҵ���С�������Ӧ�ȵ�Ⱦɫ�弰��������Ⱥ�е�λ��
    [newbestfitness,newbestindex]=min(individuals.fitness);
    [worestfitness,worestindex]=max(individuals.fitness);
    % ������һ�ν�������õ�Ⱦɫ��
    if bestfitness>newbestfitness
        bestfitness=newbestfitness;
        bestchrom=individuals.chrom(newbestindex,:);
    end
    individuals.chrom(worestindex,:)=bestchrom;
    individuals.fitness(worestindex)=bestfitness;
    
    avgfitness=sum(individuals.fitness)/sizepop;
    
    trace=[trace;avgfitness bestfitness]; %��¼ÿһ����������õ���Ӧ�Ⱥ�ƽ����Ӧ��

end
%% �Ŵ��㷨������� 
figure
plot(trace(:,2),'b-*','linewidth',2)
xlabel('��������')
ylabel('��Ӧ��')
%legend('ƽ����Ӧ��','�����Ӧ��')
grid on
x=bestchrom;
%% �����ų�ʼ��ֵȨֵ��������Ԥ��
% %���Ŵ��㷨�Ż���BP�������ֵԤ��
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2;

%% BP����ѵ��
%�����������
net.trainParam.epochs=100;
net.trainParam.lr=0.1;
net.trainParam.mc = 0.8;%����ϵ����[0 1]֮��
net.trainParam.goal=0.001;
%����ѵ��
net=train(net,inputn,outputn);
%% BPѵ����Ԥ��
BP_sim=sim(net,inputn);
%�����������һ��
T_sim=mapminmax('reverse',BP_sim,outputps);
% 
 figure
 plot(1:length(output_train),output_train,'b-','linewidth',1)
 hold on
 plot(1:length(T_sim),T_sim,'r-.','linewidth',1)
 axis tight
 xlabel('ѵ������','FontSize',12);
 ylabel('����','FontSize',12);
 legend('ʵ��ֵ','Ԥ��ֵ');
 string={'GA-BPԤ��'};
 title(string);
%% �������ݹ�һ��
  inputn_test=mapminmax('apply',input_test,inputps);
% %Ԥ�����
  an=sim(net,inputn_test);
  BPsim=mapminmax('reverse',an,outputps);
 figure
 plot(1:length(output_test), output_test,'b-','linewidth',1)
 hold on
 plot(1:length(BPsim),BPsim,'r-.','linewidth',1)
 xlabel('��������','FontSize',12);
 ylabel('����','FontSize',12);
 axis tight
 legend('ʵ��ֵ','Ԥ��ֵ');
  string={'GA-BPԤ��'};
 title(string);

% % ����
ae= abs(BPsim - output_test);
rmse = (mean(ae.^2)).^0.5;
mae = mean(ae);
mape = mean(100*ae./BPsim);

disp('�Ż���Ԥ��������ָ�꣺')
disp(['RMSE = ', num2str(rmse)])
disp(['MAE  = ', num2str(mae)])
disp(['MAPE = ', num2str(mape)])
