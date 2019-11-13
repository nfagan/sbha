function sbha_run_summary_position_frequency_timecourse()

% Whether task is rt task
is_rt_task = true;

% Whether to save an excel file with these results.
save_xls = true;
xls_save_dir = fullfile( sbha.dataroot(), 'xls', 'position_frequency_timecourse_summary' );

% Whether to use excel trial criteria
use_trial_selection_criterion = false;

% Whether to use only correct, selected trials.
use_only_correct_selected_trials = false;

% Restrict input files to those containing string(s). Leave empty: {} to
% include all files.
files_containing = {'nc-congruent-twotarg-03-Dec-2018 17_54_41'};

% Window of interest in time dimension.
stat_time_roi = [0, 667];

% Optionally add padding around the cues.
stat_position_padding = 0;

event_name = ternary( is_rt_task, 'cue_onset', 'target_onset' );

outs = sbha_run_binned_position_frequency_timecourse( ...
     'files_containing', files_containing ... 
   , 'time_window_size', 10 ... % ms
   , 'position_window_size', 0.01 ... % normalized units [0, 1]
   , 'use_trial_selection_criterion', use_trial_selection_criterion ...
   , 'event_name', event_name ...
   , 'is_parallel', true ...
   , 'normalize_to', 'screen' ...
);

%%

labels = outs.labels';

if ( use_only_correct_selected_trials )
  mask = make_correct_selected_mask( labels, use_trial_selection_criterion );
else
  mask = make_all_mask( labels, use_trial_selection_criterion );
end

%%

roi_left = get_roi( outs.norm_roi_left, stat_position_padding );
roi_right = get_roi( outs.norm_roi_right, stat_position_padding );

left_counts = sbha_cue_summary_counts( outs.counts, outs.counts_t, outs.edges, stat_time_roi, roi_left );
right_counts = sbha_cue_summary_counts( outs.counts, outs.counts_t, outs.edges, stat_time_roi, roi_right );

all_counts = [ left_counts(mask), right_counts(mask) ];

%%

if ( save_xls )
  do_save_xls( all_counts, prune(labels(mask)), xls_save_dir );
end

end

function do_save_xls(counts, labels, xls_save_dir)

assert_ispair( counts, labels );

meta_labs = make_additional_meta_labels( labels );

all_data = cell( rows(labels), size(counts, 2) + size(meta_labs, 2) );
all_data(:, 1:size(counts, 2)) = arrayfun( @(x) x, counts, 'un', 0 );
all_data(:, (size(counts, 2)+1):end) = meta_labs;

shared_utils.io.require_dir( xls_save_dir );
save_p = fullfile( xls_save_dir, xls_filename(labels) );
xlswrite( save_p, all_data );

end

function labs = make_additional_meta_labels(labels)

labs = cellstr( labels, {'correct', 'made-selection' ...
  , 'congruent-direction', 'correct-direction', 'selected-direction', 'subject', 'identifier'} );

end

function filename = xls_filename(labels)

max_num_chars = 256;
ids = cellfun( @(x) strrep(x, '.mat', ''), combs(labels, 'identifier'), 'un', 0 );

filename = sprintf( '%s.xls', strjoin(ids, '_') );
filename = filename(1:min(numel(filename), max_num_chars));

end

function norm_roi = get_roi(norm_roi, padding)

norm_roi(:, 1) = norm_roi(:, 1) - padding/2;
norm_roi(:, 2) = norm_roi(:, 2) + padding/2;

end

function mask = make_all_mask(labels, use_trial_selection_criterion)

if ( use_trial_selection_criterion )
  % Only trials that were selected
  mask = find( labels, 'rt-is-trial-selected-true' );
else
  % All trials
  mask = rowmask( labels );
end

mask = fcat.mask( labels, mask ...
  , @find, {'collapsed-cue-direction-false'} ...
);

end

function mask = make_correct_selected_mask(labels, use_trial_selection_criterion)

if ( use_trial_selection_criterion )
  % Only trials that were selected
  mask = find( labels, 'rt-is-trial-selected-true' );
else
  % All trials
  mask = rowmask( labels );
end

mask = fcat.mask( labels, mask ...
  , @find, {'made-selection-true', 'collapsed-cue-direction-false'} ...
  , @find, {'correct-true'} ...
);

end

