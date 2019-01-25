function outs = sbha_run_saccade_patterns(varargin)

defaults = sbha_saccade_patterns_defaults();
params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;

inputs = { fullfile('edf_trials', event_name), 'edf_events', 'unified', 'labels' };

[~, loop_runner] = sbha.get_params_and_loop_runner( inputs, '', defaults, varargin );
loop_runner.convert_to_non_saving_with_output();

results = loop_runner.run( @sbha_saccade_patterns, params );

results(~[results.success]) = [];

if ( isempty(results) )
  outs = struct();
  outs = outs(false);
  return
end

outputs = [ results.output ];

outs = struct();
outs.labels = vertcat( fcat, outputs.labels );

end