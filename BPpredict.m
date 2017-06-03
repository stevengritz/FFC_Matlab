function [ty]=BPpredict(xt,n,h,m,W)
w=W{1}; b2=W{2}; v=W{3}; b1=W{4};
[R ~]=size(xt);
for I=1:R
    for j=1:h
        zin(j)=b1(j);
        for i=1:n
            zin(j)=zin(j)+xt(I,i)*v(i,j);
        end
        z(j)=bipsig(zin(j));
    end
    for k=1:m
        yin(k)=b2(k);
        for j=1:h
            yin(k)=yin(k)+z(j)*w(j,k);
        end
        y(k)=bipsig(yin(k));
        ty(I,k)=y(k);
    end
end
end
function y=bipsig(x)
y=2/(1+exp(-x))-1;
end
function y=bipsig1(x)
y=1/2*(1-bipsig(x))*(1+bipsig(x));
end