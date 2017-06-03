function [empty]=FuzzyBP(refmissile,Clusters,Inputs,Outputs,Hidden,alpha,et,maxepoch,holdpercent,database_num)
close all
warning('off','all');
current_dir=strcat(pwd,sprintf('\\DataSet%i\\',database_num));
% refmissile=121;
% Clusters=8;
dpoints=Inputs+Outputs;

file_path=strcat(current_dir,'\ANNResults\');
dircheck=isdir(file_path);
if dircheck==0
    mkdir(file_path);
   
end
for cluster=1:Clusters
    close all
     fid=strcat(current_dir,'\ClusteredDataforANN\',sprintf('Perfomance_geo_cluster%i_refmiss%i.txt',cluster,refmissile));
file=fopen(fid);
i=1;
j=1;
p=1;
while ~feof(file)
    line=fgets(file);
    checkline=isletter(line);
    if checkline(1)~=1
        data(i,1:dpoints)=str2num(line);
        i=i+1;
        
    else
        
    end
    
end
fclose(file);
% Normalization
[R C]=size(data);
for i=1:C
    norm_scale(i)=max(data(:,i));
    data(:,i)=data(:,i)/norm_scale(i);
end
%%%%%
trainx=data(:,1:Inputs); trainy=data(:,Inputs+1:Inputs+Outputs);
holds=zeros(1,floor(length(data)*holdpercent));
hold_full=1;
i=1;
while holds(1,floor(length(data)*holdpercent))==0
    potential=randi(length(data),1);
    check=find(holds==potential, 1);
    check=isempty(check);
    if check==1
        holds(1,i)=potential;
        i=i+1;
    end
end
i=1;
for j=[holds]
    xholdout(i,1:Inputs)=trainx(j,1:Inputs);
    trainx(j,1:Inputs)=0;
    yholdout(i,1:Outputs)=trainy(j,1:Outputs);
    trainy(j,1:Outputs)=0;
    i=i+1;
end
j=1;
for i=1:length(trainx)
    if trainx(i,1:Inputs)~=zeros(1,Inputs)
        trainx2(j,1:Inputs)=trainx(i,1:Inputs);
        trainy2(j,1:Outputs)=trainy(i,1:Outputs);
        j=j+1;
    end
end
W=BPANN(trainx2,trainy2,Inputs,Hidden,Outputs,alpha,et,maxepoch);
[y]=BPpredict(xholdout,Inputs,Hidden,Outputs,W);

% Rescale
for i=1:Outputs
    yholdout(:,i)=yholdout*norm_scale(Inputs+i);
    y(:,i)=y*norm_scale(Inputs+i);
end
sos=0;
for i=1:length(yholdout)
    sos=sos+(trainy2(i)-y(i))^2;
end
RMSE=sqrt(sos)/length(yholdout);
savefid=strcat(current_dir,'\ANNResults\',sprintf('cluster%i_refmiss%i_ANNresults.mat',cluster,refmissile));
save(savefid)
hand=figure;
scatter(yholdout,y)
xlabel('y holdout')
ylabel('predicted y')
xlim([0 1.5]); ylim([0 1.5])
xplot=0:0.1:1.5;yplot=0:0.1:1.5;
hold on
plot(xplot,yplot,'k')
% Create textbox
annotation(hand,'textbox',...
    [0.199492462311558 0.827195467422096 0.277894472361809 0.0524079320113323],...
    'String',{sprintf('RMSE=%4.3g',RMSE)},...
    'FontSize',24,...
    'FitBoxToText','on');
plotfid=strcat(current_dir,'\ANNResults\',sprintf('cluster%i_refmiss%i_ANNresults.pdf',cluster,refmissile));
hold off
export_fig(plotfid,'-transparent')
clear data trainx trainy holds xholdout yholdout y W trainx2 trainy2
end
 
end
% toc


