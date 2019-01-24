function outs = sbha_gaze_switching(files, varargin)

defaults = sbha_gaze_switching_defaults();
params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;
time_window = params.time_window;

edf_trials_file = shared_utils.general.get( files, event_name );
labels_file = shared_utils.general.get( files, 'labels' );
un_file = shared_utils.general.get( files, 'unified' );

labs = fcat.from( labels_file );
key = edf_trials_file.key;

x = squeeze( edf_trials_file.aligned(:, :, key('x')) );
y = squeeze( edf_trials_file.aligned(:, :, key('y')) );
t = edf_trials_file.t;

if ( ~isempty(time_window) )
  use_t = t >= time_window(1) & t <= time_window(2);
  
  x = x(:, use_t);
  y = y(:, use_t);
  t = t(use_t);
end

l_image = un_file.opts.STIMULI.left_image1.vertices;
r_image = un_file.opts.STIMULI.right_image1.vertices;

is_ib_left = rect_bounds( l_image, x, y );
is_ib_right = rect_bounds( r_image, x, y );

switch_counts = zeros( rows(x), 3 );

for i = 1:rows(x)
  left_starts = shared_utils.logical.find_all_starts( is_ib_left(i, :) );
  right_starts = shared_utils.logical.find_all_starts( is_ib_right(i, :) );
  switch_starts = find_switches( left_starts, right_starts );
  
  n_left = numel( left_starts );
  n_right = numel( right_starts );
  n_switches = numel( switch_starts );
  
  switch_counts(i, :) = [ n_left, n_right, n_switches ];  
end

outs = struct();
outs.counts = switch_counts;
outs.labels = labs;

end

function starts = find_switches(left, right)

n_left = numel( left );
n_right = numel( right );

if ( n_left == 0 || n_right == 0 )
  % No switches if never looked left or never looked right
  starts = [];
  return
elseif ( n_left == 1 && n_right == 1 )
  % One look left and one look right -> one switch
  starts = max( left, right );
  return
end

is_left = false( 1, n_left + n_right );
is_left(1:n_left) = true;
combined = [ left(:)', right(:)' ];

[combined, sorted_index] = sort( combined );
permuted_is_left = is_left(sorted_index);

[start_indices, durs] = shared_utils.logical.find_all_starts( permuted_is_left );

starts = [];

for i = 1:numel(start_indices)
  start_left = start_indices(i);
  start_right = start_left + durs(i);
  
  if ( start_left > 1 )    
    starts(end+1) = combined(start_left);
  end
  
  if ( start_right <= numel(combined) )
    starts(end+1) = combined(start_right);
  end
end

end

function ib = rect_bounds(r, x, y)

ib = x >= r(1) & x <= r(3) & y >= r(2) & y <= r(4);

end