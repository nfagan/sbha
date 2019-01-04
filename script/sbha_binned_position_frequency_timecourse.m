function outs = sbha_binned_position_frequency_timecourse(files, varargin)

defaults = sbha_binned_position_frequency_timecourse_defaults();

params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;
conf = params.config;

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

screen_size = un_file.opts.WINDOW.rect;

min_x = screen_size(1);
max_x = screen_size(3);

norm_func = @(x, min, max) (x - min) ./ (max-min);
norm_x = norm_func( x, min_x, max_x );

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

all_counts = [];
all_labs = fcat();
collapsed_dir_cat = 'collapsed-cue-direction';

for i = 1:2
  use_x = norm_x;
  use_labs = addcat( labs', collapsed_dir_cat );
  
  if ( i == 1 )
    % flip congruent-right trials
%     right_trials = find( labs, {'right-cue', 'right-target'} );
%     use_x(right_trials, :) = 1 - use_x(right_trials, :);

    left_trials = findor( labs, {'left-cue', 'left-target'} );
    use_x(left_trials, :) = 1 - use_x(left_trials, :);
    
    setcat( use_labs, collapsed_dir_cat, sprintf('%s-true', collapsed_dir_cat) );
  else
    setcat( use_labs, collapsed_dir_cat, sprintf('%s-false', collapsed_dir_cat) );
  end

  time_window_size = params.time_window_size;
  pos_window_size = params.position_window_size;

  [subset_counts, binned_t, edges] = ...
    get_binned_counts( use_x, t, pos_window_size, time_window_size );
  
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

end

function labs = get_trial_selection_criterion(labs, identifier, conf)

identifier_sans_ext = strrep( identifier, '.mat', '' );

selection_filename = sprintf( 'TRIALS_%s.xlsx', identifier_sans_ext );

selection_dir = fullfile( sbha.dataroot(conf), 'misc', 'position_frequency_trial_selection' );
selection_file = fullfile( selection_dir, selection_filename );

selection_cat = 'rt-is-trial-selected';
addsetcat( labs, selection_cat, sprintf('%s-false', selection_cat) );

if ( ~shared_utils.io.fexists(selection_file) )
  error( 'No such file: "%s".', selection_file );
end

[xls, header] = xlsread( selection_file );

[selected_trials, use_trial_index] = parse_trial_selection_excel_file( xls, header );

add_is_trial_selected_labels( labs, selection_cat, selected_trials, use_trial_index );


end

function [selected_trials, use_trial_index] = parse_trial_selection_excel_file(xls, header)

test_func = @(x, y) ~isempty( strfind(lower(x), y) );

is_trial_col = cellfun( @(x) test_func(x, 'trial'), header );
is_include_col = cellfun( @(x) test_func(x, 'include'), header );

assert( all(xor(is_trial_col, is_include_col)), 'Invalid header: "%s".' ...
  , strjoin(header, ' | ') );

selected_trials = xls(:, is_trial_col);
use_trial_index = xls(:, is_include_col);

end

function add_is_trial_selected_labels(labs, selection_cat, selected_trials, use_trial)

labs_made_select = find( labs, 'made-selection-true' );

n_labs_made_select = numel( labs_made_select );
n_selected = numel( selected_trials );

assert( n_labs_made_select == n_selected, 'Selected trials do not match.' );
assert( all(ismember(use_trial, [0, 1])), 'Trial selection crit is not a logical mask.' );

use_trial_index = labs_made_select(logical(use_trial));

setcat( labs, selection_cat, sprintf('%s-true', selection_cat), use_trial_index );

end

function [counts, binned_t, edges] = get_binned_counts(x, t, pos_window, time_window)

import shared_utils.vector.slidebin;

edges = 0:pos_window:1;

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

% stim = un_file.opts.STIMULI;
% 
% left_image_setup = stim.setup.left_image1;
% left_image_obj = un_file.opts.STIMULI.left_image1;
% right_image_obj = un_file.opts.STIMULI.right_image1;
% 
% choice_time = left_image_setup.target_duration * 1e3;
% 
% mask_onset = round( events(:, event_key('mask_onset')) );
% cue_onset = round( events(:, event_key('cue_onset')) );
% targ_onset = round( events(:, event_key('rt_target_onset')) );
% targ_acquired = round( events(:, event_key('target_acquired')) );
% 
% mask_delay_time = mask_onset - cue_onset - look_back;
% targ_delay_time = targ_onset - cue_onset - look_back;
% targ_acq_delay_time = targ_acquired - cue_onset - choice_time - look_back;