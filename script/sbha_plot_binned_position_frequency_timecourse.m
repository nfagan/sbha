function sbha_plot_binned_position_frequency_timecourse()

%%  Config

% Subdirectory of plots/pos_freq_timecourse/<date> in which to save plots.
base_plot_subdirectory = 'Hitch';

% Prefix each figure file with this string.
base_plot_prefix = 'Hitch_NC_7ms_Dec15';

% Whether to save plots
should_save_plots = false;

% Where to draw horizontal dotted lines on the spectra, in ms.
horz_lines = [ 0, 7, 660 ];

% Whether to use excel trial criteria
use_trial_selection_criterion = false;

% Restrict input files to those containing string(s). Leave empty: {} to
% include all files.
% files_containing = { '28-Dec-2018' };
% files_containing = {'nc-congruent-twotarg-15-Dec-2018 10_18_47';'nc-congruent-twotarg-15-Dec-2018 10_50_01'};
files_containing = {'nc-congruent-twotarg-27-Dec-2018 15_15_19.mat'; 'nc-congruent-twotarg-28-Dec-2018 09_45_18.mat' };

%%  bin position frequencies over time

outs = sbha_run_binned_position_frequency_timecourse( ...
     'files_containing', files_containing ... 
   , 'time_window_size', 10 ... % ms
   , 'position_window_size', 0.01 ... % normalized units [0, 1]
   , 'use_trial_selection_criterion', use_trial_selection_criterion ...
   , 'event_name', 'cue_onset' ...
   , 'is_parallel', true ...
   , 'normalize_to', 'adjusted-cues' ...
   , 'lr_normalization_time_window', [400, 450] ...
   , 'position_padding', 0.2 ...
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
  error( 'No files matched: "%s".', strjoin(files_containing, ' | ') );
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
shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.ylabel( axs(1), 'Time from cue onset (ms)' );
shared_utils.plot.xlabel( axs(1), 'Normalized position ');
shared_utils.plot.add_horizontal_lines( axs, plot_lines, 'r--' );
shared_utils.plot.fullscreen( figs );

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