function result = make_edf_trials(varargin)

defaults = sbha.make.defaults.edf_trials();
params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;

inputs = { 'edf', 'edf_events' };
output = fullfile( 'edf_trials', event_name );

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @sbha.make.edf_trials, params );

end