function out = recalculate_rt_gaze(files, varargin)

defaults = sbha.make.defaults.recalculate_rt_gaze();

params = sbha.parsestruct( defaults, varargin );

edf_trials_file = shared_utils.general.get( files, 'rt_target_onset' );
labels_file = shared_utils.general.get( files, 'labels' );
unified_file = shared_utils.general.get( files, 'unified' );

labels = make_labels( labels_file );
[x, y, t] = extract_samples( edf_trials_file, params );

assert_ispair( x, labels );
assert_ispair( y, labels );

left_rect = left_target_bounds( unified_file );
right_rect = right_target_bounds( unified_file );

mask = findor( labels, {'selected-left', 'selected-right'} );

rt = nan( rows(x), 1 );

for i = 1:numel(mask)  
  j = mask(i);
  choice_direction = current_choice_direction( labels, j );
  
  x_ = x(j, :);
  y_ = y(j, :);
  
  start_stops = sbha.find_saccades( x_, y_ ...
    , 'saccade_velocity_threshold', params.saccade_velocity_threshold ...
    , 'duration_samples_threshold', params.duration_samples_threshold ...
  );
  
  rt(j) = one_trial( x_, y_, start_stops, t, choice_direction, left_rect, right_rect, params );
end

compare_rt = columnize( [unified_file.DATA.rt] ) * 1e3;  % to ms.

out = struct();
out.identifier = unified_file.identifier;
out.gaze_rt = rt;
out.original_rt = compare_rt;
out.x = x;
out.y = y;
out.t = t;
out.labels = labels;
out.left_rect = repmat( left_rect(:)', rows(labels), 1 );
out.right_rect = repmat( right_rect(:)', rows(labels), 1 );

end

function labels = make_labels(labels_file)

labels = fcat.from( labels_file );
trials = arrayfun( @(x) sprintf('trial-%d', x), 1:rows(labels), 'un', 0 );
addsetcat( labels, 'trial-number', trials );

end

function compare_rts(gaze, mat, labels)

gaze_labs = addsetcat( labels', 'method', 'gaze' );
task_labs = addsetcat( labels', 'method', 'task' );

rt = [ gaze; mat ];
append( gaze_labs, task_labs );

pl = plotlabeled.make_common();
pl.hist_add_summary_line = true;

mask = findnone( gaze_labs, 'selected-none' );

axs = pl.hist( rt(mask), gaze_labs(mask), {'method', 'congruency', 'selected-direction'}, 20 );

d = 10;

end

function [x, y, t] = extract_samples(edf_trials_file, params)

[x, y, t] = sbha.extract_edf_trials_samples( edf_trials_file, params.t_window );

end

function rt = one_trial(x, y, saccade_stop_starts, t, choice_direction, left_bounds, right_bounds, params)

assert( t(1) == 0, 'Expected first time point to be 0; was %d', t(1) );

ib_left = bfw.bounds.rect( x, y, left_bounds );
ib_right = bfw.bounds.rect( x, y, right_bounds );

left_choice = strcmp( choice_direction, 'left' );
right_choice = strcmp( choice_direction, 'right' );
assert( xor(left_choice, right_choice), 'Expected left or right choice.' );

first_ib_left = find( ib_left, 1 );
first_ib_right = find( ib_right, 1 );

[rt, tf] = check_in_bounds_zero_case( t, first_ib_left, first_ib_right, left_choice );

if ( tf )
  return;
end

[rt, tf] = check_saccade_case( saccade_stop_starts, ib_left, ib_right, left_choice, t );

% Okay -- got saccade-based rt.
if ( tf )
  return
end

% Otherwise, use time of first entry into target.
if ( left_choice && ~isempty(first_ib_left) )
  rt = t(first_ib_left);
elseif ( right_choice && ~isempty(first_ib_right) )
  rt = t(first_ib_right);
else
  rt = nan;
end

end

function [rt, tf] = check_in_bounds_zero_case(t, first_ib_left, first_ib_right, left_choice)

is_first_left = ~isempty( first_ib_left ) && ...
  (isempty(first_ib_right) || first_ib_left < first_ib_right);
is_first_right = ~isempty( first_ib_right ) && ...
  (isempty(first_ib_left) || first_ib_right < first_ib_left);

tf = true;

if ( left_choice && is_first_left )
  rt = t(first_ib_left);
  
elseif ( ~left_choice && is_first_right )
  rt = t(first_ib_right);
  
else
  rt = nan;
  tf = false;
end

end

function [rt, tf] = check_saccade_case(start_stops, ib_left, ib_right, is_left, t)

[rt, tf] = sbha.saccade_based_rt( t, start_stops{1}, ib_left, ib_right, is_left );

end

function r = right_target_bounds(unified_file)

right_target = unified_file.opts.STIMULI.right_image1.targets{1};
r = right_target.bounds + right_target.padding;
  
end

function r = left_target_bounds(unified_file)

left_target = unified_file.opts.STIMULI.left_image1.targets{1};
r = left_target.bounds + left_target.padding;
  
end

function c = current_choice_direction(labels, i)

assert( numel(i) == 1 );

selected_dir = char( cellstr(labels, 'selected-direction', i) );
directions = { 'left', 'right' };
match_ind = cellfun( @(x) contains(selected_dir, x), directions );
assert( nnz(match_ind) == 1, 'Expected 1 direction to match for "%s".', selected_dir );

c = directions(match_ind);

end