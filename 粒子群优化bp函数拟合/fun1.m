function error = fun1(x,inputnum,hiddennum,outputnum,inputn,outputn)
%该函数用来计算适应度值
%x          input     个体
%inputnum   input     输入层节点数
%outputnum  input     输出层节点数
%net        input     网络
%inputn     input     训练输入数据
%outputn    input     训练输出数据
%error      output    个体适应度值
%提取
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);
net=newff(inputn,outputn,hiddennum);
%网络进化参数
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.showWindow=0;
net.trainParam.max_fail = 200;
%网络权值赋值
net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';
%网络训练
% net=train(net,inputn,outputn);
an=sim(net,inputn);
error=mse(an-outputn);%以均方差作为适应度函数
