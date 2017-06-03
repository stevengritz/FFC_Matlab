% Fuzzy Cluster? FUZZY CLUSTER
% This type of cluster is an online clustering, providing real-time results
% to the cluster assignment as time progresses
% NOTE: This requires the database 'Clustered.mat' to be loaded
% clc
clear all 
close all
load('Clustered.mat');
progressbar(0)            % Initialize/reset
% This program is designed to perform a functional fuzzy cluster
% of missile trajectory data. 

%% Method
% Normalize (In this case, Range and Alt)
% 
% -> Start with first ~15 timesteps
% |  Compute distance from all obs to cluster center
% |  update membership values
% -< repeat until convergence
%% Constants
% Fuzzy parameter
m=2;
% Number of clusters
c=8;
% Time steps until online starts
turt=15;
% The reference missile chosen for final online clustering 
refmissile=40;

%% Reference Frame Calculation
% Should be imported from the Clustered.mat database. If not, these
% calculations need to be run

% eval(sprintf('ref.alt=spline(missile.m%i.time,missile.m%i.Alt);',refmissile,refmissile));
% eval(sprintf('ref.range=spline(missile.m%i.time,missile.m%i.Range);',refmissile,refmissile));
% eval(sprintf('ref.vel=spline(missile.m%i.time,missile.m%i.Velocity);',refmissile,refmissile));


%% RMS Calculation

j=0;
z=1;
oldmaxtime=0;
for i=1:total % Cycle missiles
%     if i==39
%         debugtime=1;
%     else
%     end
    j=j+1;
    Coord.sosAlt=0;
    Coord.sosRange=0;
    Coord.sosVel=0;
    eval(sprintf('time=missile.m%i.time;', i));
    maxtime=length(time);
%     eval(sprintf('Alt=missile.m%i.Alt;', i));
%     eval(sprintf('Range=missile.m%i.Range;', i));
    eval(sprintf('Vel=missile.m%i.Velocity;', i));
    for e =1:length(time)-turt
    if e==1
        for t=1:turt
%             Coord.sosAlt=(ppval(ref.alt,time(t))-Alt(t))^2+Coord.sosAlt;
%             Coord.sosRange=(ppval(ref.range,time(t))-Range(t))^2+...
%                 Coord.sosRange;
            Coord.sosVel=(ppval(ref.vel,time(t))-Vel(t))^2+Coord.sosVel;
        end
    else
        t=e-1+turt;
        
%         Coord.sosAlt=(ppval(ref.alt,time(t))-Alt(t))^2+Coord.sosAlt;
%         Coord.sosRange=(ppval(ref.range,time(t))-Range(t))^2+...
%             Coord.sosRange;
        Coord.sosVel=(ppval(ref.vel,time(t))-Vel(t))^2+Coord.sosVel;
    end
    
    
%     Coord.RMSAlt(i)=sqrt(Coord.sosAlt)/length(time);
%     Coord.RMSRange(i)=sqrt(Coord.sosRange)/length(time);
%     Coord.RMSVel(i)=sqrt(Coord.sosVel)/length(time);
    Coord.RMSVel(i)=sqrt(Coord.sosVel)/t;

%% "Distance" Calculations

% Cycle through missiles, i


% eval(sprintf('time=missile.m%i.time;', i));
% eval(sprintf('Alt=missile.m%i.Alt;', i));
% eval(sprintf('Range=missile.m%i.Range;', i));
% eval(sprintf('Vel=missile.m%i.Velocity;', i));

for C=1:c
%     eval(sprintf('Altdiff=Coord.Class%i(1)-Coord.RMSAlt(i);',C));
%     eval(sprintf('Rangediff=Coord.Class%i(2)-Coord.RMSRange(i);',C));
    eval(sprintf('Veldiff=Coord.Class%i(3)-Coord.RMSVel(i);',C));
    eval(sprintf('Class%i.Distance(i)=sqrt(Veldiff^2);',C));
end

%% Membership Values


for C=1:c
    eval(sprintf('Class%i.membership(i,e)=0;',C));
    for CC=1:c
        eval(sprintf(...
            'Class%i.membership(i,e)=Class%i.membership(i,e)+(Class%i.Distance(i)/Class%i.Distance(i))^(2/(m-1));',C,C,C,CC));
    end
    eval(sprintf('Class%i.membership(i,e)=Class%i.membership(i,e)^(-1);',C,C));
end

% The timesets show which missiles are members at that time set
for C=1:c
    if eval(sprintf('Class%i.membership(i,e)>0.5',C))
        eval(sprintf('Class%i.members(i,e)=1;',C));
        eval(sprintf('membership%i.timeset%i(j)=%i;',C,e,i));
%         switch C
%             case 1
%                 j=j+1;
%             case 2
%         end
%     elseif C==c
%         unclass(z,e)=i;
%         z=z+1;
    else
    end
end      
% elseif Class2.membership(i,e)>0.5 
%     Class2.members(i,e)=1;
%     eval(sprintf('membership2.timeset%i(k)=%i;',e,i));
%         
% elseif Class3.membership(i,e)>0.5
%     Class3.members(i,e)=1;
%     eval(sprintf('membership3.timeset%i(p)=%i;',e,i));
%         
% elseif Class4.membership(i,e)>0.5
%     Class4.members(i,e)=1;
%     eval(sprintf('membership4.timeset%i(q)=%i;',e,i));
%     
% elseif Class5.membership(i,e)>0.5
%     Class5.members(i,e)=1;
%     eval(sprintf('membership5.timeset%i(jj)=%i;',e,i));
%     
% elseif Class6.membership(i,e)>0.5
%     Class6.members(i,e)=1;
%     eval(sprintf('membership6.timeset%i(kk)=%i;',e,i));
        

% end

%% Cleanup

    end
    progressbar(i/total)
    if maxtime>oldmaxtime
        oldmaxtime=maxtime;
    end
end

%% Validation by plot
colours={'-m' '-c' '-r' '-g' '-b' '-k' '-xr' '-xc' '-xm' '-xg' '-xb' '-xk'};
videofile=sprintf('Clustering_Online_%i_ref%i.avi',c,refmissile);
newvid=VideoWriter(videofile);
open(newvid);
figure
view([60 22]);
axis([0 1200 0 6000 0 3500])
xlabel('time(sec)');ylabel('range');zlabel('Altitude');
grid on
hold on
for t=1:50:oldmaxtime
    axis([0 1200 0 6000 0 3500])
    view([60 22]);
    axis([0 1200 0 6000 0 3500])
    xlabel('time(sec)');ylabel('range');zlabel('Altitude');
    grid on
    hold on
   for C=1:c
       if eval(sprintf('isfield(membership%i,''timeset%i'')==1',C,t))
           eval(sprintf('Mem%i=membership%i.timeset%i;',C,C,t));
           for i=1:length(eval(sprintf('Mem%i',C)))
               if eval(sprintf('Mem%i(i)',C))~=0
                   eval(sprintf('j=Mem%i(i);',C));
                   if t==1
                       eval(sprintf('plot3(missile.m%i.time(1:turt),missile.m%i.Range(1:turt),missile.m%i.Alt(1:turt),colours{C})',j,j,j));
                   else
                       if eval(sprintf('length(missile.m%i.time)',j))-turt>=t
                           eval(sprintf('plot3(missile.m%i.time(1:turt+t),missile.m%i.Range(1:turt+t),missile.m%i.Alt(1:turt+t),colours{C})',j,j,j));
                       end
                   end
                   
                   
               end
           end
       end
   end
   
    frames=getframe;
    writeVideo(newvid,frames);
    
%     axes1 = axes('Parent',figure1);
    view([60 22]);
    axis([0 1200 0 6000 0 3500])
    xlabel('time(sec)');ylabel('range');zlabel('Altitude');
    grid on
    pause(0.0000001)
    hold off
end
close(newvid);
save(sprintf('Clustering_Online_Vel_%i_ref%i.mat',c,refmissile));



% newvid=VideoWriter('Wedge_First_Order.avi');
% open(newvid);
% for m=1:4:nm
%     figure(101)
%     surf(xplot,yplot,intime_e{m}./intime_r{m},'EdgeAlpha',0)
%     axis([0 2*pi 0 2*pi])
% %     axes1 = axes('Parent',figure(101));
%     view([-0.5 90]);
%     frames=getframe;
%     writeVideo(newvid,frames);
%     pause(0.01)
%     
% end
% close(newvid);














        