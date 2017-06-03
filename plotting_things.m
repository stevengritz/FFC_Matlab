function [fig_handel,plot_handel]=plotting_things(c,allClasses,Coord,refmissile,file_path)
% normAlt=Coord.RMSAlt./max(Coord.RMSAlt);
% normRange=Coord.RMSRange./max(Coord.RMSRange);
% normVel=Coord.RMSVel./max(Coord.RMSVel);
% scatter3(normAlt,normRange,normVel)
fig_handel=figure;
plot_handel=gca;
xlabel('RMS Alt'); ylabel('RMS Range'); zlabel('RMS Vel');
colours={'m' 'c' 'r' 'g' 'b' 'k' 'xr' 'xc' 'xm' 'xg' 'xb' 'xk'};
% linestypes=['--' ':' '-.'];
% markers=['+' 'o' 'x'];
plot_count=1;
for C=1:c
if eval(sprintf('sum(allClasses.Class%i.members)',C))>0
    for i=1:eval(sprintf('length(allClasses.Class%i.members)',C))
         eval(sprintf('j=allClasses.Class%i.members(i);',C));         
        eval(sprintf('scatter3(Coord.RMSAlt(j),Coord.RMSRange(j),Coord.RMSVel(j),''%s'')',colours{plot_count}));
        hold on
    end
end
plot_count=plot_count+1;
end

export_fig(strcat(file_path,'\RMS Plots\',sprintf('%icluster_RMS_%i.pdf',c,refmissile)), '-transparent')
hold off
end
% newvid=VideoWriter(sprintf('Clustering_6_Centers%i.avi',refmissile));
% newvid.FrameRate=2;
% open(newvid)
% % figure%('units','normalized','outerposition',[0 0 1 1])
% % 
% % for t=1:epochs
% %     axis([0 altlim 0 rangelim 0 vellim]) 
% %     title(sprintf('Epoch %i',t));
% %     if t==epochs
% %         for i=1:c
% %             centerplot=epoch_center{i,t};
% %             scatter3(centerplot(1),centerplot(2),centerplot(3))
% %             hold on
% %         end
% %     export_fig(strcat(file_path,'\RMS Centers\',sprintf('%icluster_RMS_%i_%i.pdf',c,refmissile,t)), '-transparent')
% %     end
% % %     frames=getframe;
% % %     writeVideo(newvid,frames);
% % %     pause(.5)
% %     hold off
% % end

% close(newvid);

