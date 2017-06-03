% Max Range and Alt sort for ref missiles
% Requires:
%   -Max_Alt_and_Range.txt

function [refmissile]=RefMissileSort(database_num)
current_dir=strcat(pwd,sprintf('\\DataSet%i\\',database_num));
load(strcat(current_dir,'Classificated_plus.mat'));

file=fopen(strcat(current_dir,'Max_Alt_and_Range.txt'));
i=1;
while ~feof(file)
    line=fgets(file);
    checkline=isletter(line);
    if checkline(1)==1
        
        if strncmp('Obs',line,3)
            
        end
        continue
    else
        data(i,1:3)=str2num(line);
        i=i+1;
    end
    
end
fclose(file);

totallines=i-1;
RangeMean=mean(data(:,2));
AltMean=mean(data(:,3));
RangeStd=std(data(:,2));
AltStd=std(data(:,3));
refDomain(1,:)=[RangeMean-RangeStd RangeMean+RangeStd];
refDomain(2,:)=[AltMean-AltStd AltMean+AltStd];
for i=1:2
    for j=1:2
        if refDomain(i,j)<0
            refDomain(i,j)=0;
        end
    end
end

j=1; k=1;
for i=1:totallines
%     if data(i,2)<RangeMean && data(i,3)<AltMean && (data(i,2)*0.8<data(i,3) && data(i,3)<data(i,2)*1.2)
    if data(i,2)<refDomain(1,1) || data(i,3)<refDomain(2,1)
        filteredListLow(j,:)=data(i,:);
        j=j+1;
    elseif data(i,2)>refDomain(1,2) && data(i,3)>refDomain(2,2)
        filteredListHigh(k,:)=data(i,:);
        k=k+1;
    end
end


[junk index]=max(filteredListLow(:,3));
refmissile(1)=filteredListLow(index,1);

[junk index]=max(filteredListHigh(:,2));
refmissile(2)=filteredListHigh(index,1);
end
















