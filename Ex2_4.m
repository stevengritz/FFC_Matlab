% Steven Ritz
% Example 2.4 Plots
% 03/9/12
clc
clear all
close all

x0=0;
v0=50; %cm/s
time=10;%seconds run out to

% Case 1
wn1=4;%rad/s
xi1=[.05 .1 .2];
l=length(xi1);
j=1;
for i=1:l
    C(i)=sqrt(x0^2+((xi1(i)*wn1*x0+v0)/(sqrt(1-xi1(i)^2)*wn1))^2);
    phi(i)=atan((xi1(i)*wn1*x0+v0)/((1/(2*pi))*sqrt(1-xi1(i)^2)*wn1*x0));
    for t=0:.05:time
        x1(i,j)=C(i)*exp(-xi1(i)*wn1*t)*cos(sqrt(1-xi1(i)^2)*wn1*t-phi(i));
        d(i,j)=C(i)*exp(-xi1(i)*wn1*t);
        e(i,j)=-d(i,j);
        j=j+1;
    end
    j=1;
end

t=0:.05:time;
junk=zeros(length(t));
plot(t,x1(1,:),'k')
hold on
plot(t,x1(2,:),'-k')
hold on
plot(t,x1(3,:),':k')
hold on
plot(t,d(1,:),'-.k')
hold on
plot(t,e(1,:),'-.k')
hold on
plot(t,junk,'k')
xlabel('Time, sec.');ylabel('Vertical displacement, cm');
legend('\zeta=.05','\zeta=.1','\zeta=.2');title('Steven Ritz')

% Case 2
wn2=4;%rad/s
xi2=[1.2 1.6 2.0];
l=length(xi2);
j=1;
time=4;%seconds run out to
j=1;
for i=1:l
    K(i)=(xi2(i)*wn2*x0+v0)/(sqrt(xi2(i)^2-1)*wn2);
    for t=0:.05:time
        x2(i,j)=exp(-xi2(i)*wn2*t)*(K(i)*sinh(sqrt(xi2(i)^2-1)*...
            wn2*t)+x0*cosh(sqrt(xi2(i)^2-1)*wn2*t));
        j=j+1;
    end
    j=1;
end

t=0:.05:time;
figure
plot(t,x2(1,:),'k')
hold on
plot(t,x2(2,:),'-k')
hold on
plot(t,x2(3,:),':k')
xlabel('Time, sec.');ylabel('Vertical displacement, cm');
legend('\zeta=1.2','\zeta=1.6','\zeta=2.0');title('Steven Ritz')

% Case 3
wn3=4;%rad/s
xi3=1;
l=length(xi3);
j=1;
for t=0:.05:time
    x3(j)=(x0+(wn3*wn3+v0)*t)*exp(-wn3*t);
    j=j+1;
end

t=0:.05:time;
figure
plot(t,x3(1,:),'k')
xlabel('Time, sec.');ylabel('Vertical displacement, cm');
legend('\zeta=1');title('Steven Ritz')