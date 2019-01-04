inputs = struct();

inputs.files_containing = {};

%%

% Use all folders
subdirs = shared_utils.io.dirnames( fullfile(sbha.dataroot(), 'raw'), 'folders' );
% subdirs = { '122918_tarantino' };

sbha.make_unified( subdirs, inputs );

%%

sbha.make_trials( inputs );
sbha.make_meta( inputs );
sbha.make_labels( inputs );

%%

sbha.make_xls_summary( inputs );

%%

sbha.make_edfs( inputs );

%%
              
sbha.make_events( inputs );
sbha.make_edf_events( inputs );

%%

timing_inputs = struct();
timing_inputs.look_back = -200;
timing_inputs.look_ahead = 1666;

sbha.make_edf_trials( inputs, timing_inputs, 'event_name', 'cue_onset' );
sbha.make_edf_trials( inputs, timing_inputs, 'event_name', 'target_onset' );