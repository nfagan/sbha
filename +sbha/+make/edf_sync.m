function sync_file = edf_sync(files)

unified_file = shared_utils.general.get( files, 'unified' );
edf_file = shared_utils.general.get( files, 'edf' );

edf_sync_times = edf_file.sync_times(:);
mat_sync_times = unified_file.tracker_sync.times(:);

nmat = numel( mat_sync_times );
nedf = numel( edf_sync_times );

assert( nmat == nedf || nedf == nmat + 1 ...
, 'Eyelink and Matlab sync times do not correspond.' );

edf_sync_times = edf_sync_times(1:nmat);

sync_file = struct();
sync_file.identifier = unified_file.identifier;
sync_file.mat = mat_sync_times;
sync_file.edf = edf_sync_times;

end