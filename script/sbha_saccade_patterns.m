function outs = sbha_saccade_patterns(files, varargin)

defaults = sbha_saccade_patterns_defaults();
params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;

edf_trials_file = shared_utils.general.get( files, event_name );
edf_events_file = shared_utils.general.get( files, 'edf_events' );
labels_file = shared_utils.general.get( files, 'labels' );
un_file = shared_utils.general.get( files, 'unified' );

labs = fcat.from( labels_file );
key = edf_trials_file.key;

x = squeeze( edf_trials_file.aligned(:, :, key('x')) );
y = squeeze( edf_trials_file.aligned(:, :, key('y')) );
t = edf_trials_file.t;

[cue_onset_event, target_onset_event] = get_start_stop_event_indices( edf_events_file, un_file, params );
[start_times, stop_times] = get_start_stop_times( edf_events_file, cue_onset_event, target_onset_event, params );

l_image = un_file.opts.STIMULI.left_image1.vertices;
r_image = un_file.opts.STIMULI.right_image1.vertices;

is_ib_left = rect_bounds( l_image, x, y );
is_ib_right = rect_bounds( r_image, x, y );

saccade_pattern_cat = 'saccade-pattern';
addcat( labs, saccade_pattern_cat );

for i = 1:rows(x)
  left_starts = shared_utils.logical.find_all_starts( is_ib_left(i, :) );
  right_starts = shared_utils.logical.find_all_starts( is_ib_right(i, :) );
  
  is_within_t = t >= start_times(i) & t <= stop_times(i);
  within_bounds_ts = t(is_within_t);
  
  min_t = min( within_bounds_ts );
  max_t = max( within_bounds_ts );
  
  left_starts(left_starts > max_t | left_starts < min_t) = [];
  right_starts(right_starts > max_t | right_starts < min_t) = [];
  
  n_left = numel( left_starts );
  n_right = numel( right_starts );
  
  is_direct_saccade = n_left > 0 && n_right == 0 || n_left == 0 && n_right > 0;
  
  congruent_dir = partcat( labs, 'correct-direction', i );
  is_right = strcmp( congruent_dir, 'correct-right' );
  is_left = strcmp( congruent_dir, 'correct-left' );
  
  assert( is_right || is_left, 'Unrecognized direction: "%s".', char(congruent_dir) );
  
%   congruent_dir = partcat( labs, 'congruent-direction', i );
%   is_right = strcmp( congruent_dir, 'congruent-left' );
%   is_left = strcmp( congruent_dir, 'congruent-right' );
%   
%   if ( ~strcmp(congruent_dir, 'congruent-two') )
%     assert( is_right || is_left, 'Unrecognized direction: "%s".', char(congruent_dir) );
%   end
  
  if ( is_direct_saccade )
    is_correct_dir = is_left && n_left > 0 || is_right && n_right > 0;
    
    label = ternary( is_correct_dir, 'direct-correct', 'direct-incorrect' );
  else
    [is_antisaccade, anti_first_direction] = check_is_antisaccade( left_starts, right_starts );
    
    % Anti-saccade begins with saccade to incorrect (opposite) direction.
    is_begin_incorrect = is_left && strcmp(anti_first_direction, 'right') || ...
      is_right && strcmp(anti_first_direction, 'left');
    
    if ( is_antisaccade && is_begin_incorrect )
      label = 'anti-saccade';
    else
      label = 'other-saccade';
    end
  end
  
  setcat( labs, saccade_pattern_cat, label, i );
end

outs = struct();
outs.labels = labs;

end

function [start_ind, stop_ind] = get_start_stop_event_indices(edf_events_file, un_file, params)

task_type = un_file.opts.STRUCTURE.task_type;

is_rt_task = strcmp( task_type, 'rt' );

if ( is_rt_task )
  start_ind = edf_events_file.event_key('cue_onset');
  
  if ( params.use_end_event )
    stop_ind = edf_events_file.event_key(params.end_event_name);
  else
    stop_ind = edf_events_file.event_key('rt_target_onset');
  end
else
  error( 'Function is not defined for task_type: "%s".', task_type );
end

end

function [start_times, stop_times] = get_start_stop_times(edf_events_file, start_event_index, stop_event_index, params)

event_index = edf_events_file.event_key(params.event_name);
time_offsets = params.time_offsets;

absolute_start_time = edf_events_file.events(:, start_event_index);
absolute_stop_time = edf_events_file.events(:, stop_event_index);
event_time = edf_events_file.events(:, event_index);

start_times = round( absolute_start_time - event_time );
stop_times = round( absolute_stop_time - event_time );

if ( ~isempty(time_offsets) )
  start_times = start_times + time_offsets(1);
  stop_times = stop_times + time_offsets(2);
end

end

function ib = rect_bounds(r, x, y)

ib = x >= r(1) & x <= r(3) & y >= r(2) & y <= r(4);

end

function [tf, start_direction] = check_is_antisaccade(left, right)

n_left = numel( left );
n_right = numel( right );

tf = false;
start_direction = ternary( min(left) < min(right), 'left', 'right' );

if ( n_left == 0 || n_right == 0 )
  return
elseif ( n_left == 1 && n_right == 1 )
  tf = true;
  return
end

is_left = false( 1, n_left + n_right );
is_left(1:n_left) = true;
combined = [ left(:)', right(:)' ];

[combined, sorted_index] = sort( combined );
permuted_is_left = is_left(sorted_index);

[start_indices, durs] = shared_utils.logical.find_all_starts( permuted_is_left );

% More than one switch between left and right, so not an antisaccade
if ( numel(start_indices) > 1 )
  return
end

% Look left is either the first fixation, or the last fixation. Otherwise,
% there's a switching behavior.
tf = start_indices == 1 || start_indices + durs - 1 == numel( combined );

end