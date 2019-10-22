function edf_trials_file = edf_trials(files, varargin)

defaults = sbha.make.defaults.edf_trials();
params = sbha.parsestruct( defaults, varargin );

edf_file = shared_utils.general.get( files, 'edf' );
events_file = shared_utils.general.get( files, 'edf_events' );

event_names = keys( events_file.event_key );
event_name = validatestring( params.event_name, event_names ...
  , mfilename, 'event_name' );

[lb, la] = check_look_back_look_ahead( params.look_back, params.look_ahead );

events = events_file.events(:, events_file.event_key(event_name));

[aligned, t, key] = get_aligned_data( edf_file, events, lb, la );

edf_trials_file = struct();
edf_trials_file.identifier = edf_file.identifier;
edf_trials_file.params = params;
edf_trials_file.aligned = aligned;
edf_trials_file.t = t;
edf_trials_file.key = key;

end

function [aligned, aligned_t, key] = get_aligned_data(samples, events, lb, la)

assert( isvector(events), 'Events must be a vector.' );

t = samples.t;
x = samples.x;
y = samples.y;

n_t = la - lb + 1;

aligned = nan( numel(events), n_t, 3 );
aligned_t = lb:la;
key = containers.Map({'x', 'y'}, {1, 2});

for i = 1:numel(events)
  evt = round( events(i) );
  
  if ( isnan(evt) )
    continue;
  end
  
  start = evt + lb;
  stop = evt + la;
  
  start_i = t == start;
  stop_i = t == stop;
  
  assert( nnz(start_i) == 1, 'No matching start time.' );
  allow_mismatch_size = false;
  
  if ( nnz(stop_i) == 0 )
    if ( stop > max(t) )
      stop_i = t == max( t );
      allow_mismatch_size = true;
    else
      error( 'No matching stop time.' );
    end
  end
  
  num_start_i = find( start_i );
  num_stop_i = find( stop_i );
  
  current_n_t = num_stop_i - num_start_i + 1;
  
  if ( ~allow_mismatch_size )
    assert( current_n_t == n_t, 'Stop - start doesn''t match number of samples.' );
  end
  
  index_vec = num_start_i:num_stop_i;
  
  aligned(i, 1:current_n_t, 1) = x(index_vec);
  aligned(i, 1:current_n_t, 2) = y(index_vec);
end

end

function [lb, la] = check_look_back_look_ahead(lb, la)

classes = { 'numeric' };
attrs = { 'scalar' };
mf = mfilename;

validateattributes( lb, classes, attrs, mf, 'look_back' );
validateattributes( la, classes, attrs, mf, 'look_ahead' );

lb = double( lb );
la = double( la );

end