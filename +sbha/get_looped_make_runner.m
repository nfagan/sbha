function obj = get_looped_make_runner(params)

if ( nargin < 1 || isempty(params) )
  params = sbha.get_common_make_defaults();
end

obj = shared_utils.pipeline.LoopedMakeRunner;
obj.save = params.save;
obj.is_parallel = params.is_parallel;
obj.overwrite = params.overwrite;
obj.filter_files_func = @(x) sbha.files_containing( x, params.files_containing );
obj.log_level = params.log_level;
obj.files_aggregate_type = 'containers.Map';

end