% Steven Ritz
% Vibrations Lab Problems
% 03/7/2012

clc
close all
clear all

wn=6.21; %rad/s
m=25.9; %lbf-s^2/in

% Problem 1
syms z
zeta=solve('20*exp(-z*6.21*1.011)*cos(sqrt(1-z^2)*6.21*1.011)-16.4493',z);
c1=zeta*2*m*wn;
c1=double(c1);
fprintf('Answers to various approaches:\nProblem 1 \n')
fprintf('Damping coefficient is: %5.3f lb/s/in \n\n',c1)
clear z 

% Problem 2
syms z
zeta=solve('20*exp(-z*6.21*7.085)*cos(sqrt(1-z^2)*6.21*7.085)-5.0991',z);
c2=zeta*2*m*wn;
c2=double(c2);
fprintf('Problem 2 \n')
fprintf('Damping coefficient is: %5.3f lb/s/in \n\n',c2)

% Problem 3
% From Excel, equation for Least Squares is y=-0.1929x+2.9952
delta = 0.1928;

zeta=delta/(sqrt((2*pi)^2+delta^2));
zeta=double(zeta);
fprintf('Problem 3 \n')
fprintf('Damping ratio is: %5.3f\n',zeta)
c3=zeta*2*m*wn;
fprintf('Damping coefficient is: %5.3f lb/s/in \n',c3)
