function result = make_xls_summary(varargin)

defaults = sbha.get_common_make_defaults();
defaults.format = 'xls';

params = sbha.parsestruct( defaults, varargin );
params.format = validatestring( params.format, {'xls'}, mfilename, 'format' );

conf = params.config;

loop_runner = sbha.get_looped_make_runner( params );

loop_runner.input_directories = sbha.gid( 'unified', conf );
loop_runner.output_directory = fullfile( sbha.dataroot(conf), 'xls', 'trial_data' );
loop_runner.save_func = get_save_func( params.format );
loop_runner.func_name = mfilename;
loop_runner.get_filename_func = get_filename_func( params.format );

result = loop_runner.run( @make_xls_summary_main, params );

end

function xls_summary = make_xls_summary_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );
xls_summary = sbha.to_xls_compatible_summary( unified_file );

end

function save_xls_file(filename, summary)

sheet_names = fieldnames( summary );

for i = 1:numel(sheet_names)
  sheet_name = sheet_names{i};
  sheet = summary.(sheet_name);
  
  xlswrite( filename, sheet, sheet_name );
end

end

function save_csv_file(filename, summary)

sheet_names = fieldnames( summary );
dir_name = filename(1:end-4);
shared_utils.io.require_dir( dir_name );

for i = 1:numel(sheet_names)
  sheet_name = sheet_names{i};
  sheet = summary.(sheet_name);
  
  converted = xls_to_csv( sheet );
  
  full_name = fullfile( dir_name, sprintf('%s.csv', sheet_name) );
  
  csvwrite( full_name, converted );
end

end

function func = get_filename_func(format)

switch ( format )
  case 'xls'
    func = @(x) strrep( x, '.mat', '.xls' );
  case 'csv'
    func = @(x) strrep( x, '.mat', '.csv' );
  otherwise
    error( 'Unimplemented format: "%s".', format );
end
  
end

function func = get_save_func(format)

switch ( format )
  case 'xls'
    func = @save_xls_file;
  case 'csv'
    func = @save_csv_file;
  otherwise
    error( 'Unimplemented format: "%s".', format );
end
  
end

function out = xls_to_csv(sheet)

out = char( cellfun(@num2str, sheet, 'un', 0) );

end