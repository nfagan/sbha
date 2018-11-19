function result = make_edfs(varargin)

defaults = sbha.get_common_make_defaults();

inputs = 'unified';
output = 'edf';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_edf_main, params );

end

function edf_file = make_edf_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );

data_root = sbha.dataroot( params.config );

edf_filename = fullfile( data_root, unified_file.edf_components{:} );

edf_obj = Edf2Mat( edf_filename );

edf_file = struct();
edf_file.identifier = unified_file.identifier;
edf_file.params = params;

messages = edf_obj.Events.Messages;

is_sync_msg = strcmp( messages.info, 'RESYNCH' );

edf_file.x = edf_obj.Samples.posX;
edf_file.y = edf_obj.Samples.posY;
edf_file.t = edf_obj.Samples.time;
edf_file.pupil = edf_obj.Samples.pupilSize;
edf_file.sync_times = messages.time(is_sync_msg);

end