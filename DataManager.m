% Steven Ritz
% Part of the Fuzzy Suite
%
% Reqiures 2 data files as input:
%   -Distribution Performance Data.dat
%   -randlhc.dat


% Data handling for Performance Data genertaed from LHC solutions
clc 
clear all
close all
warning('off','all');

file=fopen('Distribution Performance Data.dat');
i=1;
j=1;
p=1;
while ~feof(file)
    line=fgets(file);
    checkline=isletter(line);
    if checkline(1)==1
        
        if strncmp('ZONE',line,4)
            ppm(j)=str2num(line(8:11));
            j=j+1;
        elseif strncmp('TITLE',line,5)
            mn(p)=str2num(line(16:18));
            p=p+1;
        end
        continue
    else
        data(i,1:9)=str2num(line);
        i=i+1;
    end
    
end
fclose(file);
% Select Feasible Missile Geometry from seed
i=1;
file=fopen('randlhc.dat');
while ~feof(file)
    line=fgets(file);
    checkline=isletter(line);
    if checkline(7)==1
        continue
    else
        missile_geo(i,1:35)=str2num(line);
        i=i+1;
    end
    
end
fclose(file);


cutdata=data(:,1:4);
total=j-1;
k=1;
for i=1:total
    
    for j=1:ppm(i)
        eval(sprintf('missile.m%i.time(%g) = cutdata(%i,1)  ;', i,j,k));
        eval(sprintf('missile.m%i.Alt(%g) = cutdata(%i,2)  ;', i,j,k));
        eval(sprintf('missile.m%i.Range(%g) = cutdata(%i,3)  ;', i,j,k));
        eval(sprintf('missile.m%i.Velocity(%g) = cutdata(%i,4)  ;', i,j,k));
        k=k+1;
    end
    geo=missile_geo(mn(i),:);
    eval(sprintf('missile.m%i.geo = geo  ;', i));
    
    
end

save('Classificated_plus.mat');
% lookin=randi(total,[1,4]);
% lookin=[39 37 56 41];
% lookin=[];
% Class designation from Random selection
% j=1;
% for i=lookin
%     eval(sprintf('class.c%i=missile.m%i  ;', i,i));
%     
%     figure
%     eval(sprintf('plot3(class.c%i.time,class.c%i.Range,class.c%i.Alt)',i,i,i));
%     grid on
%     xlabel('time');ylabel('Range');zlabel('Alt')
% end
