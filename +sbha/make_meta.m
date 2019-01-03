function result = make_meta(varargin)

defaults = sbha.get_common_make_defaults();

inputs = 'unified';
output = 'meta';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_meta_main, params );

end

function meta_file = make_meta_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );

structure = unified_file.opts.STRUCTURE;
time_in = unified_file.opts.TIMINGS.time_in;

meta_file = struct();
meta_file.identifier = unified_file.identifier;
meta_file.params = params;
% 'c-nc' is default; 'rt' is also possible
meta_file.task_type = shared_utils.struct.field_or( structure, 'task_type', 'c-nc' );
meta_file.date = strrep( unified_file.identifier(end-23:end-4), '_', ':' );
meta_file.day = datestr( meta_file.date, 'mmddyy' );
meta_file.subject = unified_file.opts.META.subject;
meta_file.congruency = structure.trial_type;
meta_file.conscious_type = get_conscious_type( structure, time_in );
meta_file.target_type = sbha.get_target_str( structure.is_two_targets );
meta_file.randomization_id = structure.randomization_id;

end

function str = get_conscious_type(structure, time_in)

is_rt_task = isfield( structure, 'task_type' ) && strcmp( structure.task_type, 'rt' );

if ( is_rt_task )
  % For rt task, conscious condition shows cues for at least 0.25 seconds
  str = sbha.get_consciousness_str( time_in.rt_present_targets < 0.25 );
else
  str = sbha.get_consciousness_str( structure.is_masked );
end

end