%
%
%       by: david schoppik
%     date: 4/8/05
%  purpose: to turn the output of pull into something that I can plot
%   usage: r = prepforfig3(r,experimenttype)
%
%   for type t, what we need to know is the following:
%   is there a difference in the post-saccadic eye velocity for type 1 and
%   type 2?  type 2 will jump away from the fovea, type 1 will jump towards
%   the fovea.


function [r] = prepforfig3(r)

if nargin == 0
  help simplify
  return;
end

% get rid of existing values from the last time we ran this program; this
% was helpful during debugging
if isfield(r,'summary')
  r = rmfield(r,'summary');
end

if isfield(r,'stats')
  r = rmfield(r,'stats');
end

% some variables
cutoff = 0; % duration of time

%%%%%%%%%%%%
% raw data %
%%%%%%%%%%%%

% because there are different velocities of interest, resort the data

rinda = find(r.mot > cutoff & r.olddir == 'r' & r.jumptype == 1);
linda = find(r.mot > cutoff & r.olddir == 'l' & r.jumptype == 1);
dinda = find(r.mot > cutoff & r.newdir == 'd' & r.jumptype == 1);
uinda = find(r.mot > cutoff & r.newdir == 'u' & r.jumptype == 1);

rindb = find(r.mot > cutoff & r.olddir == 'r' & r.jumptype == 2);
lindb = find(r.mot > cutoff & r.olddir == 'l' & r.jumptype == 2);
dindb = find(r.mot > cutoff & r.newdir == 'd' & r.jumptype == 2);
uindb = find(r.mot > cutoff & r.newdir == 'u' & r.jumptype == 2);


r.summary.a.prevel = ([r.data.pre(3,rinda) -r.data.pre(3,linda), r.data.pre(4,uinda) -r.data.pre(4,dinda)]);
r.summary.a.vel = ([r.data.post(3,rinda) -r.data.post(3,linda), r.data.post(4,uinda) -r.data.post(4,dinda)]);
r.summary.a.pos = [r.pos.pre.r(rinda) r.pos.pre.r(linda) r.pos.pre.r(uinda) r.pos.pre.r(dinda)];
r.summary.a.mot = [r.mot(rinda) r.mot(linda), r.mot(uinda) r.mot(dinda)];

r.summary.b.prevel = ([r.data.pre(3,rindb) -r.data.pre(3,lindb), r.data.pre(4,uindb) -r.data.pre(4,dindb)]);
r.summary.b.vel = ([r.data.post(3,rindb) -r.data.post(3,lindb), r.data.post(4,uindb) -r.data.post(4,dindb)]);
r.summary.b.pos = [r.pos.pre.r(rindb) r.pos.pre.r(lindb) r.pos.pre.r(uindb) r.pos.pre.r(dindb)];
r.summary.b.mot = [r.mot(rindb) r.mot(lindb), r.mot(uindb) r.mot(dindb)];

%%%%%%%%%%%%%%
% statistics %
%%%%%%%%%%%%%%

% We'll fit the time courses as exponentials, and then get 95% confidence
% intervals.  To seed nlinfit, we'll fit the exponentials as if they were
% lines.
[s y] = myregress(r.summary.a.mot,log(abs(r.summary.a.vel)));

[r.stats.a.beta res jac] = nlinfit(r.summary.a.mot,r.summary.a.vel,'exponential',[y s]);
[r.stats.a.ci] = nlparci(r.stats.a.beta,res,jac);


[s y] = myregress(r.summary.b.mot,log(abs(r.summary.b.vel)));

[r.stats.b.beta res jac] = nlinfit(r.summary.b.mot,r.summary.b.vel,'exponential',[y s]);
[r.stats.b.ci] = nlparci(r.stats.b.beta,res,jac);

