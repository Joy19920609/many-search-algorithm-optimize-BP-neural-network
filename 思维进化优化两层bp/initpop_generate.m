function initpop = initpop_generate(popsize,S1,S2,S3,S4,P,T,Pt,Tt)
% ���볤�ȣ�Ȩֵ/��ֵ�ܸ�����
S = S1*S2 + S2*S3 + S3*S4+S2 + S3+S4;

% Ԥ�����ʼ��Ⱥ����
initpop = zeros(popsize,S+1);

for i = 1:popsize
    % �������һ������[-1,1]
    x = rand(1,S)*2 - 1;
    
    % ǰS1*S2������ΪW1����������һ���������Ȩֵ��
    temp = x(1:S1*S2);
    W1 = reshape(temp,S2,S1);
    
    % ���ŵ�S2*S3������ΪW2����������ڶ��������Ȩֵ��
    temp = x(S1*S2+1:S1*S2+S2*S3);
    W2 = reshape(temp,S3,S2);
    
    % ���ŵ�S3*S4������ΪW3����������ڶ��������Ȩֵ��
    temp = x(S1*S2+S2*S3+1:S1*S2+S2*S3+S3*S4);
    W3 = reshape(temp,S4,S3);
    
    % ���ŵ�S2������ΪB1����һ��������Ԫ��ֵ��
    temp = x(S1*S2+S2*S3+S3*S4+1:S1*S2+S2*S3+S3*S4+S2);
    B1 = reshape(temp,S2,1);
    % ���ŵ�S3������ΪB2����2��������Ԫ��ֵ��
    temp = x(S1*S2+S2*S3+S3*S4+S2+1:S1*S2+S2*S3+S3*S4+S2+S3);
    B2 = reshape(temp,S3,1);
    %���ŵ�S4������B3���������Ԫ��ֵ��
    temp = x(S1*S2+S2*S3+S3*S4+S2+S3+1:end);
    B3 = reshape(temp,S4,1);
  
net=newff(P,T,[S2 S3]);
net.trainParam.showWindow=0;
net.trainParam.epochs=20;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;
net.trainParam.show=1;
% ��Ѱ�ŵ�ֵ����˫����BP����
net.iw{1,1}=W1;
net.lw{2,1}=W2;
net.lw{3,2}=W3;
net.b{1}=B1;
net.b{2}=B2;
net.b{3}=B3;
%����ѵ��
net=train(net,P,T);
an=sim(net,Pt);
error=mse(an-Tt);
    % ˼ά�����㷨�ĵ÷�
    val = error;
    % ������÷ֺϲ�
    initpop(i,:) = [x val];
end