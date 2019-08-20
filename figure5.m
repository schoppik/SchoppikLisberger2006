% mox = prepforfig4(mox);
% moa = prepforfig4(moa);
% moz = prepforfig4(moz);
% 
% pux = prepforfig4(pux);
% pua = prepforfig4(pua);
% puz = prepforfig4(puz);
% 
% cbx = prepforfig4(cbx);
% cba = prepforfig4(cba);
% cbz = prepforfig4(cbz);
% 
% qux = prepforfig4(qux);
% qua = prepforfig4(qua);
% quz = prepforfig4(quz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure 4B -- all monkeys, summary data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
hold on

subplot(1,4,3)
hold on

errorbar(cba.summary.meanpos,cba.summary.meanvel,cba.summary.stdvel,cba.summary.stdvel,'kd','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(cbx.summary.meanpos,cbx.summary.meanvel,cbx.summary.stdvel,cbx.summary.stdvel,'kd','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[0 0 0],'markeredgecolor','k');
errorbar(cbz.summary.meanpos,cbz.summary.meanvel,cbz.summary.stdvel,cbz.summary.stdvel,'kd','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[.5 .5 .5],'markeredgecolor','k');

set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 10],'xtick',[0 5 10], ...
  'ylim',[5 25],'ytick',[5 10 15 20 25], ...
  'PlotBoxAspectRatio',[1 1 1],...
  'DataAspectRatioMode','auto');

subplot(1,4,2)
hold on

errorbar(moa.summary.meanpos,moa.summary.meanvel,moa.summary.stdvel,moa.summary.stdvel,'ko','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(mox.summary.meanpos,mox.summary.meanvel,mox.summary.stdvel,mox.summary.stdvel,'ko','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[0 0 0],'markeredgecolor','k');
errorbar(moz.summary.meanpos,moz.summary.meanvel,moz.summary.stdvel,moz.summary.stdvel,'ko','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[.5 .5 .5],'markeredgecolor','k');

set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 10],'xtick',[0 5 10], ...
  'ylim',[5 25],'ytick',[5 10 15 20 25], ...
  'PlotBoxAspectRatio',[1 1 1],...
  'DataAspectRatioMode','auto');

subplot(1,4,1)
hold on

errorbar(pua.summary.meanpos,pua.summary.meanvel,pua.summary.stdvel,pua.summary.stdvel,'ks','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(pux.summary.meanpos,pux.summary.meanvel,pux.summary.stdvel,pux.summary.stdvel,'ks','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[0 0 0],'markeredgecolor','k');
errorbar(puz.summary.meanpos,puz.summary.meanvel,puz.summary.stdvel,puz.summary.stdvel,'ks','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[.5 .5 .5],'markeredgecolor','k');

set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 10],'xtick',[0 5 10], ...
  'ylim',[5 25],'ytick',[5 10 15 20 25], ...
  'PlotBoxAspectRatio',[1 1 1],...
  'DataAspectRatioMode','auto');

subplot(1,4,4)
hold on

errorbar(qua.summary.meanpos,qua.summary.meanvel,qua.summary.stdvel,qua.summary.stdvel,'k^','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[1 1 1],'markeredgecolor','k');
errorbar(qux.summary.meanpos,qux.summary.meanvel,qux.summary.stdvel,qux.summary.stdvel,'k^','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[0 0 0],'markeredgecolor','k');
errorbar(quz.summary.meanpos,quz.summary.meanvel,quz.summary.stdvel,quz.summary.stdvel,'k^','linestyle','-','color',[.6 .6 .6],'markerfacecolor',[.5 .5 .5],'markeredgecolor','k');

set(gca,'tickdir','out',...
  'box','off',...
  'xlim',[0 10],'xtick',[0 5 10], ...
  'ylim',[5 25],'ytick',[5 10 15 20 25], ...
  'PlotBoxAspectRatio',[1 1 1],...
  'DataAspectRatioMode','auto');


%%%%%%%%%%%%%%%%%%%%%%
% summary statistics %
%%%%%%%%%%%%%%%%%%%%%%

% disp(['pu 1d jump a vs. x ' num2str(myttest(pua.summary.a.vel,pux.summary.a.vel))])
% disp(['pu 1d jump a vs. z ' num2str(myttest(pua.summary.a.vel,puz.summary.a.vel))])
% disp(['pu 9d jump a vs. x ' num2str(myttest(pua.summary.c.vel,pux.summary.c.vel))])
% disp(['pu 9d jump a vs. z ' num2str(myttest(pua.summary.c.vel,puz.summary.c.vel))])
% 
% disp(['mo 1d jump a vs. x ' num2str(myttest(moa.summary.a.vel,mox.summary.a.vel))])
% disp(['mo 1d jump a vs. z ' num2str(myttest(moa.summary.a.vel,moz.summary.a.vel))])
% disp(['mo 9d jump a vs. x ' num2str(myttest(moa.summary.c.vel,mox.summary.c.vel))])
% disp(['mo 9d jump a vs. z ' num2str(myttest(moa.summary.c.vel,moz.summary.c.vel))])
% 
% disp(['cb 1d jump a vs. x ' num2str(myttest(cba.summary.a.vel,cbx.summary.a.vel))])
% disp(['cb 1d jump a vs. z ' num2str(myttest(cba.summary.a.vel,cbz.summary.a.vel))])
% disp(['cb 9d jump a vs. x ' num2str(myttest(cba.summary.c.vel,cbx.summary.c.vel))])
% disp(['cb 9d jump a vs. z ' num2str(myttest(cba.summary.c.vel,cbz.summary.c.vel))])
% 
% disp(['qu 1d jump a vs. x ' num2str(myttest(qua.summary.a.vel,qux.summary.a.vel))])
% disp(['qu 1d jump a vs. z ' num2str(myttest(qua.summary.a.vel,quz.summary.a.vel))])
% disp(['qu 9d jump a vs. x ' num2str(myttest(qua.summary.c.vel,qux.summary.c.vel))])
% disp(['qu 9d jump a vs. z ' num2str(myttest(qua.summary.c.vel,quz.summary.c.vel))])
% 
% 
% 

% size = [cbx.summary.full.size,cba.summary.full.size,cbz.summary.full.size,...
%   mox.summary.full.size,moa.summary.full.size,moz.summary.full.size,...
%   pux.summary.full.size,pua.summary.full.size,puz.summary.full.size,...
%   qux.summary.full.size,qua.summary.full.size,quz.summary.full.size];
% 
% speed = [repmat('a',length(cbx.summary.full.size),1);repmat('b',length(cba.summary.full.size),1);repmat('c',length(cbz.summary.full.size),1);...
%   repmat('a',length(mox.summary.full.size),1);repmat('b',length(moa.summary.full.size),1);repmat('c',length(moz.summary.full.size),1);...
%   repmat('a',length(pux.summary.full.size),1);repmat('b',length(pua.summary.full.size),1);repmat('c',length(puz.summary.full.size),1);...
%   repmat('a',length(qux.summary.full.size),1);repmat('b',length(qua.summary.full.size),1);repmat('c',length(quz.summary.full.size),1)]';
% 
% y = [cbx.summary.full.veldata,cba.summary.full.veldata,cbz.summary.full.veldata,...
%   mox.summary.full.veldata,moa.summary.full.veldata,moz.summary.full.veldata,...
%   pux.summary.full.veldata,pua.summary.full.veldata,puz.summary.full.veldata,...
%   qux.summary.full.veldata,qua.summary.full.veldata,quz.summary.full.veldata];
% [p jnk stats] = anovan(y,{speed,size},'varnames',{'Speed','size'},'model','full','sstype',3);
% multcompare(stats);
