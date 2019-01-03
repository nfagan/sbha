function outs = sbha_run_binned_position_frequency_timecourse(varargin)

defaults = sbha_binned_position_frequency_timecourse_defaults();
params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;

inputs = { fullfile('edf_trials', event_name), 'edf_events', 'unified', 'labels' };

[~, loop_runner] = sbha.get_params_and_loop_runner( inputs, '', defaults, varargin );
loop_runner.convert_to_non_saving_with_output();

results = loop_runner.run( @sbha_binned_position_frequency_timecourse, params );

results(~[results.success]) = [];

if ( isempty(results) )
  outs = struct();
  outs = outs(false);
  return
end

outputs = [ results.output ];
identifiers = { results.file_identifier };

counts = { outputs.counts };
labels = { outputs.labels };
event_indices = { outputs.event_indices };

counts_t = outputs(1).counts_t;
edges = outputs(1).edges;
params = outputs(1).params;

counts = vertcat( counts{:} );
event_indices = vertcat( event_indices{:} );
labels = vertcat( fcat, labels{:} );

assert_ispair( counts, labels );

outs = struct();
outs.params = params;
outs.counts = counts;
outs.labels = labels;
outs.counts_t = counts_t;
outs.edges = edges;
outs.identifiers = identifiers;
outs.event_indices = event_indices;

end