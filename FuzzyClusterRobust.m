% Author: Steven Ritz
% This program is part of the fuzzy neural suite of codes to sort, cluster,
% and predict missile geometery based on data that would be acquired
% through radar. 
%
%   Fuzzy/ANN Suite:
%       -DataManager.m
%       -FuzzyClusterRobust.m*
%       -Max_Alt_Range.m
%       -plotting_things.m
%       -PreNeural.m
%       -RefMissileSort.m
%       -onlineFuzzyClusterRobustVelocity.m
% NOTE: This requires the database 'Classificated_plus.mat' from 
%       DataManager.m to be in current directory 
% clc
% clear all 
% close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the function version of the code to be used for confidence
% interval testing. It will likely be put into the final suite version to
% be implemented into the GUI.
function [F]=FuzzyClusterRobust(m,c,epochs,allRef,refm,database_num)
close all
current_dir=strcat(pwd,sprintf('\\DataSet%i\\',database_num));
load(strcat(current_dir,'Classificated_plus.mat'));

% EXAMPLE
% This program is designed to perform a functional fuzzy cluster
% of missile trajectory data. 
% In this early version, splines were used to estimate 
% trendlines for the central trajectories
%% Method
% Normalize
% Randomly Assign to clusters
% -> Compute distance from all obs to cluster center
% |  update membership values
% -< repeat until desired epochs is met
%% Constants
% Fuzziness parameter
% m=2;
% Number of clusters 
% c=4;
% Number of iterations for clustering
% epochs=40;
% Reference Missile
% allRef=1; % Cycle all of them
% refm=73;

switch allRef
    case 0
        cycledM=refm;
    case 1
        cycledM=[1:1:total];
end
%% File Management
% current_dir=pwd;
number_for_file=num2str(c);
file_path=strcat(current_dir,'\',number_for_file,' Clusters\');
dircheck=isdir(file_path);
if dircheck==0
    mkdir(file_path);
    mkdir(strcat(file_path,'\Trajectories\'));
    mkdir(strcat(file_path,'\Missiles In Clusters\'));
    mkdir(strcat(file_path,'\RMS Plots\'));
    mkdir(strcat(file_path,'\RMS Centers\'));
    mkdir(strcat(file_path,'\Ref Based DBs\'));
end

% progressbar(sprintf('Clustering Data Set %i',database_num))
for refmissile=cycledM
    close all
%% Initialize Membership for all obs
% progressbar([])
for C=1:c
    eval(sprintf('Class%i.membership=zeros(1,total);',C));
end
for i=1:total
    C=rem(i,c);
    if C==0
        C=c;
    end
    eval(sprintf('Class%i.membership(i)=1;',C));
end
%% Reference Frame Calculation
eval(sprintf('ref.alt=spline(missile.m%i.time,missile.m%i.Alt);',refmissile,refmissile));
eval(sprintf('ref.range=spline(missile.m%i.time,missile.m%i.Range);',refmissile,refmissile));
eval(sprintf('ref.vel=spline(missile.m%i.time,missile.m%i.Velocity);',refmissile,refmissile));
%% Coordinate Calculation
% Cycle through missiles, i
for i=1:total    
    Coord.sosAlt=0;
    Coord.sosRange=0;
    Coord.sosVel=0;
          
    eval(sprintf('time=missile.m%i.time;', i));
    eval(sprintf('Alt=missile.m%i.Alt;', i));
    eval(sprintf('Range=missile.m%i.Range;', i));
    eval(sprintf('Vel=missile.m%i.Velocity;', i));
    for t=1:length(time)           
            Coord.sosAlt=(ppval(ref.alt,time(t))-Alt(t))^2+Coord.sosAlt;
            Coord.sosRange=(ppval(ref.range,time(t))-Range(t))^2+...
                Coord.sosRange;
            Coord.sosVel=(ppval(ref.vel,time(t))-Vel(t))^2+Coord.sosVel;                    
    end    
        Coord.RMSAlt(i)=sqrt(Coord.sosAlt)/length(time);
        Coord.RMSRange(i)=sqrt(Coord.sosRange)/length(time);
        Coord.RMSVel(i)=sqrt(Coord.sosVel)/length(time);   
end
for ecount=1:epochs

%% Repeated Center Calculation
for C=1:c
    x1t=0; x2t=0; x3t=0; x1b=0; x2b=0; x3b=0;
    for i=1:total
        eval(sprintf('mum=Class%i.membership(i);',C));
        x1t=x1t+(mum^m*Coord.RMSAlt(i));
        x1b=x1b+(mum^m);
        x2t=x2t+(mum^m*Coord.RMSRange(i));
        x2b=x2b+(mum^m);
        x3t=x3t+(mum^m*Coord.RMSVel(i));
        x3b=x3b+(mum^m);
        
    end
    x1=x1t/x1b;
    x2=x2t/x2b;
    x3=x3t/x3b;
    eval(sprintf('Coord.Class%i=[x1,x2,x3];',C));
end
%% "Distance" Calculations
% Cycle through missiles, i
for i=1:total
    for C=1:c
        eval(sprintf('Class%i.sosX1=0;',C));
        eval(sprintf('Class%i.sosX2=0;',C));
        eval(sprintf('Class%i.sosX3=0;',C));       
    end
    eval(sprintf('time=missile.m%i.time;', i));
    eval(sprintf('Alt=missile.m%i.Alt;', i));
    eval(sprintf('Range=missile.m%i.Range;', i));
    eval(sprintf('Vel=missile.m%i.Velocity;', i));    
    for C=1:c
        eval(sprintf('Altdiff=Coord.Class%i(1)-Coord.RMSAlt(i);',C));
        eval(sprintf('Rangediff=Coord.Class%i(2)-Coord.RMSRange(i);',C));
        eval(sprintf('Veldiff=Coord.Class%i(3)-Coord.RMSVel(i);',C));
        eval(sprintf('Class%i.Distance(i)=sqrt(Altdiff^2+Rangediff^2+Veldiff^2);',C));
    end
end
%% Membership Values

for C=1:c
    eval(sprintf('Class%i.members=[];',C));
end
for i=1:total
    for C=1:c
        eval(sprintf('Class%i.membership(i)=0;',C));
        for CC=1:c
            eval(sprintf(...
'Class%i.membership(i)=Class%i.membership(i)+(Class%i.Distance(i)/Class%i.Distance(i))^(2/(m-1));',C,C,C,CC));
        end
        eval(sprintf('Class%i.membership(i)=Class%i.membership(i)^(-1);',C,C));
    end
    member_check=Class1.membership(i);
    cluster_id=1;
    for C=2:c
        if eval(sprintf('Class%i.membership(i)>member_check',C))
            eval(sprintf('member_check=Class%i.membership(i);',C));
            cluster_id=C;
        end
    end
    j=length(eval(sprintf('Class%i.members;',cluster_id)));
%     eval(sprintf('Class%i.members=[Class%i.members i];',cluster_id,cluster_id));
     eval(sprintf('Class%i.members(j+1)= i;',cluster_id));
end
%% Cleanup
for C=1:c
     eval(sprintf('epoch_center{C,ecount}=Coord.Class%i;',C));
end
% progressbar(ecount/epochs)
end
%% Partition Coef
% F=0;
% for i=1:total
%     for C=1:c
%         eval(sprintf('F=F+Class%i.membership(i)^2/total;',C));
%     end
% end

%% Validation by plot
altlim=0;rangelim=0;vellim=0;
for t=1:epochs
    for i=1:c
        centerplot=epoch_center{i,t};
        if centerplot(1)>altlim
            altlim=centerplot(1);
        end
        if centerplot(2)>rangelim
            rangelim=centerplot(2);
        end 
        if centerplot(3)>vellim
            vellim=centerplot(3);
        end        
    end
end
for C=1:c
    eval(sprintf('allClasses.Class%i=Class%i;',C,C));
end
% [fig_handel,plot_handel]=plotting_things(c,allClasses,Coord,refmissile,file_path);
% plotting_things_str=strcat(pwd,'\plotting_things.m');
% run(plotting_things_str)
% close all
%  Plot Thingsssssssssssssssssssssssssssssssssssss
% colours={'-m' '-c' '-r' '-g' '-b' '-k' '-xr' '-xc' '-xm' '-xg' '-xb' '-xk'};
% for C=1:c
%     if eval(sprintf('sum(Class%i.members)',C))>0
%         for i=1:eval(sprintf('length(Class%i.members)',C))
%             pp=1;
%             timeplot=0;
%             Rangeplot=0;
%             Altplot=0;
%             eval(sprintf('j=Class%i.members(i);',C));
%             eval(sprintf('time=missile.m%i.time;',j));
%             for plotter=1:length(time)
%                 if mod(plotter,10)==0
%                 eval(sprintf('timeplot(pp)=missile.m%i.time(plotter);',j));
%                 eval(sprintf('Rangeplot(pp)=missile.m%i.Range(plotter);',j));
%                 eval(sprintf('Altplot(pp)=missile.m%i.Alt(plotter);',j));
%                 pp=pp+1;
%                 else
%                 end
%             end
%             eval(sprintf('plot3(plot_handel,timeplot,Rangeplot,Altplot,''%s'',''MarkerSize'',4)',colours{C}));
%                 hold on
%         end
%     end
% end
% grid on 
% xlabel('time');ylabel('Range');zlabel('Alt')
% view([60 22]);
% 
% export_fig(strcat(file_path,'\Trajectories\',sprintf('%icluster_%i.pdf',c,refmissile)), '-transparent')  

% progressbar(0,0)
% progressbar(refmissile/total,[])

Membership_file=fopen(strcat(file_path,'\Missiles In Clusters\',sprintf('RefMissile%i.txt',refmissile)),'w');
for i=1:c
    eval(sprintf('allmembers(i)=length(Class%i.members);',i));
    eval(sprintf('themembers=Class%i.members;',i));
    fprintf(Membership_file,'Class %i \r\n',i);
    for b=1:allmembers(i)
        fprintf(Membership_file,'%i  ',themembers(b));
    end
    fprintf(Membership_file,' \r\n');
    
end
F=std(allmembers);
fclose(Membership_file);
save(strcat(file_path,'\Ref Based DBs\',sprintf('Clustered_ref_%i.mat',refmissile)));
end
% close(fig_handel);
end

        