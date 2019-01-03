function result = make_edf_events(varargin)

defaults = sbha.get_common_make_defaults();

inputs = { 'unified', 'edf', 'events' };
output = 'edf_events';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @sbha.make.edf_events );

end