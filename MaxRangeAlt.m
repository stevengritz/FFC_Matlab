% Max Alt and Range calculation and file write.
% Requires data set to be loaded into Matlab
function [empty]=MaxRangeAlt(database_num)
close all
current_dir=strcat(pwd,sprintf('\\DataSet%i\\',database_num));
missileall=load(strcat(current_dir,'Classificated_plus.mat'),'missile','total');
missile=missileall.missile;
total=missileall.total;

maxAlt=zeros(1,total); maxRange=zeros(1,total);

for i=1:total
    
    eval(sprintf('time=missile.m%i.time;', i));
    eval(sprintf('Alt=missile.m%i.Alt;', i));
    eval(sprintf('Range=missile.m%i.Range;', i));
    eval(sprintf('Vel=missile.m%i.Velocity;', i));
    
    
    maxAlt(i)=max(Alt);
    
    maxRange(i)=max(Range);
    
    

end




Max_file=fopen(strcat(current_dir,'Max_Alt_and_Range.txt'),'wt');
fprintf(Max_file,'Obs \t Max Range \t Max Alt \n');
for i=1:i
    
    fprintf(Max_file,'%i \t %10.4f \t %10.4f \n',i,maxAlt(i),maxRange(i));
   
end

fclose(Max_file);
end