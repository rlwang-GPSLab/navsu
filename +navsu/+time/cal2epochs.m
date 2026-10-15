function epochs = cal2epochs(yr,mn,dy,hr,min,sec)
% cal2epochs
% DESCRIPTION:
%   Convert from calendar date to GPS epoch (seconds since start of GPS
%   time)
% INPUT:
%   yr  = year      [Nx1]
%   mn  = month     [Nx1]
%   dy  = day       [Nx1]
%   hr  = hour      [Nx1]
%   min = minute    [Nx1]
%   sec = second    [Nx1]
% OUTPUT:
%   epochs = GPS epoch [Nx1]
%
% See also: navsu.time.epochs2cal

% Allow for single vector input
if nargin == 1 && size(yr,2) == 6
   mn  = double(yr(:,2));
   dy  = double(yr(:,3));
   hr  = double(yr(:,4));
   min = double(yr(:,5));
   sec = double(yr(:,6));
   yr  = double(yr(:,1));
end


jd = navsu.time.cal2jd(yr,mn,dy);
[gpsweek,sow] = navsu.time.jd2gps(jd);
epochs = gpsweek*86400*7+sow+hr*3600+min*60+sec;

end