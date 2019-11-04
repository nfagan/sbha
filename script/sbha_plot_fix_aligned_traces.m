edf_trials_file = sbha.load1( 'edf_trials/fixation_onset', 'nc-congruent-twotarg-22-Feb-2019 12_13_38' );
unified_file = sbha.load1( 'unified', edf_trials_file.identifier );
edf_events_file = sbha.load1( 'edf_events', edf_trials_file.identifier );
trials_file = sbha.load1( 'trials', edf_trials_file.identifier );

%%

fix_events = edf_events_file.events(:, edf_events_file.event_key('fixation_onset'));
cue_events = edf_events_file.events(:, edf_events_file.event_key('cue_onset'));

fix_bounds = unified_file.opts.STIMULI.fix_square.vertices;
trial = 15;

t = edf_trials_file.t;
x = squeeze( edf_trials_file.aligned(trial, :, 1) );
y = squeeze( edf_trials_file.aligned(trial, :, 2) );

y_lims = [ 0, shared_utils.rect.width(unified_file.opts.WINDOW.rect) ];

xp = fix_bounds([1, 3]);
yp = fix_bounds([2, 4]);

tp = cue_events(trial) - fix_events(trial);

% axs = sbha.plot_traces( t, x, y, tp, xp, yp, 'y_lims', y_lims );
% shared_utils.plot.match_xlims( axs );

%%

