%
%
%       by: david schoppik
%     date: 4/8/05
%  purpose: to turn the output of pull into something that I can plot
%   usage: r = prepforfig2(r,experimenttype)
% calls myregress

function [r] = preptypeh(r)

if nargin == 0
  help simplify
  return;
end

% get rid of existing values from the last time we ran this program; this
% was helpful during debugging
if isfield(r,'summary')
  r = rmfield(r,'summary');
end

% some variables
cutoff = 50; % duration of time

%%%%%%%%%%%%
% raw data %
%%%%%%%%%%%%

ind = find(r.mot > cutoff & (r.newdir == 'u' | r.newdir == 'd'));
uind = find(r.mot > cutoff & r.newdir == 'u');
dind = find(r.mot > cutoff & r.newdir == 'd');

% all of the positions (for horizontal data only)
r.summary.full.posdata = (r.pos.r(ind));
r.summary.full.veldata = (r.data.post(4,ind));

% other variables to regress on
r.summary.full.saclen = r.sac.len(ind);
r.summary.full.saclat = r.sac.lat(ind);
r.summary.full.sacx = r.sac.x(ind);
r.summary.full.sacy = r.sac.y(ind);
r.summary.full.mot = r.mot(ind);
r.summary.full.type = r.jumptype(ind);
r.summary.full.size = r.summary.full.type;

r.summary.full.size(find(r.summary.full.type == 1 | r.summary.full.type == 2)) = 1;
r.summary.full.size(find(r.summary.full.type == 3 | r.summary.full.type == 4)) = 2;
r.summary.full.size(find(r.summary.full.type == 5 | r.summary.full.type == 6)) = 3;

r.summary.full.side = r.newdir(ind);

%%%%%%%%%%%%%%%
% by jumptype %
%%%%%%%%%%%%%%%

% lets keep all the horizontal stuff out
side = ['d' 'u' 'd' 'u' 'd' 'u'];


for i = 1:6
  % if we're only looking at trials where the target went right or left, and sorting by the type
  % of jump, then we should be fine using the hvel values for the "new" and
  % the vvel values for the "old" eye velocities
  r.summary.full.meanvel(i) = mean(r.data.post(4,find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i))));
  r.summary.full.meanpos(i) = mean(r.pos.r(find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i))));

  r.summary.full.stdvel(i) = std(r.data.post(4,find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i))));
  r.summary.full.stevel(i) = std(r.data.post(4,find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i)))) ./ ...
    sqrt(length(r.data.post(4,find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i))))-1);
  r.summary.full.stdpos(i) = std(r.pos.r(find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i))));
  r.summary.full.stepos(i) = std(r.pos.r(find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i)))) ./ ...
    sqrt(length(r.pos.r(find(r.mot > cutoff & r.jumptype == i & r.newdir == side(i))))-1);
end


%%%%%%%%%%%%%%%%%%%%%
% data by jump size %
%%%%%%%%%%%%%%%%%%%%%

inda = find(r.mot > cutoff & (r.newdir == 'u' | r.newdir == 'd') & r.jumptype <= 2);
indb = find(r.mot > cutoff & (r.newdir == 'u' | r.newdir == 'd') & (r.jumptype == 3 | r.jumptype == 4));
indc = find(r.mot > cutoff & (r.newdir == 'u' | r.newdir == 'd') & r.jumptype >= 5);

r.summary.a.pos = r.pos.r(inda);
r.summary.a.meanpos = mean(r.summary.a.pos);
r.summary.a.stdpos = std(r.summary.a.pos);
r.summary.a.stepos = std(r.summary.a.pos)/sqrt(length(r.summary.a.pos)-1);

r.summary.a.vel = abs(r.data.post(4,inda));
r.summary.a.oldvel = abs(r.data.post(3,inda));
r.summary.a.meanvel = mean(r.summary.a.vel);
r.summary.a.oldmeanvel = mean(r.summary.a.oldvel);
r.summary.a.stdvel = std(r.summary.a.vel);
r.summary.a.stevel = std(r.summary.a.vel)/sqrt(length(r.summary.a.vel)-1);
r.summary.a.oldstdvel = std(r.summary.a.oldvel);

r.summary.a.lat = r.sac.lat(inda);
r.summary.a.sacr = r.sac.r(inda);
r.summary.a.sacx = (r.sac.x(inda));
r.summary.a.sacy = (r.sac.y(inda));
r.summary.a.mot = r.mot(inda);

r.summary.b.pos = r.pos.r(indb);
r.summary.b.meanpos = mean(r.summary.b.pos);
r.summary.b.stdpos = std(r.summary.b.pos);
r.summary.b.stepos = std(r.summary.b.pos)/sqrt(length(r.summary.b.pos)-1);

r.summary.b.vel = abs(r.data.post(4,indb));
r.summary.b.oldvel = abs(r.data.post(3,indb));
r.summary.b.meanvel = mean(r.summary.b.vel);
r.summary.b.oldmeanvel = mean(r.summary.b.oldvel);
r.summary.b.stdvel = std(r.summary.b.vel);
r.summary.b.stevel = std(r.summary.b.vel)/sqrt(length(r.summary.b.vel)-1);
r.summary.b.oldstdvel = std(r.summary.b.oldvel);

r.summary.b.lat = r.sac.lat(indb);
r.summary.b.sacr = r.sac.r(indb);
r.summary.b.sacx = (r.sac.x(indb));
r.summary.b.sacy = (r.sac.y(indb));
r.summary.b.mot = r.mot(indb);

r.summary.c.pos = r.pos.r(indc);
r.summary.c.meanpos = mean(r.summary.c.pos);
r.summary.c.stdpos = std(r.summary.c.pos);
r.summary.c.stepos = std(r.summary.c.pos)/sqrt(length(r.summary.c.pos)-1);

r.summary.c.vel = abs(r.data.post(4,indc));
r.summary.c.oldvel = abs(r.data.post(3,indc));
r.summary.c.meanvel = mean(r.summary.c.vel);
r.summary.c.oldmeanvel = mean(r.summary.c.oldvel);
r.summary.c.stdvel = std(r.summary.c.vel);
r.summary.c.stevel = std(r.summary.c.vel)/sqrt(length(r.summary.c.vel)-1);
r.summary.c.oldstdvel = std(r.summary.c.oldvel);

r.summary.c.lat = r.sac.lat(indc);
r.summary.c.sacr = r.sac.r(indc);
r.summary.c.sacx = (r.sac.x(indc));
r.summary.c.sacy = (r.sac.y(indc));
r.summary.c.mot = r.mot(indc);

r.summary.meanpos = [r.summary.a.meanpos r.summary.b.meanpos r.summary.c.meanpos];
r.summary.stdpos = [r.summary.a.stdpos r.summary.b.stdpos r.summary.c.stdpos];
r.summary.stepos = [r.summary.a.stepos r.summary.b.stepos r.summary.c.stepos];

r.summary.oldmeanvel = [r.summary.a.oldmeanvel r.summary.b.oldmeanvel r.summary.c.oldmeanvel];
r.summary.oldstdvel = [r.summary.a.oldstdvel r.summary.b.oldstdvel r.summary.c.oldstdvel];

r.summary.meanvel = [r.summary.a.meanvel r.summary.b.meanvel r.summary.c.meanvel];
r.summary.stdvel = [r.summary.a.stdvel r.summary.b.stdvel r.summary.c.stdvel];
r.summary.stevel = [r.summary.a.stevel r.summary.b.stevel r.summary.c.stevel];

r.summary.mot = [r.summary.a.mot r.summary.b.mot r.summary.c.mot];
r.summary.pos = [r.summary.a.pos r.summary.b.pos r.summary.c.pos];
r.summary.vel = [r.summary.a.vel r.summary.b.vel r.summary.c.vel];
r.summary.oldvel = [r.summary.a.oldvel r.summary.b.oldvel r.summary.c.oldvel];
r.summary.lat = [r.summary.a.lat r.summary.b.lat r.summary.c.lat];

r.summary.sacx = abs([r.summary.a.sacx r.summary.b.sacx r.summary.c.sacx]);
r.summary.sacy = abs([r.summary.a.sacy r.summary.b.sacy r.summary.c.sacy]);


%%%%%%%%%%%%%%
% statistics %
%%%%%%%%%%%%%%

% 1. are the distributions of velocity for left and right different?
%    they should be, given that ordinarily, responses to left and right are
%    different -- this isn't really work talking about

% 2. are the slopes of the regression line for all the trials significantly
%    different from zero? (y = velocity, x = position)

[r.stats.slope r.stats.yint jnk r.stats.pslope r.stats.pyint] = myregress(r.summary.pos',r.summary.vel');
[r.stats.oldslope r.stats.oldyint jnk r.stats.oldpslope r.stats.oldpyint] = myregress(r.summary.pos',r.summary.oldvel');

% 3. is adding the duration of motion useful?
%
r.stats.motmodel = regstats(r.summary.vel',[r.summary.pos' r.summary.mot']);

% 4. are the distributions of latencies different for the three jump sizes,
%    given that the jumps are to different sides?
%    if the r.stats.lat value is less that pcrit, then re-run this by hand
%    to examine the values.

[r.stats.lat t stats] = anovan(r.summary.full.mot,{r.summary.full.size,r.summary.full.side},'display','off');
