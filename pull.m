% pull.m
%
%
%       by: david schoppik
%     date: 10/16/04
%  purpose: to select and parse trials for plotting
%
%
%   usage: r = pull(in,trialtype)
%
%  in is a structure containing the info from multiple days made of:
%  in.dir (the full path to the trials)
%  in.exp (the experiment; always a single letter)
%
% this parses the trials and filters out the ones that don't meet the
% proper criteria.  It puts the trial values into a structure for analysis.
%
%   calls: readcxdata, digitaldiff, getlastdir
%
% some notes on the naming convention for trials:
% the first letter indicates the type of experiment
% the second letter is the original direction of motion
% the third number designates the size of the displacement (1,5, or 9d) and
% its direction (odds went one way, evens the other)
% ex: s.r.1
% trials of type 's' have a target move 90d orthogonally to the original
% direction of motion
% 'r' means that the target started moving right
% 1 means that the motion after the jump was downward (orthogonal to the
% direction of motion, and signed negative, or downward, by convention)
%
% the convention is true for everything EXCEPT the trials with two targets.
% there, the two letters describe the two directions the targets moved.
% the second of the two letters describes the motion of the target that
% changes, and the number the direction of the post-change motion.
% these trials were always paired (ex. u.d.* with d.u.*)
%
% prepforfig*.m will parse things appropriately for plotting
% where the * refers to the appropriate figure number
% 


function [r] = pull(in,trialtype)
switch nargin
  case 1
    trialtype = 's';
  case 0
   help pull
  return;
end

% important default variables

tta = 20; % how much time after the saccade do you average for the single point analysis?
veclen = 100; % for a temporal analysis, how much data to take?
spatcutoff = 1.0; % how far off the meridian can a saccade be (deg)?
minmottime = -50; % minimum duration of new motion (ms)
maxmottime = 100; % max duration of new motion (ms)
maxdelay = 200; % max time between first saccade and corrective saccade (ms)
maxsaclen = 105; % what is the longest possible saccade duration (to get rid of biphasic saccades
realsacend = 0; % offset to add to the marked end of the saccade

poscal = 40;  % changes V to deg (based on a 12-bit A/D converter)
velcal = 10.8826; % changes V to deg/s
calibmat = [poscal poscal velcal velcal]'; % file default is HEPOS VEPOS HEVEL VEVEL
[num,denom] = butter(2,25/500); % 25Hz digital filter -- used to generate the velocity traces

verbose = 1; % used during coding for error-checking

% a few indices
expind = 1;
ctrind = 1;
rejind = 0;
totnumtrials = 0;
keepers = 0;
trialcounter = 0;
notjump = 0;

for k=1:length(in.exp)
  cd(in.dir(k,:));
  directory = pwd;
  experiment = in.exp(k);

  % set up the names
  trialbasename = [getlastdir(pwd) experiment];

  numtrials = 0;
  files=dir(directory);

  for i=1:length(files)
    if strcmp(files(i).name(min(length(files(i).name),9)),experiment) && ~strcmp(files(i).name(2:3),'DS')
      numtrials = numtrials +1;
    end
  end

  if verbose
    disp(['Number of trials in ' trialbasename ' is ' num2str(numtrials)])
  end

  for i=1:numtrials

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% evaluate a trial %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in the trial data
    trialdata = readcxdata(strcat(trialbasename,sprintf('.%04d',i)));

    if ~isempty(trialtype) % is it the type of experiment we're sorting?
      switch trialtype
        case {'u','d'} % two target experiments are either u.d or d.u
          if trialdata.trialname(1) ~= 'u' & trialdata.trialname(1) ~= 'd'
            continue;
          end
        otherwise
          if trialdata.trialname(1) ~= trialtype
            continue;
          end
      end
    end

    if isempty(trialdata.mark1)  % did I miss a mark somewhere?
      disp([num2str(i),' mark1']) % show me the number so I can go back and fix it
      continue;
    end

   
    
    if trialdata.mark1(1) == -1 % if the trial is already defined as a reject
      rejind = rejind +1;
      continue;
    end

    if isempty(trialdata.mark2)  % did I miss an end-of-saccade mark somewhere?
      disp([num2str(i),' mark2']) % show me the number so I can go back and fix it
      continue;
    end

    % keep track of the trials
    totnumtrials = totnumtrials + 1;
      
    
    % set up the eye data matrix
    % rows 1 & 2 are position, rows 3 & 4 are velocity 
    % (horizontal then vertical)
    % digitally differentiate and filter the eye position to get velocity
    eyedata = [trialdata.data(1:2,:) ./ repmat(calibmat(1:2),1,length(trialdata.data(1,:)))];
    eyedata(3,:) = filtfilt(num,denom,digitaldiff(trialdata.data(1,:),.001,1))./40;
    eyedata(4,:) = filtfilt(num,denom,digitaldiff(trialdata.data(2,:),.001,1))./40;

    % get rid of any fixed offset present in the hardware
    eyedata = eyedata - repmat(mean((eyedata(1:4,1:200)),2),1,length(eyedata(1,:)));

    % filter the position data
    for j=1:2, eyedata(j,:) = filtfilt(num,denom,eyedata(j,:)); end

    % use the calculated target positions, as they were sent to the
    % stimulus display hardware, as an approximation of target
    % position in the world (galvonometer feedback was not always
    % available for recording)

    switch trialdata.trialname(1:3)
      case {'u.d','d.u'} % these trials had two targets
        switch trialdata.trialname(3)
          case {'u'}
            target = [trialdata.targets.hpos(2,:); trialdata.targets.vpos(2,:)];
          case {'d'}
            target = [trialdata.targets.hpos(1,:); trialdata.targets.vpos(1,:)];
        end
      otherwise
        target = [trialdata.targets.hpos(1,:); trialdata.targets.vpos(1,:)];
    end
    % what type of trial was it?
    trialtype = trialdata.trialname(1);
    jumptype = str2double(trialdata.trialname(5));
    targetstartdir = trialdata.trialname(3);

    % which way does the new motion go?
    % it seemed like a reasonable naming convention at the time....
    % this way, a positive "jumptype" should lead to positive values, in
    % keeping with our convention that right and up were both positive
    % my deepest apologies for anyone who struggles with this.
    switch trialdata.trialname(1)
      case {'s','h','y','u'} % change of 90d
        switch jumptype
          case {1,3,5}
            if targetstartdir == 'r' || targetstartdir == 'l'
              newmotiondir = 'd';
            elseif targetstartdir == 'u' || targetstartdir == 'd'
              newmotiondir = 'l';
            end
          case {2,4,6}
            if targetstartdir == 'r' || targetstartdir == 'l' 
              newmotiondir = 'u';
            elseif targetstartdir == 'u' || targetstartdir == 'd'
              newmotiondir = 'r';
            end
          case {0}
            newmotiondir = targetstartdir;
        end
      case {'a','x','z','t'} % no change in target direction
        newmotiondir = targetstartdir; % because there was no change in target direction
      case {'d'} % odds/evens switched here, change of 90d
        switch jumptype
          case {2,4,6}
            if targetstartdir == 'r' || targetstartdir == 'l' % < - !!!! check this?
              newmotiondir = 'd';
            elseif targetstartdir == 'u' || targetstartdir == 'd'
              newmotiondir = 'l';
            end
          case {1,3,5}
            if targetstartdir == 'r' || targetstartdir == 'l' 
              newmotiondir = 'u';
            elseif targetstartdir == 'u' || targetstartdir == 'd'
              newmotiondir = 'r';
            end
          case {0}
            newmotiondir = targetstartdir;
        end
      
      otherwise
        disp('improperly named trial')
        continue;
    end

    % get the saccade-related data
    sacstart = trialdata.mark1(1);
    sacend = trialdata.mark2(1)+realsacend;
    sac2 = 0;
    delay = nan;

    if length(trialdata.mark1) > 1 & length(trialdata.mark2) > 1
      if jumptype & trialdata.mark2(2) < length(trialdata.data(1,:))-(tta+1) % was there a second saccade?
        sac2 = 1;
        sac2start = trialdata.mark1(2);
        sac2end = min(trialdata.mark2(2)+realsacend,length(trialdata.data)-tta);
        delay = sac2start - sacend;
      elseif jumptype & trialtype == 's' % there wasn't a second, orienting saccade; skip this trial (for "s" only)
        rejind = rejind + 1;
        continue;
      end
    end

    % get the timing pulse-related data
    switch size(trialdata.other,1) 
      case {2,3}
        newmotionstart = trialdata.other(1,2);
      case {4}
        newmotionstart = trialdata.other(2,2);
      otherwise
        disp('improper number of pulses?')
        continue;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% rejecting trials %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%

    % restrict the motion time
    % we usually only want postive values here -- if he jumps before the change in
    % target motion, it can't tell us about processing that motion
    if sacstart - newmotionstart < minmottime & sacstart - newmotionstart < maxmottime
      rejind = rejind +1;
      continue;
    end

    % get rid of the saccades that go to the new position of the target
    % which in most cases, is simply off the meridian
    switch trialtype
      case {'s','h'} % the target jumps and changes direction; he must saccade first with the original motion, then second to the new motion 
        switch targetstartdir
          case {'l','r'} % if the target was a horizontal saccade
            if isnan(abs(mean(eyedata(2,sacend:min(end,sacend+tta))))) % this happened once b/c the start of the saccade was at the end of a trial
              disp(num2str(i))
              rejind = rejind + 1;
              continue;
            else
              if abs(mean(eyedata(2,sacend:min(end,sacend+tta)))) > spatcutoff % did he land on the meridian?
                rejind = rejind + 1;
                continue;
                %elseif jumptype & abs(mean(eyedata(2,sac2end:min(end,sac2end+tta)))) < spatcutoff % did he leave the meridian?
                %  rejind = rejind + 1;
                %  continue;
              end
            end
          case {'u','d'}
            if abs(mean(eyedata(1,sacend:sacend+tta))) > spatcutoff % did he land on the meridian
              rejind = rejind +1;
              continue;
            elseif jumptype & abs(mean(eyedata(1,sac2end:min(end,sac2end+tta)))) < spatcutoff % did he leave the meridian?
              rejind = rejind + 1;
              continue;
            end
        end

      case {'a','x','z'} % here the target continues in the same direction; he must saccade to the original motion
        switch targetstartdir
          case {'l','r'} % if the target was a horizontal saccade
            if isnan(abs(mean(eyedata(2,sacend:min(end,sacend+tta))))) % this happened once b/c the start of the saccade was at the end of a trial
              disp(num2str(i))
              rejind = rejind + 1;
              continue;
            else
              if abs(mean(eyedata(2,sacend:min(end,sacend+tta)))) > spatcutoff % did he land on the meridian?
                rejind = rejind + 1;
                continue;
              end
              
            end
          case {'u','d'}
            if abs(mean(eyedata(1,sacend:sacend+tta))) > spatcutoff % did he land on the meridian
              rejind = rejind +1;
              continue;
            end
        end
        
      case {'t'}
        % the initial target step here was either to (-3,-3) or (3,3) so the
        % absolute value of the endpoint of the saccade should be within
        % our cutoff plus 3 degrees regardless of the direction
        switch targetstartdir
          case {'d','l'} % the eye should saccade to (3,3)
            if mean(eyedata(1,sacend:min(end,sacend+tta))) < 3 - spatcutoff | ... % hpos was less than 3 - cutoff
                mean(eyedata(1,sacend:min(end,sacend+tta))) > 3 + spatcutoff | ... % hpos was more than 3 + cutoff
                mean(eyedata(2,sacend:min(end,sacend+tta))) < 3 - spatcutoff | ... % vpos was less than 3 - cutoff
                mean(eyedata(2,sacend:min(end,sacend+tta))) > 3 + spatcutoff       % vpos was more than 3 + cutoff
              rejind = rejind + 1;
              continue;
            end

          case {'u','r'} % the eyes should saccade to (-3,-3)
            if mean(eyedata(1,sacend:min(end,sacend+tta))) > -3 + spatcutoff | ... % hpos was less than -3 + cutoff
                mean(eyedata(1,sacend:min(end,sacend+tta))) < -3 - spatcutoff | ... % hpos was more than -3 - cutoff
                mean(eyedata(2,sacend:min(end,sacend+tta))) > -3 + spatcutoff | ... % vpos was less than -3 + cutoff
                mean(eyedata(2,sacend:min(end,sacend+tta))) < -3 - spatcutoff       % vpos was more than -3 - cutoff
              rejind = rejind +1;
              continue;
            end
        end
      case {'y'} 
        % the initial target stepped 3 degrees along the meridian
        switch targetstartdir
          case {'r'}
            if abs(mean(eyedata(2,sacend:sacend+tta))) > spatcutoff | ... % vpos was more than the cutoff
                abs(mean(eyedata(1,sacend:sacend+tta))) > 3 + spatcutoff | ... % hpos was more than 2 + cutoff
                abs(mean(eyedata(1,sacend:sacend+tta))) < 3 - spatcutoff % hpos was less than 2 - cutoff
              rejind = rejind + 1;
              continue;
            end
          case {'l'} 
            if abs(mean(eyedata(2,sacend:sacend+tta))) > spatcutoff | ... % vpos was more than the cutoff
                abs(mean(eyedata(1,sacend:sacend+tta))) > 3 + spatcutoff | ... % hpos was more than 2 + cutoff
                abs(mean(eyedata(1,sacend:sacend+tta))) < 3 - spatcutoff % hpos was less than 2 - cutoff
              rejind = rejind + 1;
              continue;
            end
        end
      case {'u','d'}
        % these are special, because they had two targets
        % first, we'll check if the target chosen was the one that switched
        % as only one of them could switch at a time
        % the "chosen" target is set as a flag, with "28" meaning target 2,
        % and "44" meaning target 1.  
        switch trialdata.key.flags
          case 28 
            if trialtype == 'u' % down was the one which changed direction
              rejind = rejind + 1;
              continue;
            end
          case 44 % target two (which moved up) was chosen
            if trialtype == 'd' % up was the one which changed direction
              rejind = rejind + 1;
              continue;
            end
          otherwise % he didn't choose a target in time
            rejind = rejind + 1;
            continue;
        end

        % now we can check to see if the saccade landed appropriately --
        % this was taken from type 's' which has similar requirements 
        switch targetstartdir
          case {'l','r'} % if the target was a horizontal saccade
            if isnan(abs(mean(eyedata(2,sacend:min(end,sacend+tta))))) % this happened once b/c the start of the saccade was at the end of a trial
              disp(num2str(i))
              rejind = rejind + 1;
              continue;
            else
              if abs(mean(eyedata(2,sacend:min(end,sacend+tta)))) > spatcutoff % did he land on the meridian?
                rejind = rejind + 1;
                continue;
                %elseif jumptype & abs(mean(eyedata(2,sac2end:min(end,sac2end+tta)))) < spatcutoff % did he leave the meridian?
                %  rejind = rejind + 1;
                %  continue;
              end
            end
          case {'u','d'}
            if abs(mean(eyedata(1,sacend:sacend+tta))) > spatcutoff % did he land on the meridian
              rejind = rejind +1;
              continue;
%             elseif jumptype & abs(mean(eyedata(1,sac2end:min(end,sac2end+tta)))) < spatcutoff % did he leave the meridian?
%               rejind = rejind + 1;
%               continue;
            end
        end

    end

    % get rid of biphasic saccades on experimental trials
    % this isn't an issue if saccades are marked on the position trace,
    % which they usually are
    if jumptype & delay < tta || ((sacend - sacstart) > maxsaclen)
      rejind = rejind +1;
      continue;
    end

    
    % was his eye where it was supposed to be (along the meridian) before
    % the saccade started?  if not, toss the trial.  this happens when the
    % monkey looks away during the grace period for fixation, then looks
    % back in time to catch the target.  pretty rare, but still important
    % to look out for.
    if abs(mean(eyedata(1,sacstart-tta:sacstart))) > spatcutoff || ...
        abs(mean(eyedata(2,sacstart-tta:sacstart))) > spatcutoff
      rejind = rejind + 1;
      continue;
    end

    % similarly, is his eye WAY off where it should have landed? <- TODO

    %%%%%%%%%%%%%%%%%%%%%%%
    %%%% output matrix %%%%
    %%%%%%%%%%%%%%%%%%%%%%%

    switch jumptype
      case {0} % a control trial
        r.c.type(ctrind) = trialdata.trialname(1);
        r.c.olddir(ctrind) = targetstartdir;
        r.c.data.pre(1:4,ctrind) = mean(eyedata(:,sacstart-tta:sacstart),2);
        r.c.data.post(1:4,ctrind) = mean(eyedata(:,sacend:sacend+tta),2);
        r.c.sac.len(ctrind) = sacend-sacstart;
        [r.c.sac.th(ctrind) r.c.sac.r(ctrind)] = cart2pol((r.c.data.post(1,ctrind) - r.c.data.pre(1,ctrind)), ...
          (r.c.data.post(2,ctrind) - r.c.data.pre(2,ctrind)));
        [r.c.sac.x(ctrind),r.c.sac.y(ctrind)] = pol2cart(r.c.sac.th(ctrind),r.c.sac.r(ctrind));
        r.c.sac.maxvel(ctrind) = max([abs(eyedata(3,sacstart:sacend)),abs(eyedata(4,sacstart:sacend))]);
        r.c.sac.lat(ctrind) = sacstart - 200;
        r.c.trialnum(ctrind,:) = strcat(trialbasename,sprintf('.%04d',i));
        if sac2
          r.c.sac.delay(ctrind) = delay;
          r.c.sac.lat2(ctrind) = sac2start-newmotionstart;
          r.c.data2.pre(1:4,ctrind) = mean(eyedata(:,sac2start-tta:sac2start),2);
          r.c.data2.post(1:4,ctrind) = mean(eyedata(:,sac2end:min(end,sac2end+tta)),2);
        else
          r.c.sac.delay(ctrind) = nan;
          r.c.sac.lat2(ctrind) = nan;
        end
        % take the vector after the saccade; pad the array with nans in case it isn't long
        % enough to fill it out (because of the second saccade):
        r.c.vec.post.data(ctrind,1:veclen,1:4) = nan;
        r.c.vec.post.data(ctrind,1:1+min(delay,min(veclen,length(eyedata)-sacend)),1:4) = eyedata(:,sacend:sacend+min(delay,min(veclen,end-sacend)))' ;
        r.c.vec.post.data(ctrind,1:1+min(delay,min(veclen,length(eyedata)-sacend)),1:4) = eyedata(:,round(newmotionstart):round(newmotionstart+min(delay,min(veclen,end-sacend))))' ;
        r.c.vec.post.time(ctrind,1:veclen) = nan;
        r.c.vec.post.time(ctrind,1:1+min(delay,veclen)) = round(sacend-newmotionstart):round(sacend-newmotionstart)+min(delay,veclen);


        ctrind = ctrind+1;


      case {1,2,3,4,5,6} % an experimental trial
        r.type(expind) = trialdata.trialname(1);
        r.olddir(expind) = targetstartdir;
        r.newdir(expind) = newmotiondir;
        r.jumptype(expind) = jumptype;
        r.data.pre(1:4,expind) = mean(eyedata(:,sacstart-tta:sacstart),2);
        r.data.velpre(1:4,expind) = mean(eyedata(:,sacstart-(tta+30):sacstart-30),2);
        r.data.post(1:4,expind) = mean(eyedata(:,sacend:sacend+tta),2);
        r.sac.len(expind) = sacend-sacstart;
        
        r.pos.x(expind) = (target(1,sacend) - eyedata(1,sacend));
        r.pos.y(expind) = (target(2,sacend) - eyedata(2,sacend));
        r.pos.r(expind) = sqrt(r.pos.x(expind).^2 + r.pos.y(expind).^2);
        
        r.pos.pre.x(expind) = (target(1,sacstart) - eyedata(1,sacstart));
        r.pos.pre.y(expind) = (target(2,sacstart) - eyedata(2,sacstart));
        r.pos.pre.r(expind) = sqrt(r.pos.pre.x(expind).^2 + r.pos.pre.y(expind).^2);
        
        [r.sac.th(expind) r.sac.r(expind)] = cart2pol((r.data.post(1,expind) - r.data.pre(1,expind)), ...
          (r.data.post(2,expind) - r.data.pre(2,expind)));
        [r.sac.x(expind),r.sac.y(expind)] = pol2cart(r.sac.th(expind),r.sac.r(expind));
        r.sac.maxvel(expind) = max([abs(eyedata(3,sacstart:sacend)),abs(eyedata(4,sacstart:sacend))]);
        r.sac.lat(expind) = sacstart - 200;
        r.proctime(expind) = round(sacend-newmotionstart);
        r.mot(expind) = round(sacstart - newmotionstart);
        r.trialnum(expind,:) =  strcat(trialbasename,sprintf('.%04d',i));

        % take the vector after the saccade; pad the array with nans in case it isn't long
        % enough to fill it out (because of the second saccade):
        r.vec.post.data(expind,1:veclen,1:4) = nan;
        r.vec.post.data(expind,1:1+min(delay,veclen),1:4) = eyedata(:,sacend:sacend+min(delay,veclen))' ;
        r.vec.post.time(expind,1:veclen) = nan;
        r.vec.post.time(expind,1:1+min(delay,veclen)) = round(sacend-newmotionstart):round(sacend-newmotionstart)+min(delay,veclen);

        if sac2
          r.sac.delay(expind) = delay;
          r.sac.lat2(expind) = sac2start-newmotionstart;
          r.data2.pre(1:4,expind) = mean(eyedata(:,sac2start-tta:sac2start),2);
          r.data2.post(1:4,expind) = mean(eyedata(:,sac2end:sac2end+tta),2);
        else
          r.sac.delay(expind) = nan;
          r.sac.lat2(expind) = nan;
        end
        expind = expind+1;
    end
  end
  
  if verbose
    
    keepers = expind-keepers;
    trialcounter = totnumtrials-trialcounter;
    disp(['Number of trials = ' num2str(totnumtrials)])
    disp(['Number of keepers in ' trialbasename ' is ' num2str(keepers)])
   end

  
end

if verbose
  disp(['Total number of trials = ' num2str(totnumtrials)])
  disp(['Total number of rejects = ' num2str(rejind)])
end



