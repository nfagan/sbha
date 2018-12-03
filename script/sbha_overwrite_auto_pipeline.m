inputs = struct();
inputs.overwrite = true;

raw_data_p = fullfile( sbha.util.get_project_folder(), 'data', 'raw' );
folders = shared_utils.io.dirnames( raw_data_p, 'folders' );

sbha.make_unified( folders, inputs );

%%

sbha.make_xls_summary( inputs );

%%
              
sbha.make_events( inputs );

%%

sbha.make_trials( inputs );
sbha.make_meta( inputs );
sbha.make_labels( inputs );

%%

sbha.make_edfs( inputs );
