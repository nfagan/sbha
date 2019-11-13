function summary_counts = sbha_cue_summary_counts(counts, counts_t, edges, time_roi, pos_roi)

validateattributes( counts, {'numeric'}, {}, mfilename, 'counts' );
validateattributes( counts_t, {'numeric'}, {'numel', size(counts, 2)}, mfilename, 'counts_t' );
validateattributes( edges, {'numeric'}, {'numel', size(counts, 3)}, mfilename, 'edges' );

time_roi_ind = counts_t >= time_roi(1) & counts_t <= time_roi(2);
pos_roi_ind = edges >= pos_roi(:, 1) & edges <= pos_roi(:, 2);

assert( rows(pos_roi_ind) == rows(counts) ...
  , 'Expected rows of counts to match rows in bounds position roi.' );

num_trials = rows( counts );
summary_counts = nan( num_trials, 1 );

for i = 1:num_trials
  summary_counts(i) = sum( columnize(counts(i, time_roi_ind, pos_roi_ind(i, :))) );
end

end