function y=boundary(x);
[m n]=size(x);
for i=1:m
    for j=1:n
    if x(i,j)>=1
        x(i,j)=rand;
    elseif x(i,j)<=0
        x(i,j)=rand;
    end
end
y=x;

end%���۸����㷨�Ż���ȼ���ѧϰ������392503054