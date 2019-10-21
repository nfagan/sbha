function [rt, tf] = saccade_based_rt(t, start_stops, ib_left, ib_right, is_left)

validateattributes( start_stops, {'double'}, {}, mfilename, 'start_stop indices' );

rt = nan;
tf = false;

if ( isempty(start_stops) )
  return
end

first_saccade_stop = start_stops(1, 2);

is_left_stop = is_left && ib_left(first_saccade_stop);
is_right_stop = ~is_left && ib_right(first_saccade_stop);

% saccade to left or right
if ( is_left_stop || is_right_stop )
  rt = t(first_saccade_stop);
  tf = true;
end

end