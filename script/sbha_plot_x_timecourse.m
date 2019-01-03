event_name = 'cue_onset';
look_back = -200;

%%

sbha.make_edf_trials( ...
    'event_name', event_name ...
  , 'look_back', look_back ...
  , 'look_ahead', 1666 ...
  , 'overwrite', true ...
);

%%

edf_events_file = sbha.load1( 'edf_events', 'nc-congruent' );
% edf_events_file = sbha.load1( 'edf_events', 'nc-congruent-twotarg-17-Dec-2018 11_03_02' );

id = edf_events_file.identifier;

edf_trials_file = sbha.load1( fullfile('edf_trials', event_name), id );
labels_file = sbha.load1( 'labels', id );
un_file = sbha.load1( 'unified', id );

labs = fcat.from( labels_file );
key = edf_trials_file.key;

x = squeeze( edf_trials_file.aligned(:, :, key('x')) );
y = squeeze( edf_trials_file.aligned(:, :, key('y')) );
t = edf_trials_file.t;

events = edf_events_file.events;
event_key = edf_events_file.event_key;

stim = un_file.opts.STIMULI;

left_image_setup = stim.setup.left_image1;
left_image_obj = un_file.opts.STIMULI.left_image1;
right_image_obj = un_file.opts.STIMULI.right_image1;

choice_time = left_image_setup.target_duration * 1e3;

mask_onset = round( events(:, event_key('mask_onset')) );
cue_onset = round( events(:, event_key('cue_onset')) );
targ_onset = round( events(:, event_key('rt_target_onset')) );
targ_acquired = round( events(:, event_key('target_acquired')) );

mask_delay_time = mask_onset - cue_onset - look_back;
targ_delay_time = targ_onset - cue_onset - look_back;
targ_acq_delay_time = targ_acquired - cue_onset - choice_time - look_back;

task_timings = un_file.opts.TIMINGS.time_in;

mask_time = task_timings.rt_present_targets;
targ_time = task_timings.pre_mask_delay + mask_time;

mask_time = round( mask_time * 1e3 );
targ_time = round( targ_time * 1e3 );

left_bounds = left_image_obj.targets{1}.bounds;
right_bounds = right_image_obj.targets{1}.bounds;

all_valid_x = columnize( x(~isnan(x)) );
all_valid_y = columnize( y(~isnan(y)) );

screen_size = un_file.opts.WINDOW.rect;

% min_x = min( all_valid_x );
% max_x = max( all_valid_x );
% min_y = min( all_valid_y );
% max_y = max( all_valid_y );

min_x = screen_size(1);
max_x = screen_size(3);
min_y = screen_size(2);
max_y = screen_size(4);

norm_func = @(x, min, max) (x - min) ./ (max-min);

norm_x = norm_func( x, min_x, max_x );
norm_y = 1 - norm_func( y, min_y, max_y );  % invert y

norm_left_x = norm_func( left_bounds([1, 3]), min_x, max_x );
norm_right_x = norm_func( right_bounds([1, 3]), min_x, max_x );
norm_left_y = norm_func( left_bounds([2, 4]), min_y, max_y );
norm_right_y = norm_func( right_bounds([2, 4]), min_y, max_y );

make_rect = @(x, y) [ x(1), y(1), x(2), y(2) ];

norm_left_bounds = make_rect( norm_left_x, norm_left_y );
norm_right_bounds = make_rect( norm_right_x, norm_right_y );

% flip congruent-left trials
right_trials = find( labs, 'congruent-right' );
norm_x(right_trials, :) = 1 - norm_x(right_trials, :);

%%

window_size = 10;
edges = 0:0.01:1;

use_x = norm_x;

binned_t = cellfun( @(x) x(1), shared_utils.vector.slidebin(t, window_size, window_size) );
counts = nan( rows(use_x), numel(binned_t), numel(edges) );

for i = 1:rows(use_x)
  
  subset_x = use_x(i, :);
  binned_x = shared_utils.vector.slidebin( subset_x, window_size, window_size );
  
  for j = 1:numel(binned_x)
    counts(i, j, :) = histc( binned_x{j}, edges );
  end
end

% x_ind = edges >= 0.25 & edges < 0.65;
x_ind = true( size(edges) );

pl = plotlabeled.make_spectrogram( binned_t, edges(x_ind) );
pl.panel_order = { 'congruent-left', 'congruent-right' };

pltlabs = labs';
pltdat = fliplr( counts );

setcat( pltlabs, 'congruent-direction', 'congruent-single' ...
  , find(pltlabs, {'congruent-left', 'congruent-right'}) );

mask = fcat.mask( pltlabs ...
  , @find, 'made-selection-true' ...
);

mask = mask(26:end);

pcats = { 'congruent-direction', 'subject' };

axs = pl.imagesc( pltdat(mask, :, x_ind), pltlabs(mask), pcats );

shared_utils.plot.fseries_yticks( axs, binned_t );
shared_utils.plot.hold( axs, 'on' );
horz_lines = ([0, mask_time, targ_time] - binned_t(1)) / window_size;
shared_utils.plot.add_horizontal_lines( axs, horz_lines, 'r--' );


%%

trial_n = 3;

mask = find( labs, 'made-selection-true' );

hold off;
plot( t(:)', x(mask(trial_n), :) ); hold on;
plot( t(:)', y(mask(trial_n), :) );

legend( {'x', 'y'} );

shared_utils.plot.add_vertical_lines( gca, mask_delay_time(mask(trial_n)) );
shared_utils.plot.add_vertical_lines( gca, targ_delay_time(mask(trial_n)) );
shared_utils.plot.add_vertical_lines( gca, targ_acq_delay_time(mask(trial_n)) );

%%




