test_file = 'nc-congruent-twotarg-22-Feb-2019 12_13_38.mat';
% test_file = 'nc-congruent-twotarg-14-Dec-2018 17_18_07';

outs = sbha_run_binned_position_frequency_timecourse( ...
     'files_containing', test_file ... 
   , 'time_window_size', 10 ... % ms
   , 'position_window_size', 0.01 ... % normalized units [0, 1]
   , 'use_trial_selection_criterion', false ...
   , 'event_name', 'cue_onset' ...
   , 'is_parallel', true ...
   , 'normalize_to', 'screen' ...
   , 'lr_normalization_time_window', [1100, 1200] ...
   , 'position_padding', 0.6 ...
);

%%  per direction

edges = outs.edges;
counts_t = outs.counts_t;
labs = outs.labels';
counts = outs.counts;
x_ind = true( size(edges) );

pl = plotlabeled.make_spectrogram( counts_t, edges(x_ind) );

pltlabs = labs';
pltdat = fliplr( counts );

mask = fcat.mask( pltlabs ...
  , @find, {'made-selection-true', 'collapsed-cue-direction-false'} ...
  , @find, {'correct-true'} ...
);

fcats = { 'conscious-type', 'monkey', 'task-type', 'congruency' };
pcats = { 'cue-target-direction', 'n-targets', 'conscious-type', 'monkey' };

select_data = pltdat(mask, :, x_ind);
select_labs = pltlabs(mask);

[figs, axs, I] = pl.figures( @imagesc, select_data, select_labs, fcats, pcats );

shared_utils.plot.fseries_yticks( axs, counts_t, 20 );
shared_utils.plot.hold( axs, 'on' );
hs = shared_utils.plot.add_vertical_lines( axs, bfw.find_nearest(edges(x_ind), 0.5), 'r--' );
set( hs, 'linewidth', 2 );

%%  collapse directions

edges = outs.edges;
counts_t = outs.counts_t;
labs = outs.labels';
counts = outs.counts;
x_ind = true( size(edges) );

pl = plotlabeled.make_spectrogram( counts_t, edges(x_ind) );
pl.panel_order = { 'n-targets-1', 'n-targets-2' };

pltlabs = labs';
pltdat = fliplr( counts );

mask = fcat.mask( pltlabs ...
  , @find, {'made-selection-true', 'collapsed-cue-direction-true'} ...
  , @find, {'correct-true'} ...
);

select_data = pltdat(mask, :, x_ind);
select_labs = pltlabs(mask);

fcats = { 'monkey', 'conscious-type', 'task-type', 'congruency' };
pcats = { 'n-targets', 'conscious-type', 'monkey' };

[figs, axs, I] = pl.figures( @imagesc, select_data, select_labs, fcats, pcats );
shared_utils.plot.fseries_yticks( axs, counts_t, 20 );