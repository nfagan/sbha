function outs = sbha_binned_position_frequency_timecourse(files, varargin)

defaults = sbha_binned_position_frequency_timecourse_defaults();

params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;
norm_to = validatestring( params.normalize_to, {'screen', 'cues', 'adjusted-cues'} ...
  , mfilename, 'normalize_to' );
match_time_window = params.lr_normalization_time_window;

conf = params.config;
  
if ( strcmp(norm_to, 'adjusted-cues') )
  validateattributes( match_time_window, {'numeric'}, {'numel', 2} ...
    , mfilename, 'lr_normalization_time_window' );
end

edf_events_file = shared_utils.general.get( files, 'edf_events' );
edf_trials_file = shared_utils.general.get( files, event_name );
labels_file = shared_utils.general.get( files, 'labels' );
un_file = shared_utils.general.get( files, 'unified' );

labs = fcat.from( labels_file );
key = edf_trials_file.key;
identifier = edf_events_file.identifier;
is_rt_task = strcmp( labs('task-type'), 'rt' );

x = squeeze( edf_trials_file.aligned(:, :, key('x')) );
y = squeeze( edf_trials_file.aligned(:, :, key('y')) );
t = edf_trials_file.t;

mask_time = nan;
targ_time = nan;

if ( is_rt_task )
  task_timings = un_file.opts.TIMINGS.time_in;

  mask_time = task_timings.rt_present_targets;
  targ_time = task_timings.pre_mask_delay + mask_time;

  mask_time = round( mask_time * 1e3 );
  targ_time = round( targ_time * 1e3 );
end

% Calculate (x, y) center of stimulus
center_func = @(x) [ mean(x.vertices([1, 3])), mean(x.vertices([2, 4])) ];

l_image = un_file.opts.STIMULI.left_image1;
r_image = un_file.opts.STIMULI.right_image1;

l_center = center_func( l_image );
r_center = center_func( r_image );
screen_size = un_file.opts.WINDOW.rect;

switch ( norm_to )
  case 'screen'
    min_x = screen_size(1);
    max_x = screen_size(3);
    
  case { 'cues', 'adjusted-cues' }
    min_x = l_center(1);
    max_x = r_center(1);
    
  otherwise
    error( 'Unrecognized normalization: "%s".', norm_to );
end

norm_func = @(x, min, max) (x - min) ./ (max - min);
norm_x = norm_func( x, min_x, max_x );

if ( strcmp(norm_to, 'adjusted-cues') )  
  norm_x = match_x_across_midline( norm_x, t, match_time_window );
end
  
if ( is_rt_task )
  sbha.label.rt_cue_target_direction( labs );
  sbha.label.rt_n_targets( labs );
else
  sbha.label.cnc_cue_target_direction( labs );
  sbha.label.cnc_n_targets( labs );
end

sbha.label.monkey_from_subject( labs );

if ( params.use_trial_selection_criterion )
  get_trial_selection_criterion( labs, identifier, conf );
end

[norm_roi_left, norm_roi_right] = get_normalized_cue_rois( l_image, r_image, min_x, max_x );

all_counts = [];
all_labs = fcat();
collapsed_dir_cat = 'collapsed-cue-direction';

for i = 1:2
  use_x = norm_x;
  use_labs = addcat( labs', collapsed_dir_cat );
  
  if ( i == 1 )
    left_trials = findor( labs, {'left-cue', 'left-target'} );
    use_x(left_trials, :) = 1 - use_x(left_trials, :);
    
    setcat( use_labs, collapsed_dir_cat, sprintf('%s-true', collapsed_dir_cat) );
  else
    setcat( use_labs, collapsed_dir_cat, sprintf('%s-false', collapsed_dir_cat) );
  end

  time_window_size = params.time_window_size;
  pos_window_size = params.position_window_size;
  pos_padding = params.position_padding;

  [subset_counts, binned_t, edges] = ...
    get_binned_counts( use_x, t, pos_window_size, time_window_size, pos_padding );
  
  all_counts = [ all_counts; subset_counts ];
  
  append( all_labs, use_labs );
end

outs = struct();
outs.params = params;
outs.counts = all_counts;
outs.counts_t = binned_t;
outs.labels = all_labs;
outs.edges = edges;
outs.event_indices = [ mask_time, targ_time ];
outs.norm_roi_left = repmat( norm_roi_left, rows(all_labs), 1 );
outs.norm_roi_right = repmat( norm_roi_right, rows(all_labs), 1 );
outs.screen_size = repmat( screen_size(:)', rows(all_labs), 1 );

end

function [norm_x_l, norm_x_r] = get_normalized_cue_rois(image_l, image_r, min_x, max_x)

xs_l = image_l.vertices([1, 3]);
xs_r = image_r.vertices([1, 3]);

norm_func = @(x, min, max) (x - min) ./ (max - min);
norm_x_l = norm_func( xs_l, min_x, max_x );
norm_x_r = norm_func( xs_r, min_x, max_x );

end

function labs = get_trial_selection_criterion(labs, identifier, conf)

selection_filename = sbha.util.get_trial_selection_criterion_filename( identifier );
use_trial_index = sbha.util.get_trial_selection_criterion( selection_filename, conf );
add_is_trial_selected_labels( labs, use_trial_index );

end

function add_is_trial_selected_labels(labs, use_trial)

selection_cat = 'rt-is-trial-selected';
addsetcat( labs, selection_cat, sprintf('%s-false', selection_cat) );

labs_made_select = find( labs, 'made-selection-true' );

n_labs_made_select = numel( labs_made_select );
n_selected = numel( use_trial );

assert( n_labs_made_select == n_selected, 'Selected trials do not match.' );
assert( all(ismember(use_trial, [0, 1])), 'Trial selection crit is not a logical mask.' );

use_trial_index = labs_made_select(logical(use_trial));

setcat( labs, selection_cat, sprintf('%s-true', selection_cat), use_trial_index );

end

function [counts, binned_t, edges] = get_binned_counts(x, t, pos_window, time_window, padding)

import shared_utils.vector.slidebin;

edges = (0-padding):pos_window:(1+padding);

binned_t = cellfun( @(x) x(1), slidebin(t, time_window, time_window) );
counts = nan( rows(x), numel(binned_t), numel(edges) );

for i = 1:rows(x)
  subset_x = x(i, :);
  binned_x = slidebin( subset_x, time_window, time_window );
  
  for j = 1:numel(binned_x)
    counts(i, j, :) = histc( binned_x{j}, edges );
  end
end

end

function adjusted_x = match_x_across_midline(x, t, time_window)

adjusted_x = nan( size(x) );

is_within_time = t >= time_window(1) & t <= time_window(2);
is_left = x < 0.5;
is_right = x >= 0.5;

is_norm_left = is_within_time & is_left;
is_norm_right = is_within_time & is_right;

left_adjust = nanmean( x(is_norm_left) );
right_adjust = nanmean( x(is_norm_right) ) - 1;

adjusted_x(is_left) = x(is_left) - left_adjust;
adjusted_x(is_right) = x(is_right) - right_adjust;


end