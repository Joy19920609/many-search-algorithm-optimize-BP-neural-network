function error = fun1(x,inputnum,hiddennum,outputnum,inputn,outputn)
%�ú�������������Ӧ��ֵ
%x          input     ����
%inputnum   input     �����ڵ���
%outputnum  input     �����ڵ���
%net        input     ����
%inputn     input     ѵ����������
%outputn    input     ѵ���������
%error      output    ������Ӧ��ֵ
%��ȡ
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);
net=newff(inputn,outputn,hiddennum);
%�����������
net.trainParam.epochs=200;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.showWindow=0;
net.trainParam.max_fail = 200;
%����Ȩֵ��ֵ
net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';
%����ѵ��
% net=train(net,inputn,outputn);
an=sim(net,inputn);
error=mse(an-outputn);%�Ծ�������Ϊ��Ӧ�Ⱥ���
