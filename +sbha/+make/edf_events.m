function events_file = edf_events(files)

import shared_utils.sync.cinterp;

unified_file = shared_utils.general.get( files, 'unified' );
events_file = shared_utils.general.get( files, 'events' );
edf_file = shared_utils.general.get( files, 'edf' );

mat_event_times = events_file.events;

edf_sync_times = edf_file.sync_times(:);
mat_sync_times = unified_file.tracker_sync.times(:);

nmat = numel( mat_sync_times );
nedf = numel( edf_sync_times );

assert( nmat == nedf || nedf == nmat + 1 ...
  , 'eyelink and matlab sync times do not correspond.' );

edf_sync_times = edf_sync_times(1:nmat);

edf_event_times = nan( size(mat_event_times) );

for i = 1:size(mat_event_times, 2)
  mat_times = mat_event_times(:, i);  
  
  edf_times = cinterp( mat_times, mat_sync_times, edf_sync_times, true );
  
  edf_event_times(:, i) = edf_times;
end

events_file.events = edf_event_times;

end