%%  Config

% Subdirectory of plots/pos_freq_timecourse/<date> in which to save plots.
base_plot_subdirectory = 'ephron';

% Prefix each figure file with this string.
base_plot_prefix = 'ephron_NC';

% Plot formates
plot_formats = { 'png', 'svg', 'epsc', 'fig' };

% Whether to save plots
should_save_plots = true;

% Where to draw horizontal dotted lines on the spectra, in ms.
horz_lines = [ 0, 17, 650 ];

% Whether to use excel trial criteria
use_trial_selection_criterion = false;

% Restrict input files to those containing string(s). Leave empty: {} to
% include all files.
% files_containing = { '28-Dec-2018' };
files_containing = {'nc-congruent-twotarg-03-Dec-2018 16_27_28'; 'nc-congruent-twotarg-03-Dec-2018 16_14_54'};

%%  bin position frequencies over time

outs = sbha_run_binned_position_frequency_timecourse( ...
     'files_containing', files_containing ... 
   , 'time_window_size', 10 ... % ms
   , 'position_window_size', 0.01 ... % normalized units [0, 1]
   , 'use_trial_selection_criterion', use_trial_selection_criterion ...
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
end

%%  plot each direction individually

plot_filename_prefix = sprintf( '%sper_direction__', base_plot_prefix );
plot_subdirectory = 'per_monkey';

x_ind = true( size(edges) );

pl = plotlabeled.make_spectrogram( counts_t, edges(x_ind) );
pl.panel_order = { 'n-targets-1', 'n-targets-2' };

pltlabs = labs';
pltdat = fliplr( counts );

mask = fcat.mask( pltlabs ...
  , @find, 'rt' ... % rt task only
  , @find, {'made-selection-true', 'collapsed-cue-direction-false'} ...
  , @find, {'correct-true'} ...
);

pcats = { 'cue-target-direction', 'n-targets', 'conscious-type', 'monkey' };
fcats = { 'conscious-type', 'monkey' };

select_data = pltdat(mask, :, x_ind);
select_labs = pltlabs(mask);

[figs, axs, I] = pl.figures( @imagesc, select_data, select_labs, fcats, pcats );

shared_utils.plot.fseries_yticks( axs, counts_t, 20 );
shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.ylabel( axs(1), 'Time from cue onset (ms)' );
shared_utils.plot.xlabel( axs(1), 'Normalized position ');
shared_utils.plot.add_horizontal_lines( axs, plot_lines, 'r--' );
shared_utils.plot.fullscreen( figs );

if ( should_save_plots )  
  full_plot_p = fullfile( plot_p, plot_subdirectory );
  
  for i = 1:numel(figs)
    filename_labs = prune( select_labs(I{i}) );
    dsp3.req_savefig( figs(i), full_plot_p, filename_labs, fcats, plot_filename_prefix, plot_formats );
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

mask = fcat.mask( pltlabs ...
  , @find, 'rt' ... % rt task only
  , @find, {'made-selection-true', 'collapsed-cue-direction-true'} ...
  , @find, {'correct-true'} ...
);

select_data = pltdat(mask, :, x_ind);
select_labs = pltlabs(mask);

fcats = { 'monkey', 'conscious-type' };
pcats = { 'n-targets', 'conscious-type', 'monkey' };

[figs, axs, I] = pl.figures( @imagesc, select_data, select_labs, fcats, pcats );

shared_utils.plot.fseries_yticks( axs, counts_t, 20 );
shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.ylabel( axs(1), 'Time from cue onset (ms)' );
shared_utils.plot.xlabel( axs(1), 'Normalized position ');
shared_utils.plot.add_horizontal_lines( axs, plot_lines, 'r--' );
shared_utils.plot.fullscreen( figs );

if ( should_save_plots )
  full_plot_p = fullfile( plot_p, plot_subdirectory );
  
  for i = 1:numel(figs)
    filename_labs = prune( select_labs(I{i}) );
    dsp3.req_savefig( figs(i), full_plot_p, filename_labs, fcats, plot_filename_prefix, plot_formats );
  end
end