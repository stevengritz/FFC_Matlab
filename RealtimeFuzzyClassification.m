% Fuzzy Cluster? FUZZY CLUSTER
% This type of cluster is an online clustering, providing real-time results
% to the cluster assignment as time progresses
% NOTE: This requires the database 'Clustered.mat' to be loaded
function [conf_int_data, predgeo]=RealtimeFuzzyClassification(m,c,refmissile,geo_attributes,missile_2_classify,known_geo,plot_on,database_num)
close all
%% Constants
% Fuzzy parameter
% m=2;
% Number of clusters
% c=8;
% Time steps until online starts
turt=15;
% The reference missile chosen for final online clustering 
% refmissile=73;
% Geometrical attributes to be predicted 
% geo_attributes=[13];
% Is the geometery known for this test?
% known_geo='Y';
% Would you like a plot/movie:
% plot_on='N';

% progressbar(0)            % Initialize/reset

switch plot_on
    case 'Y'
%         figure
%         handel=gca;
    case 'N'
end
% This program is designed to perform a functional fuzzy cluster
% of missile trajectory data. 

%% Method
% Normalize (In this case, Range and Alt)
% 
% -> Start with first ~15 timesteps
% |  Compute distance from all obs to cluster center
% |  update membership values
% -< repeat until convergence
%% File Management
current_dir=strcat(pwd,sprintf('\\DataSet%i\\',database_num));

onlinefid=strcat(current_dir,'\onlineResults\');
dircheck=isdir(onlinefid);
if dircheck==0
    mkdir(onlinefid);
    mkdir(strcat(onlinefid,'\RMSE for Missiles\'));   
end


number_for_file=num2str(c);
file_path=strcat(current_dir,'\',number_for_file,' Clusters\Ref Based DBs\');
load(strcat(file_path,sprintf('Clustered_ref_%i.mat',refmissile)));
for C=1:c
    eval(sprintf('W%i=load(strcat(current_dir,''\\ANNResults\\cluster%i_refmiss%i_ANNresults.mat''),''W'');',C,C,refmissile));
    eval(sprintf('norm_scale%i=load(strcat(current_dir,''\\ANNResults\\cluster%i_refmiss%i_ANNresults.mat''),''norm_scale'');',C,C,refmissile));
    eval(sprintf('W%i=W%i.W;',C,C))
    eval(sprintf('norm_scale%i=norm_scale%i.norm_scale;',C,C))
end

%% Reference Frame Calculation
% Should be imported from the Clustered.mat database. If not, these
% calculations need to be run

% eval(sprintf('ref.alt=spline(missile.m%i.time,missile.m%i.Alt);',refmissile,refmissile));
% eval(sprintf('ref.range=spline(missile.m%i.time,missile.m%i.Range);',refmissile,refmissile));
% eval(sprintf('ref.vel=spline(missile.m%i.time,missile.m%i.Velocity);',refmissile,refmissile));
%% Required Initialization
for C=1:c
eval(sprintf('membership%i=[];',C));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
missile_2_classify=eval(missile_2_classify);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RMS Calculation
conf_int_data=zeros(total,7);
j=0;
z=1;
oldmaxtime=0;
jj=1;
for i=[missile_2_classify] % Cycle missiles
    j=j+1;
    Coord.sosAlt=0;
    Coord.sosRange=0;
    Coord.sosVel=0;
    predsos=0;
%     previousCluster=4;
    eval(sprintf('time=missile.m%i.time;', i));
    maxtime=length(time);
    time_int=floor(maxtime*[0.05 0.1 0.15 0.25 0.5 .75 1]);
    eval(sprintf('Alt=missile.m%i.Alt;', i));
    eval(sprintf('Range=missile.m%i.Range;', i));
    eval(sprintf('Vel=missile.m%i.Velocity;', i));
    for e =1:length(time)-turt
    if e==1
        for t=1:turt
            Coord.sosVel=(ppval(ref.vel,time(t))-Vel(t))^2+Coord.sosVel;
        end
    else
        t=e+turt;
        Coord.sosVel=(ppval(ref.vel,time(t))-Vel(t))^2+Coord.sosVel;
    end      
    Coord.RMSVel(i)=sqrt(Coord.sosVel)/t;

%% "Distance" Calculations

% Cycle through missiles, i
for C=1:c
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
%% Classification
member_check=Class1.membership(i,e);
cluster_id=1;
for C=2:c
    if eval(sprintf('Class%i.membership(i,e)>member_check',C))
        eval(sprintf('member_check=Class%i.membership(i,e);',C));
        cluster_id=C;
    end
end

eval(sprintf('Class%i.members(i,e)=1;',cluster_id));
eval(sprintf('membership%i.timeset%i(j)=%i;',cluster_id,e,i));
%% Prediction
% Normalize before prediction
eval(sprintf('scaled_inputs=[time(t) Alt(t) Range(t) Vel(t)]./norm_scale%i(1:4);',cluster_id));
eval(sprintf('missile.m%i.geo_predict=BPpredict(scaled_inputs,4,10,1,W%i);',i,cluster_id));
eval(sprintf('missile.m%i.geo_predict=missile.m%i.geo_predict*norm_scale%i(5);',i,i,cluster_id));
% eval(sprintf('missile.m%i.geo_predict=BPpredict([time(t) Alt(t) Range(t) Vel(t)],4,10,1,W%i);',i,cluster_id));
switch known_geo
    case 'Y'
        eval(sprintf('predgeo(j,e)=missile.m%i.geo_predict;',i));
        eval(sprintf('actgeo=missile.m%i.geo(geo_attributes);',i));
        predsos=predsos+(predgeo(j,e)-actgeo).^2;
        eval(sprintf('missile.m%i.RMSE.timeset(e)=(predsos.^(0.5))./e;',i));
    case 'N'
        
end

%% Error/Conf Interval Calculations Using Prediction RMSE
switch known_geo
    case 'Y'
check_t=find(t==time_int, 1);
check_t2=isempty(check_t);
if check_t2==0
    eval(sprintf('conf_int_data(jj,check_t)=missile.m%i.RMSE.timeset(e);',i));
end
    case 'N'
end

%% Cleanup

    end
    jj=jj+1;
%     progressbar(i/total)
    if maxtime>oldmaxtime
        oldmaxtime=maxtime;
    end
    
    switch plot_on
        case 'Y'
%             eval(sprintf('plot(handel,1:length(missile.m%i.RMSE.timeset),missile.m%i.RMSE.timeset)',i,i));
%             xlabel(handel,'Flight time, s')
%             ylabel(handel,'RMSE')
%             title(handel,sprintf('Diameter RMSE for Missile %i',i))
%             print(strcat(onlinefid,'RMSE for Missiles\',sprintf('Missile %i.pdf',i)),'-dpdf','-r300')
        case 'N'
    end
end

%% Validation by plot
switch plot_on
    case 'Y'
% colours={'-m' '-c' '-r' '-g' '-b' '-k' '-xr' '-xc' '-xm' '-xg' '-xb' '-xk'};
% videofile=strcat(onlinefid,sprintf('Clustering_Online_%i_ref%i.avi',c,refmissile));
% newvid=VideoWriter(videofile);
% open(newvid);
% figure
% view([60 22]);
% axis([0 1200 0 6000 0 3500])
% xlabel('time(sec)');ylabel('range');zlabel('Altitude');
% grid on
% hold on
% for t=1:50:oldmaxtime
%     axis([0 2200 0 12000 0 8000])
%     view([60 22]);
%     axis([0 2200 0 12000 0 8000])
%     xlabel('time(sec)');ylabel('range');zlabel('Altitude');
%     grid on
%     hold on
%    for C=1:c
%        
%        if eval(sprintf('isfield(membership%i,''timeset%i'')==1',C,t))
%            eval(sprintf('Mem%i=membership%i.timeset%i;',C,C,t));
%            for i=1:length(eval(sprintf('Mem%i',C)))
%                if eval(sprintf('Mem%i(i)',C))~=0
%                    eval(sprintf('j=Mem%i(i);',C));
%                    if t==1
%                        eval(sprintf('plot3(missile.m%i.time(1:turt),missile.m%i.Range(1:turt),missile.m%i.Alt(1:turt),colours{C})',j,j,j));
%                    else
%                        if eval(sprintf('length(missile.m%i.time)',j))-turt>=t
%                            eval(sprintf('plot3(missile.m%i.time(1:turt+t),missile.m%i.Range(1:turt+t),missile.m%i.Alt(1:turt+t),colours{C})',j,j,j));
%                        end
%                    end
%                    
%                    
%                end
%            end
%        end
%       
%    end
%    
%     frames=getframe;
%     writeVideo(newvid,frames);
%     writeVideo(newvid,frames);
%     writeVideo(newvid,frames);
%     writeVideo(newvid,frames);
%     writeVideo(newvid,frames);
%     
% %     axes1 = axes('Parent',figure1);
%     view([60 22]);
%     axis([0 2200 0 12000 0 8000])
%     xlabel('time(sec)');ylabel('range');zlabel('Altitude');
%     grid on
%     pause(0.0000001)
%     hold off
% end
% close(newvid);
    case 'N'
end
save(strcat(onlinefid,sprintf('Clustering_Online_Vel_%i_ref%i.mat',c,refmissile)));
end


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














        