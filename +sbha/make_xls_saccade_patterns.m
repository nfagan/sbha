function result = make_xls_saccade_patterns(varargin)

defaults = sbha_saccade_patterns_defaults();
params = sbha.parsestruct( defaults, varargin );

event_name = params.event_name;
conf = params.config;

data_root = conf.PATHS.data_root;

inputs = { fullfile('edf_trials', event_name), 'edf_events', 'unified', 'labels' };

loop_runner = sbha.get_looped_make_runner( params );

loop_runner.input_directories = cellfun( @(x) sbha.gid(x, params.config), inputs, 'un', 0 );
loop_runner.output_directory = fullfile( data_root, 'xls', 'saccade_patterns' );
loop_runner.get_filename_func = @(x) strrep( x, '.mat', '.xlsx' );
loop_runner.save_func = @save_xls_file;
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_xls_saccade_patterns_main, params );

end

function saccade_pattern_mat = make_xls_saccade_patterns_main(files, params)

outs = sbha_saccade_patterns( files, params );

mask = find( outs.labels, 'made-selection-true' );

saccade_pattern_mat = cellstr( outs.labels, {'saccade-pattern', 'subject'}, mask );

end

function save_xls_file(filename, saccade_pattern_mat)

xlswrite( filename, saccade_pattern_mat );

end