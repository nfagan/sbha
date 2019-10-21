% mat_file = load( '/Users/Nick/Downloads/ );

% mat_filename = 'congruent_nonconscious_two_targ_21-Feb-2019 16_03_08.mat';
% mat_filename = 'congruent_nonconscious_two_targ_03-Dec-2018 16_14_54.mat';
mat_filename = 'congruent_nonconscious_two_targ_04-Dec-2018 16_47_05.mat';

mat_file = load( fullfile('/Users/Nick/Downloads', mat_filename) );
edf = Edf2Mat( fullfile('/Users/Nick/Downloads', mat_file.edf_file) );
%%
import shared_utils.struct.field_or;

trial_data = mat_file.DATA;
reported_rts = [ trial_data.rt ];
lt0_ind = find( reported_rts < 0 );

edf_sync_t_ind = strcmp( edf.Events.Messages.info, 'RESYNCH' );
mat_sync_ts = mat_file.tracker_sync.times(1:mat_file.tracker_sync.index-1);

assert( numel(mat_sync_ts) == sum(edf_sync_t_ind), 'Times mismatch.' );
edf_sync_ts = edf.Events.Messages.time(edf_sync_t_ind);

all_events = {trial_data.events};
all_field_nums = cellfun( @(x) numel(fieldnames(x)), all_events );
[~, max_ind] = max( all_field_nums );
keep_fields = fieldnames( trial_data(max_ind).events );

mat_events = cellfun( @(x) cellfun(@(y) field_or(x, y, nan), keep_fields(:)'), all_events, 'un', 0 );
mat_events = vertcat( mat_events{:} );

edf_event_ts = shared_utils.sync.cinterp( mat_events, mat_sync_ts, edf_sync_ts );

%%

rt_response_ind = ismember( keep_fields, 'rt_target_onset' );
acq_ind = ismember( keep_fields, 'target_acquired' );
entered_ind = ismember( keep_fields, 'target_entered' );

response_events = round( edf_event_ts(:, rt_response_ind) );
acq_events = round( edf_event_ts(:, acq_ind) );
entered_events = round( edf_event_ts(:, entered_ind) );
rt_events = acq_events - mat_file.opts.STIMULI.left_image1.targets{1}.duration * 1e3;

% add_events = [ rt_events(:) ];
add_events = [ entered_events(:), rt_events(:), acq_events ];

%%

look_back = -500;
look_ahead = 1e3;

subdir = mat_filename;
output_subdir = fullfile( '/Users/Nick/Desktop/shay', subdir );

left_image1 = mat_file.opts.STIMULI.left_image1;
right_image1 = mat_file.opts.STIMULI.right_image1;

left_targ_rect = left_image1.targets{1}.bounds + left_image1.targets{1}.padding;
right_targ_rect = right_image1.targets{1}.bounds + right_image1.targets{1}.padding;

num_trials = numel( mat_file.DATA );
% num_trials = 1;

for i = 1:num_trials
shared_utils.general.progress( i, num_trials );
  
curr_trial_ind = i;
one_event = response_events(curr_trial_ind);
curr_choice = mat_file.DATA(curr_trial_ind).selected_direction;
curr_rt = mat_file.DATA(curr_trial_ind).rt;

any_errors = any( structfun(@identity, mat_file.DATA(i).errors) );

if ( isnan(one_event) || any_errors )
  continue;
end

additional_events = add_events(curr_trial_ind, :);
nan_additional = isnan( additional_events );

if ( any(nan_additional) )
  continue;
end

additional_events(nan_additional) = [];
% additional_events = [];

t_ind = find( edf.Samples.time == one_event );
t_ind_additional = arrayfun( @(x) find(edf.Samples.time == x), additional_events );

x = edf.Samples.posX(t_ind+look_back:t_ind+look_ahead);
y = edf.Samples.posY(t_ind+look_back:t_ind+look_ahead);
plt_t = look_back:look_ahead;

axs = {};

clf();
axs{1} = subplot( 1, 2, 1 );
ax = axs{1};
xlim( ax, [min(plt_t), max(plt_t)] );
ylim( ax, [0, mat_file.opts.WINDOW.rect(3)] );

hold( ax, 'on' );
plot( plt_t, x, 'r' );
shared_utils.plot.add_horizontal_lines( ax, left_targ_rect([1, 3]), 'r--' );
shared_utils.plot.add_horizontal_lines( ax, right_targ_rect([1, 3]), 'k--' );
shared_utils.plot.add_vertical_lines( ax, t_ind_additional-t_ind );

xlabel( ax, 'Time from target onset' );
ylabel( ax, '[<-- left] x position [--> right]' );

title( ax, sprintf('Chose %s, RT = %0.3f', curr_choice, curr_rt) );
% title( ax, sprintf('Chose %s', curr_choice) );

axs{2} = subplot( 1, 2, 2 );
ax = axs{2};
xlim( ax, [min(plt_t), max(plt_t)] );
ylim( ax, [0, mat_file.opts.WINDOW.rect(3)] );

hold( ax, 'on' );
plot( plt_t, y, 'b' );
shared_utils.plot.add_horizontal_lines( ax, left_targ_rect([2, 4]), 'r--' );
shared_utils.plot.add_horizontal_lines( ax, right_targ_rect([2, 4]), 'k--' );
shared_utils.plot.add_vertical_lines( ax, t_ind_additional-t_ind );
ylabel( ax, '[<-- up] y position [--> down]' );

axs = [ axs{:} ];
shared_utils.plot.match_ylims( axs );

dsp3.req_savefig( gcf, output_subdir, fcat, {}, sprintf('trial__%d', curr_trial_ind) );

end


