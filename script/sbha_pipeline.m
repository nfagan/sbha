inputs = struct();

sbha.make_unified( inputs );

%%

sbha.make_xls_summary( inputs, 'files_containing', 'nc-congruent-twotarg-30-Nov-2018 16_17_57'  );

%%
              
sbha.make_events( inputs );

%%

sbha.make_trials( inputs );
sbha.make_meta( inputs );
sbha.make_labels( inputs );

%%

sbha.make_edfs( inputs );
