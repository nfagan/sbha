inputs = struct();

%%

subdirs = {};

sbha.make_unified( subdirs, inputs );

%%

sbha.make_trials( inputs );
sbha.make_meta( inputs );
sbha.make_labels( inputs );

%%

sbha.make_edfs( inputs );

%%
              
sbha.make_events( inputs );
sbha.make_edf_events( inputs );

%%

sbha.make_edf_trials( inputs ...
  , 'event_name', 'cue_onset' ...
  , 'look_back', -200 ...
  , 'look_ahead', 1666 ...
);

%%

% inputs = struct();
% inputs.overwrite = true;

sbha.make_edf_trials( inputs ...
  , 'event_name', 'rt_target_onset' ...
  , 'look_back', 0 ...
  , 'look_ahead', 5000 ...
);

sbha.make_gaze_rt( inputs, 't_window', [0, 5e3] );

sbha.make_xls_summary( inputs );

%%

sbha.make_xls_summary( inputs );