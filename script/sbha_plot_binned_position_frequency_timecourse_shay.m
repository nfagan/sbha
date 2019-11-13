function sbha_plot_binned_position_frequency_timecourse_shay()

%%  Config

% Subdirectory of plots/pos_freq_timecourse/<date> in which to save plots.
base_plot_subdirectory = 'taranino';

% Prefix each figure file with this string.
base_plot_prefix = 'tarantino_NC_Dec29_17MS';

% Plot formates
plot_formats = { 'png', 'svg', 'epsc', 'fig' };

% Whether to save plots
should_save_plots = true;

% Where to draw horizontal dotted lines on the spectra, in ms.
horz_lines = [ 0, 17, 667 ];

% Whether task is rt task
is_rt_task = true;

% Whether to use excel trial criteria
use_trial_selection_criterion = true;

% Restrict input files to those containing string(s). Leave empty: {} to
% include all files.
% files_containing = { '28-Dec-2018' };
files_containing = {'nc-congruent-twotarg-29-Dec-2018 16_04_55';'nc-congruent-twotarg-29-Dec-2018 17_23_11'}; 

% Set axes color limits, or leave empty ([]) to set automatically.
color_limits = [];

%%  bin position frequencies over time

event_name = ternary( is_rt_task, 'cue_onset', 'target_onset' );

outs = sbha_run_binned_position_frequency_timecourse( ...
     'files_containing', files_containing ... 
   , 'time_window_size', 10 ... % ms
   , 'position_window_size', 0.01 ... % normalized units [0, 1]
   , 'use_trial_selection_criterion', use_trial_selection_criterion ...
   , 'event_name', event_name ...
   , 'is_parallel', true ...
);

if ( ~isempty(outs) )
  edges = outs.edges;
  counts_t = outs.counts_t;
  labs = outs.labels';
  counts = outs.counts;

  p_window_size = outs.params.position_window_size;
  t_window_size = outs.params.time_window_size;

  plot_lines = (horz_lines - counts_t(1)) / t_window_size;

  plot_p = fullfile( sbha.dataroot(), 'plots', 'pos_freq_timecourse' ...
    , datestr(now, 'mmddyy'), base_plot_subdirectory );
else
  error( 'No files matched: "%s".', strjoin(files_containing, ', ') );
end

%%  plot each direction individually

plot_filename_prefix = sprintf( '%sper_direction__', base_plot_prefix );
plot_subdirectory = 'per_monkey';

x_ind = true( size(edges) );

pl = plotlabeled.make_spectrogram( counts_t, edges(x_ind) );
pl.panel_order = { 'n-targets-1', 'n-targets-2' };

pltlabs = labs';
pltdat = fliplr( counts );

if ( use_trial_selection_criterion )
  % Only trials that were selected
  mask = find( pltlabs, 'rt-is-trial-selected-true' );
else
  % All trials
  mask = rowmask( pltlabs );
end

mask = fcat.mask( pltlabs, mask ...
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
shared_utils.plot.ylabel( axs(1), 'Time from cue onset (ms)' );
shared_utils.plot.xlabel( axs(1), 'Normalized position ');
shared_utils.plot.add_horizontal_lines( axs, plot_lines, 'r--' );
shared_utils.plot.fullscreen( figs );

if ( ~isempty(color_limits) )
  shared_utils.plot.set_clims( axs, color_limits );
end

if ( should_save_plots )  
  full_plot_p = fullfile( plot_p, plot_subdirectory );
  
  for i = 1:numel(figs)
    filename_labs = prune( select_labs(I{i}) );
    filename = dsp3.req_savefig( figs(i), full_plot_p, filename_labs ...
      , fcats, plot_filename_prefix );
    
    identifiers = combs( select_labs, 'identifier', I{i} );
    file_contents = strjoin( identifiers, '\n' );
    
    shared_utils.io.req_write_text_file( fullfile(full_plot_p, 'info', filename), file_contents );
  end
end

%%  plot collapsed directions

plot_filename_prefix = sprintf( '%scollapsed_directions__', base_plot_prefix );
plot_subdirectory = 'per_monkey';

x_ind = true( size(edges) );

pl = plotlabeled.make_spectrogram( counts_t, edges(x_ind) );
pl.panel_order = { 'n-targets-1', 'n-targets-2' };

pltlabs = labs';
pltdat = fliplr( counts );

if ( use_trial_selection_criterion )
  % Only trials that were selected
  mask = find( pltlabs, 'rt-is-trial-selected-true' );
else
  % All trials
  mask = rowmask( pltlabs );
end

mask = fcat.mask( pltlabs, mask ...
  , @find, {'made-selection-true', 'collapsed-cue-direction-true'} ...
  , @find, {'correct-true'} ...
);

select_data = pltdat(mask, :, x_ind);
select_labs = pltlabs(mask);

fcats = { 'monkey', 'conscious-type', 'task-type', 'congruency' };
pcats = { 'n-targets', 'conscious-type', 'monkey' };

[figs, axs, I] = pl.figures( @imagesc, select_data, select_labs, fcats, pcats );

shared_utils.plot.fseries_yticks( axs, counts_t, 20 );
shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.ylabel( axs(1), 'Time from cue onset (ms)' );
shared_utils.plot.xlabel( axs(1), 'Normalized position ');
shared_utils.plot.add_horizontal_lines( axs, plot_lines, 'r--' );
shared_utils.plot.fullscreen( figs );

if ( ~isempty(color_limits) )
  shared_utils.plot.set_clims( axs, color_limits );
end

if ( should_save_plots )  
  full_plot_p = fullfile( plot_p, plot_subdirectory );
  
  for i = 1:numel(figs)
    filename_labs = prune( select_labs(I{i}) );
    filename = dsp3.req_savefig( figs(i), full_plot_p, filename_labs ...
      , fcats, plot_filename_prefix );
    
    identifiers = combs( select_labs, 'identifier', I{i} );
    file_contents = strjoin( identifiers, '\n' );
    
    shared_utils.io.req_write_text_file( fullfile(full_plot_p, 'info', filename), file_contents );
  end
end

end