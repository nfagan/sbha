function result = make_trials(varargin)

defaults = sbha.get_common_make_defaults();

inputs = 'unified';
output = 'trials';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_trial_main, params );

end

function trials_file = make_trial_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );

dat = unified_file.DATA;

trial_dat = rmfield( dat, {'events', 'errors', 'image_info'} );

trials_file = struct();
trials_file.identifier = unified_file.identifier;
trials_file.params = params;
trials_file.data = trial_dat;

end