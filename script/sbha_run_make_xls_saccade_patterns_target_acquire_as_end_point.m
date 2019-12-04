inputs = struct();
% empty {} for all files, or give a list of files to process.
inputs.files_containing = {};
inputs.overwrite = true;

inputs.time_offsets = [];
inputs.use_end_event = true;
inputs.end_event_name = 'target_acquired';

sbha.make_xls_saccade_patterns( inputs );