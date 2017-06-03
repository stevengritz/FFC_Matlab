% The whole enchilada...yummmmm
clc
clear all
close all
tic
%% Constants for Clsutering
% Fuzziness parameter
m=2;
% Number of clusters 
c=8;
% Number of iterations for clustering
epochs=40;
% Reference Missile
allRef=0; % Cycle all of them
% Do you know the geo of what you are looking for?
known_geo='Y';
% Yes you want the plots for now
plot_on='N';
%% Additional Constants for Nerual Sections
%       - For a full list of the geometerical attributes please refer to
%         the function file 'PreNeural.m'.
% The characteristics to be modeled
geo_attributes=[13];
% Input Neurons for the ANN
Inputs=4;
% Output Neurons for ANN 
Outputs=length(geo_attributes);
% Number of Hidden Neurons
Hidden=10;
% Learning Rate for ANN
alpha=0.5;
% Error Tolerance for ANN training
et=0.05;
% Max number of epochs for training
maxepoch=2000;
% Percent of the data set to hold out for validation of the training
holdpercent=0.2;
%% Missilez...
missile_2_classify='(total-2:1:total)';

%% Clustering All Day Long

parfor i=13:20
    if  i==17 
%     elseif   i==14
    else
    clc
    fprintf('Currently working on Data Set %i...\r\n',i)
    F=[0,0];
    database_num=i;
    MaxRangeAlt(database_num);
    refmissile=RefMissileSort(database_num);
    for j=1:2
        close all
        fprintf('Clustering FFC for set %i\r\n',j)
        F(j)=FuzzyClusterRobust(m,c,epochs,allRef,refmissile(j),database_num);
    end
    if F(1)<F(2)
        selected_missile=refmissile(1);
    else
        selected_missile=refmissile(2);
    end
    % Prepare Data for ANN
    close all
    fprintf('Parsing data for ANN\r\n')
    PreNeural(selected_missile,c,geo_attributes,database_num)
    % Train ANNs
    close all
    fprintf('Starting training for ANN\r\n')
    FuzzyBP(selected_missile,c,Inputs,Outputs,Hidden,alpha,et,maxepoch,holdpercent,database_num)
    % The Big Classification Pallooza
    close all
    fprintf('Classification has begun\r\n')
    [conf_int_data{i} predgeo{i}]=RealtimeFuzzyClassification(m,c,selected_missile,geo_attributes,missile_2_classify,known_geo,plot_on,database_num);
    
    end
end
angry=toc
save('Enchilada_data.mat')
