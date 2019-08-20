cby = preptypey(cby);
moy = preptypey(moy);
puy = preptypey(puy);
quy = preptypey(quy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure 6B -- Example with one monkey, all data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure
subplot(1,3,1)
hold on
plot(quy.summary.full.posdata(find(quy.summary.full.side == 'u')),quy.summary.full.veldata(find(quy.summary.full.side == 'u')),'ks','markersize',2,'markerfacecolor','k','markeredgecolor','k');
plot(quy.summary.full.posdata(find(quy.summary.full.side == 'd')),quy.summary.full.veldata(find(quy.summary.full.side == 'd')),'ks','markersize',2,'markerfacecolor',[.6 .6 .6],'markeredgecolor',[.6 .6 .6]);

plot(quy.summary.full.meanpos([1 3 5]),quy.summary.full.meanvel([1 3 5]),'ks','markersize',6,'linewidth',0.96,'markerfacecolor','w','markeredgecolor',[.6 .6 .6]);
plot(quy.summary.full.meanpos([2 4 6]),quy.summary.full.meanvel([2 4 6]),'ks','markersize',6,'linewidth',0.96,'markerfacecolor','w','markeredgecolor','k');


set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 15],'xtick',[0 5 10 15], ...
  'ylim',[-15 15],'ytick',[-15 -10 -5 0 5 10 15], ...
  'PlotBoxAspectRatio',[1 1 1], ...
  'DataAspectRatioMode','auto', ...
  'FontName','Helvetica', ...
  'FontSize',12, ...
  'LineWidth',0.96, ...
  'TickLength',[.048 .048], ...
  'XTickMode','manual','YTickMode','manual','ZTickMode','manual','xlimmode','manual','ylimmode','manual','zlimmode','manual');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure 6C -- all monkeys, summary data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,2)
hold on

errorbar(cby.summary.meanpos,cby.summary.meanvel,cby.summary.stdvel,cby.summary.stdvel,'kd','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(moy.summary.meanpos,moy.summary.meanvel,moy.summary.stdvel,moy.summary.stdvel,'ko','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(puy.summary.meanpos,puy.summary.meanvel,puy.summary.stdvel,puy.summary.stdvel,'ks','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(quy.summary.meanpos,quy.summary.meanvel,quy.summary.stdvel,quy.summary.stdvel,'k^','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');


set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 15],'xtick',[0 5 10 15], ...
  'ylim',[0 15],'ytick',[0 5 10 15], ...
  'PlotBoxAspectRatio',[1 1 1], ...
  'DataAspectRatioMode','auto', ...
  'FontName','Helvetica', ...
  'FontSize',12, ...
  'LineWidth',0.96, ...
  'TickLength',[.048 .048], ...
  'XTickMode','manual','YTickMode','manual','ZTickMode','manual','xlimmode','manual','ylimmode','manual','zlimmode','manual');

disp(['mean slope non-normalized data = ', num2str(mean([puy.stats.slope quy.stats.slope]))])
disp(['std slope non-normalized data = ', num2str(std([puy.stats.slope quy.stats.slope]))])
disp(['p slope non-normalized data = ', num2str(std([puy.stats.pslope quy.stats.pslope]))])

disp(['mean y-int non-normalized data = ', num2str(mean([puy.stats.yint quy.stats.yint]))])
disp(['std y-int non-normalized data = ', num2str(std([puy.stats.yint quy.stats.yint]))])
disp(['p yint slope non-normalized data = ', num2str(std([puy.stats.pyint quy.stats.pyint]))])

disp(['o mean slope non-normalized data = ', num2str(mean([puy.stats.oldslope quy.stats.oldslope]))])
disp(['o std slope non-normalized data = ', num2str(std([puy.stats.oldslope quy.stats.oldslope]))])
disp(['o p slope non-normalized data = ', num2str(std([puy.stats.oldpslope quy.stats.oldpslope]))])

disp(['o mean y-int non-normalized data = ', num2str(mean([puy.stats.oldyint quy.stats.oldyint]))])
disp(['o std y-int non-normalized data = ', num2str(std([puy.stats.oldyint quy.stats.oldyint]))])
disp(['o p yint slope non-normalized data = ', num2str(std([puy.stats.oldpyint quy.stats.oldpyint]))])


