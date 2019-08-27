function subpop = subpop_generate(center,SG,S1,S2,S3,S4,P,T,Pt,Tt)

% 编码长度（权值/阈值总个数）
S = S1*S2 + S2*S3 + S3*S4+S2 + S3+S4;

% 预分配初始种群数组
subpop = zeros(SG,S+1);
subpop(1,:) = center;

for i = 2:SG
    x = center(1:S) + 0.2*(rand(1,S)*2 - 1);%以center周围的[-0.2 0.2]为范围，找出SG个子群体
    
    % 前S1*S2个编码为W1(输入层与隐含层间权值)
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
    temp = x(S1*S2+S2*S3+S3*S4+S2+S3+1:end);
    B3 = reshape(temp,S4,1);
net=newff(P,T,[S2 S3]);
net.trainParam.showWindow=0;
net.trainParam.epochs=20;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;
net.trainParam.show=1;
% 将寻优的值赋给双隐层BP网络
net.iw{1,1}=W1;
net.lw{2,1}=W2;
net.lw{3,2}=W3;
net.b{1}=B1;
net.b{2}=B2;
net.b{3}=B3;
%网络训练
net=train(net,P,T);
an=sim(net,Pt);
error=mse(an-Tt);
    % 思维进化算法的得分
    val = error;
    % 个体与得分合并
    subpop(i,:) = [x val];
end
