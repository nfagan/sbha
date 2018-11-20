inputs = struct();

sbha.make_unified( inputs );

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
