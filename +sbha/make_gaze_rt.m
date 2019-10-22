function result = make_gaze_rt(varargin)

defaults = sbha.make.defaults.recalculate_rt_gaze();

inputs = { 'edf_trials/rt_target_onset', 'labels', 'unified' };
output = 'gaze_rt';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @sbha.make.recalculate_rt_gaze, params );

end