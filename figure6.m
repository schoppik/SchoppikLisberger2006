%%%%%%%%%%%%%%%%%
% prep the data %
%%%%%%%%%%%%%%%%%

mot = preptypet(mot);
put = preptypet(put);


%%%%%%%%%%%%%%%%%%%
% 3b - one monkey %
%%%%%%%%%%%%%%%%%%%

h = figure
subplot(3,1,1)
hold on


plot(mot.summary.b.mot,mot.summary.b.vel,'o','markerfacecolor',[.6 .6 .6],'markeredgecolor',[.6 .6 .6],'markersize',3,'linewidth',0.96);
plot(mot.summary.a.mot,mot.summary.a.vel,'o','markerfacecolor','w','markeredgecolor','k','markersize',3);



set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 80],'xtick',[0:20:80], ...
  'ylim',[0 20],'ytick',[0 10 20], ...
  'PlotBoxAspectRatio',[1 1 1], ...
  'DataAspectRatioMode','auto', ...
  'FontName','Helvetica', ...
  'FontSize',12, ...
  'LineWidth',0.96, ...
  'TickLength',[.048 .048], ...
  'XTickMode','manual','YTickMode','manual','ZTickMode','manual','xlimmode','manual','ylimmode','manual','zlimmode','manual');

%set(gcf,'Units','inches', ...
%  'Position',[3 3 2.25 2.25],...
%  'PaperPosition',[4 4 2.25 2.25]);

% print(strcat('-f',num2str(h)),'-depsc2','/Users/schoppik/Desktop/fig3b.eps')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3c & d - fits for two monks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ribbonwidth = .25;

subplot(3,1,2)

hold on
% plot the confidence intervals as a ribbon -- fit them first to use them
% as dimensions for successive rectangles
a = exponential(mot.stats.a.beta,[0:ribbonwidth:80]);
alowci = exponential(mot.stats.a.ci(:,1),[0:ribbonwidth:80]);
ahighci = exponential(mot.stats.a.ci(:,2),[0:ribbonwidth:80]);

b = exponential(mot.stats.b.beta,[0:ribbonwidth:80]);
blowci = exponential(mot.stats.b.ci(:,1),[0:ribbonwidth:80]);
bhighci = exponential(mot.stats.b.ci(:,2),[0:ribbonwidth:80]);

hold on
% for i = 1:length(alowci)
%   rectangle('position',[i*ribbonwidth blowci(i) ribbonwidth bhighci(i)-blowci(i)],'facecolor',[.6 .6 .6],'edgecolor',[.6 .6 .6]);
% end
plot([0:ribbonwidth:80],b,'-','color',[.6 .6 .6],'linewidth',2*0.96)
plot([0:ribbonwidth:80],blowci,'--','color',[.6 .6 .6],'linewidth',2*0.96)
plot([0:ribbonwidth:80],bhighci,'--','color',[.6 .6 .6],'linewidth',2*0.96)

plot([0:ribbonwidth:80],a,'-','color','k','linewidth',2*0.96)
plot([0:ribbonwidth:80],alowci,'--','color','k','linewidth',2*0.96)
plot([0:ribbonwidth:80],ahighci,'--','color','k','linewidth',2*0.96)
%%plot([80 80],[alowci(end) ahighci(end)],'k','linewidth',2*0.96)
%plot([0 0],[alowci(1) ahighci(1)],'k','linewidth',2*0.96)



set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 80],'xtick',[0:20:80], ...
  'ylim',[0 20],'ytick',[0 10 20], ...
  'PlotBoxAspectRatio',[1 1 1], ...
  'DataAspectRatioMode','auto', ...
  'FontName','Helvetica', ...
  'FontSize',12, ...
  'LineWidth',0.96, ...
  'TickLength',[.048 .048], ...
  'XTickMode','manual','YTickMode','manual','ZTickMode','manual','xlimmode','manual','ylimmode','manual','zlimmode','manual');


% set(gcf,'Units','inches', ...
%   'Position',[3 3 2.25 2.25],...
%   'PaperPosition',[4 4 2.25 2.25]);
% 
% print(strcat('-f',num2str(h)),'-depsc2','/Users/schoppik/Desktop/fig3c.eps')

subplot(3,1,3)

hold on
% plot the confidence intervals as a ribbon -- fit them first to use them
% as dimensions for successive rectangles
a = exponential(put.stats.a.beta,[0:ribbonwidth:80]);
alowci = exponential(put.stats.a.ci(:,1),[0:ribbonwidth:80]);
ahighci = exponential(put.stats.a.ci(:,2),[0:ribbonwidth:80]);

b = exponential(put.stats.b.beta,[0:ribbonwidth:80]);
blowci = exponential(put.stats.b.ci(:,1),[0:ribbonwidth:80]);
bhighci = exponential(put.stats.b.ci(:,2),[0:ribbonwidth:80]);

hold on
% % for i = 1:length(alowci)
% %   rectangle('position',[i*ribbonwidth blowci(i) ribbonwidth bhighci(i)-blowci(i)],'facecolor',[.6 .6 .6],'edgecolor',[.6 .6 .6]);
% % end
% 
% % now the equivalent for open circles
% plot([0:ribbonwidth:80],alowci,'color','k','linewidth',2*0.96)
% plot([0:ribbonwidth:80],ahighci,'color','k','linewidth',2*0.96)
% %plot([80 80],[alowci(end) ahighci(end)],'k','linewidth',2*0.96)
% plot([0 0],[alowci(1) ahighci(1)],'k','linewidth',2*0.96)

plot([0:ribbonwidth:80],b,'-','color',[.6 .6 .6],'linewidth',2*0.96)
plot([0:ribbonwidth:80],blowci,'--','color',[.6 .6 .6],'linewidth',2*0.96)
plot([0:ribbonwidth:80],bhighci,'--','color',[.6 .6 .6],'linewidth',2*0.96)

plot([0:ribbonwidth:80],a,'-','color','k','linewidth',2*0.96)
plot([0:ribbonwidth:80],alowci,'--','color','k','linewidth',2*0.96)
plot([0:ribbonwidth:80],ahighci,'--','color','k','linewidth',2*0.96)

set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 80],'xtick',[0:20:80], ...
  'ylim',[0 20],'ytick',[0 10 20], ...
  'PlotBoxAspectRatio',[1 1 1], ...
  'DataAspectRatioMode','auto', ...
  'FontName','Helvetica', ...
  'FontSize',12, ...
  'LineWidth',0.96, ...
  'TickLength',[.048 .048], ...
  'XTickMode','manual','YTickMode','manual','ZTickMode','manual','xlimmode','manual','ylimmode','manual','zlimmode','manual');


% set(gcf,'Units','inches', ...
%   'Position',[3 3 2.25 2.25],...
%   'PaperPosition',[4 4 2.25 2.25]);
% 
% print(strcat('-f',num2str(h)),'-depsc2','/Users/schoppik/Desktop/fig3d.eps')