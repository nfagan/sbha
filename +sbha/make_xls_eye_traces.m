function result = make_xls_eye_traces(varargin)

defaults = sbha.get_common_make_defaults();
defaults.event_name = '';
defaults.bin_size = 1;

[params, loop_runner] = sbha.get_params_and_loop_runner( '', '', defaults, varargin );

event_name = params.event_name;
conf = params.config;
data_root = sbha.dataroot( conf );

inputs = sbha.gid( fullfile('edf_trials', event_name), conf );
output = fullfile( data_root, 'xls', 'eye_data' );

loop_runner.input_directories = inputs;
loop_runner.output_directory = output;
loop_runner.get_filename_func = @(x) strrep( x, '.mat', '.xls' );
loop_runner.save_func = @save_xls_file;
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_xls_eye_data_main, params );

end

function eye_data = make_xls_eye_data_main(files, params)

event_name = params.event_name;
bin_size = params.bin_size;

validateattributes( params.bin_size, {'numeric'}, {'scalar', 'integer'} ...
  , mfilename, 'bin_size' );

edf_trials_file = shared_utils.general.get( files, event_name );
key = edf_trials_file.key;

x = edf_trials_file.aligned(:, :, key('x'));
y = edf_trials_file.aligned(:, :, key('y'));
t = edf_trials_file.t;

if ( bin_size ~= 1 )
  x = bin_mat( x, bin_size );
  y = bin_mat( y, bin_size );
  t = bin_mat( t(:)', bin_size, @(x) x(1) );
end

eye_data = struct();
eye_data.x = x;
eye_data.y = y;
eye_data.t = t;

end

function all_binned = bin_mat(mat, bin_size, summarize_func)

if ( nargin < 3 )
  summarize_func = @nanmean;
end

N = rows( mat );

for i = 1:N
  binned = shared_utils.vector.slidebin( mat(i, :), bin_size, bin_size );
  binned = cellfun( summarize_func, binned );
  
  if ( i == 1 )
    all_binned = nan( N, size(binned, 2) );
  end
  
  all_binned(i, :) = binned;
end

end

function save_xls_file(filename, summary)

sheet_names = fieldnames( summary );

for i = 1:numel(sheet_names)
  sheet_name = sheet_names{i};
  sheet = summary.(sheet_name);
  
  xlswrite( filename, sheet, sheet_name );
end

end