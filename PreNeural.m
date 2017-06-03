% Neural Network pre-process post-clustering
% Steven Ritz
%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a data processor that preps the clustered missile data for input
% to the Aeromodeler(TM) software provided by SimulationPLUS. Compatibility
% with other ANN programs or codes is not guarenteed 
%
% This program requires:
%   -Classificated_plus.mat
%   -RefMissileX.txt (where X is the number of the ref missile)

% clc
% clear all 
% close all

function [empty]=PreNeural(selected_missile,clusters,geo_attributes,database_num)
current_dir=strcat(pwd,sprintf('\\DataSet%i\\',database_num));
missileall=load(strcat(current_dir,'Classificated_plus.mat'),'missile','total','ppm');
missile=missileall.missile;
total=missileall.total;
ppm=missileall.ppm;

% Initialize input variables
% selected_missile=73;
% clusters=8;
cluster_id=zeros(1,clusters);
cluster_group=zeros(clusters,total);
% geo_attributes=[13];
% current_dir=pwd;
file_path=strcat(current_dir,'ClusteredDataforANN\');
dircheck=isdir(file_path);
if dircheck==0
    mkdir(current_dir,'ClusteredDataforANN');
end

% First step is to check which inputs do not vary
% % [m design_in]=size(missile_geo);
% % j=1; k=1;
% % for i=1:design_in
% %     check_vary=sum(missile_geo(1,i)==missile_geo(:,i));
% %     if check_vary<m
% %         design_used(j)=i;
% %         j=j+1;
% %     else
% %         design_unused(k)=i;
% %         k=k+1;
% %     end
% % end
% Design_used contains the indices for the columns to be used for training
% the geometrical data. Design_unused lists the non-varying geo parameters 

%% Pull cluster data from file
% This is necessary since different ref missiles can be run before this
% program is executed. This allows for different ref missile cluster groups
% to be chosen without needing to run the cluster program first or having
% the cluster groups in memory/workspace

warning('off','all');
ref_file=strcat(current_dir,num2str(clusters),' Clusters\','Missiles In Clusters\','RefMissile ',num2str(selected_missile),'.txt');
file=fopen(ref_file);
i=1;
j=1;
p=1;
while ~feof(file)
    line=fgets(file);
    checkline=isletter(line);
    if checkline(1)==1
        
        if strncmp('Class',line,5)
            cluster_id(j)=str2num(line(7:8));
            j=j+1;        
        end
        continue
    else
        line_len=length(str2num(line));
        cluster_group(i,1:line_len)=str2num(line);
        i=i+1;
    end
    
end
fclose(file);

% At this point the array 'cluster_group' holds the missile numbers in each
% cluster, sorted by rows

%% Parse the performance data based on clusters
%   j: cluster id number
%   i: missile id number
for j=1:clusters
    index_old=1;
    for i=cluster_group(j,:)
        if i==0
            continue
        else
            eval(sprintf('pdata.c%i(index_old:index_old+ppm(i)-1,1)=missile.m%i.time'';',j,i));
            eval(sprintf('pdata.c%i(index_old:index_old+ppm(i)-1,2)=missile.m%i.Alt'';',j,i));
            eval(sprintf('pdata.c%i(index_old:index_old+ppm(i)-1,3)=missile.m%i.Range'';',j,i));
            eval(sprintf('pdata.c%i(index_old:index_old+ppm(i)-1,4)=missile.m%i.Velocity'';',j,i));
            
            for k=index_old:index_old+ppm(i)-1
                eval(sprintf('pdata.c%i(k,5:4+length(geo_attributes))=missile.m%i.geo(geo_attributes);',j,i));
                % only the desired attributes
            end
            eval(sprintf('index_old=length(pdata.c%i)+1;',j))
        end
    end
    final_index=k;
%     file_path=strcat(current_dir,'\ClusteredDataforANN\');
    cluster_path=strcat(file_path,sprintf('Perfomance_geo_cluster%i_refmiss%i.txt',j,selected_missile));
    cluster_file=fopen(cluster_path,'w');
    
    
    fprintf(cluster_file,'time\t alt\t range\t velocity\t ');
    for header=geo_attributes
        switch header
            case 	1
                fprintf(cluster_file,'rnos/rbod\t ');
            case 	2
                fprintf(cluster_file,'lnos/dbod\t ');
            case 	3
                fprintf(cluster_file,'kfuel\t ');
            case 	4
                fprintf(cluster_file,'rpvar\t ');
            case 	5
                fprintf(cluster_file,'rivar\t ');
            case 	6
                fprintf(cluster_file,'nsp\t ');
            case 	7
                fprintf(cluster_file,'fvar\t ');
            case 	8
                fprintf(cluster_file,'eps\t ');
            case 	9
                fprintf(cluster_file,'ptang\t ');
            case 	10
                fprintf(cluster_file,'fn1\t ');
            case 	11
                fprintf(cluster_file,'dth/Db\t ');
            case 	12
                fprintf(cluster_file,'Lb/Db\t ');
            case 	13
                fprintf(cluster_file,'dbody\t ');
            case 	14
                fprintf(cluster_file,'b2w/DB\t ');
            case 	15
                fprintf(cluster_file,'crw/DB\t ');
            case 	16
                fprintf(cluster_file,'trw\t ');
            case 	17
                fprintf(cluster_file,'wleswe\t ');
            case 	18
                fprintf(cluster_file,'xLew\t ');
            case 	19
                fprintf(cluster_file,'b2t/DB\t ');
            case 	20
                fprintf(cluster_file,'crt/DB\t ');
            case 	21
                fprintf(cluster_file,'trt\t ');
            case 	22
                fprintf(cluster_file,'tleswp\t ');
            case 	23
                fprintf(cluster_file,'xTEt\t ');
            case 	24
                fprintf(cluster_file,'Apdly\t ');
            case 	25
                fprintf(cluster_file,'thet0\t ');
            case 	26
                fprintf(cluster_file,'xk1\t ');
            case 	27
                fprintf(cluster_file,'xk2\t ');
            case 	28
                fprintf(cluster_file,'Dumy\t ');
            case 	29
                fprintf(cluster_file,'dele0\t ');
            case 	30
                fprintf(cluster_file,'delr0\t ');
            case 	31
                fprintf(cluster_file,'xcet\t ');
            case 	32
                fprintf(cluster_file,'dtchek/DB\t ');
            case 	33
                fprintf(cluster_file,'psicor\t ');
            case 	34
                fprintf(cluster_file,'delx-z\t ');
            case 	35
                fprintf(cluster_file,'delx-y\t ');
        end
        fprintf(cluster_file,'\r\n');
    end
    
%     eval(sprintf('allmembers=length(Class%i.members);',i));
%     eval(sprintf('themembers=Class%i.members;',i));
%     fprintf(Membership_file,'Class %i \r\n',i);
    for t=1:final_index
        for u=1:4+length(geo_attributes)
            fprintf(cluster_file,'%10.4g\t  ',eval(sprintf('pdata.c%i(t,u)',j)));
        end
       fprintf(cluster_file,' \r\n'); 
    end
    
    
    
    fclose(cluster_file);
end
end


















