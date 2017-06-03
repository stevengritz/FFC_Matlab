% Steven Ritz
% BackProp ANN Function
% See "Fundamentals of Neural Networks: Architectures, Algorithms, and
% Applications" for reference and notation
function [W]=BPANN(x,t,n,h,m,alpha,et,maxepoch)
%   Variable description
%       -x: Input for training set
%       -t: Output for training set
%       -n: input neurons
%       -h: hidden neurons
%       -m: output neurons 

% progressbar('Epoch Completion')
% RandStream.setDefaultStream(RandStream('mcg16807','Seed',8));
%Initialize weights and bias
v=rand(n,h)-0.5;
v1=zeros(n,h);
b1=rand(1,h)-0.5;
b2=rand(1,m)-0.5;
w=rand(h,m)-0.5;
w1=zeros(h,m);
%Learning rate (Between 0 and 1)
% alpha=0.5;
%Momentum Factor (Between 0 and 1)
mf=0.3;
%Tolerance (see page 303 for description)
% tolerance = 0.9;
%Error Tolerance (If error is less than this number it stops training)
% et = 0.05;
%Max Number of Epochs (If max number of epochs reached it stops training)
% maxepoch = 2000;
con=1;
epoch=0;
while con
%     progressbar(epoch/maxepoch)
    e=0;
    for I=1:length(x)
        %Feed forward
        for j=1:h
            zin(j)=b1(j);
            for i=1:n
                zin(j)=zin(j)+x(I,i)*v(i,j);
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
        %Backpropagation of Error
        for k=1:m
            delk(k)=(t(I,k)-y(k))*bipsig1(yin(k));
        end
        for j=1:h
            for k=1:m
        			delw(j,k)=alpha*delk(k)*z(j)+mf*(w(j,k)-w1(j,k));
         			delinj(j)=delk(k)*w(j,k);
            end
        end
        delb2=alpha*delk;        
        for j=1:h
            delj(j)=delinj(j)*bipsig1(zin(j));
        end
        for j=1:h
            for i=1:n
                delv(i,j)=alpha*delj(j)*x(I,i)+mf*(v(i,j)-v1(i,j));
            end
        end
        delb1=alpha*delj;
        w1=w;
        v1=v;
        %Weight updates
        w=w+delw;
        b2=b2+delb2;
        v=v+delv;
        b1=b1+delb1;
        for k=1:k
            e=e+(t(I,k)-y(k))^2;
        end
    end
    if e<et
        con=0;
    end
    epoch=epoch+1;
    if epoch==maxepoch
        con=0;
    end
    xl(epoch)=epoch;
    yl(epoch)=e;
    
end
% step=3.1/99;
% xt=0:step:3.1;
% xt=xt';
% Addition of noise
% for i=1:100
%     xt(i)=xt(i)+randn(1)*.1;
% end
W={w,b2,v,b1};
%Output of Net after training
% for I=1:length(xt)
%     for j=1:h
%         zin(j)=b1(j);
%         for i=1:n
%             zin(j)=zin(j)+xt(I,i)*v(i,j);
%         end
%         z(j)=bipsig(zin(j));
%     end
%     for k=1:m
%         yin(k)=b2(k);
%         for j=1:h
%             yin(k)=yin(k)+z(j)*w(j,k);
%         end
%         y(k)=bipsig(yin(k));
%         ty(I,k)=y(k);
%     end
% end
end
function y=bipsig(x)
y=2/(1+exp(-x))-1;
end
function y=bipsig1(x)
y=1/2*(1-bipsig(x))*(1+bipsig(x));
end