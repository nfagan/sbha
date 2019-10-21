rt_outs = sbha_recalculate_rt_gaze( 'is_parallel', true );

%%

all_rt = [ rt_outs.gaze_rt; rt_outs.original_rt ];
rt_labs = addcat( rt_outs.labels', 'method' );
repset( rt_labs, 'method', {'gaze', 'task'} );

mask = fcat.mask( rt_labs ...
  , @find, {'correct-true'} ...
);

pl = plotlabeled.make_common();
pl.hist_add_summary_line = true;
axs = pl.hist( all_rt(mask), rt_labs(mask), {'method', 'day'}, 30 );

%%

x = rt_outs.x;
y = rt_outs.y;
t = rt_outs.t;
rt = rt_outs.gaze_rt;
trial_rt = rt_outs.original_rt;
rt_labels = rt_outs.labels';

mask = fcat.mask( rt_labels ...
  , @find, 'correct-true' ...
  , @find, 'nc-congruent-twotarg-21-Feb-2019 16_03_08.mat' ...
);

difference_rt = abs( trial_rt - rt );
nan_one_or_other = xor( isnan(trial_rt), isnan(rt) );
subset_most_different = nan_one_or_other | difference_rt > 100;

do_save = true;
save_p = fullfile( sbha.dataroot(), 'plots', 'debug-rt' );
base_subdir = '';

for i = 1:numel(mask)
  shared_utils.general.progress( i, numel(mask) );
  
  trial = mask(i);
  
  left_rect = rt_outs.left_rect(trial, :);
  right_rect = rt_outs.right_rect(trial, :);

  xs = [ left_rect([1, 3]), right_rect([1, 3]) ];
  ys = [ left_rect([2, 4]), right_rect([2, 4]) ];
  
  curr_gaze_rt = rt(trial);
  curr_trial_rt = trial_rt(trial);

  axs = sbha.plot_traces( t, x(trial, :), y(trial, :), [curr_gaze_rt, curr_trial_rt], xs, ys ...
    , 'y_lims', [0, 1440] ...
    , 'time_point_colors', {'r', 'g'} ...
  );

	title_cats = { 'selected-direction', 'trial-number', 'correct' };
  rt_str = sprintf( 'Gaze rt = %0.2f; Trial rt = %0.2f', curr_gaze_rt, curr_trial_rt );
  
  title_labs = cellstr( rt_labels, title_cats, trial );
  
  title( axs(1), strjoin(title_labs, ' | ') );
  title( axs(2), rt_str );
  
  subdir = char( cellstr(rt_labels, 'identifier', trial) );
  
  if ( do_save )
    full_save_p = fullfile( save_p, base_subdir, subdir );
    dsp3.req_savefig( gcf, full_save_p, prune(rt_labels(trial)), title_cats );
  end
end