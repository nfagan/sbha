function out = sbha_recalculate_rt_gaze(varargin)

defaults = sbha.make.defaults.recalculate_rt_gaze();

inputs = { 'edf_trials/rt_target_onset', 'labels', 'unified' };

[params, runner] = sbha.get_params_and_loop_runner( inputs, '', defaults, varargin );
runner.convert_to_non_saving_with_output();

results = runner.run( @main, params );
outputs = shared_utils.pipeline.extract_outputs_from_results( results );

if ( isempty(outputs) )
  out = struct();
  out.labels = fcat();
  out.gaze_rt = [];
  out.original_rt = [];
  out.x = [];
  out.y = [];
  out.t = [];
  out.left_rect = [];
  out.right_rect = [];
else
  out = shared_utils.struct.soa( outputs );
  out.t = out.t(1, :);
end

end

function out = main(files, params)

out = sbha.make.recalculate_rt_gaze( files, params );

end