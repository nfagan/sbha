function results = make_unified(varargin)

defaults = sbha.get_common_make_defaults();

params = sbha.parsestruct( defaults, varargin );

conf = params.config;

raw_p = fullfile( sbha.dataroot(conf), 'raw' );

subdirs = shared_utils.io.dirnames( raw_p, 'folders' );

for i = 1:numel(subdirs)
  loop_runner = sbha.get_looped_make_runner( params );

  loop_runner.input_directories =     fullfile( raw_p, subdirs{i} );
  loop_runner.output_directory =      sbha.gid( 'unified', conf );
  loop_runner.get_identifier_func =   @get_identifier;
  loop_runner.find_files_func =       @shared_utils.io.findmat;
  loop_runner.load_func =             @load_func;
  loop_runner.func_name =             mfilename;
  loop_runner.call_with_identifier =  true;
  
  params.raw_p = raw_p;
  params.edf_components = { 'raw', subdirs{i}, 'edf' };
  
  result = loop_runner.run( @make_unified_main, params );
  
  if ( i == 1 )
    results = result;
  else
    results = [ results, result ];
  end
end

end

function unified_file = make_unified_main(files, identifier, params)

keys = shared_utils.general.keys( files );

assert( numel(keys) == 1, 'Expected one key; got %d', numel(keys) );

file = shared_utils.general.get( files, keys{1} );

end

function file = load_func(filename)
file = load( filename );
end

function id = get_identifier(file, filename)

tt = file.opts.STRUCTURE.trial_type;
ct = ternary( file.opts.STRUCTURE.is_masked, 'nc', 'c' );

date = strrep( filename(end-23:end), '_', ':' );

if ( shared_utils.char.ends_with(date, '.mat') )
  date = date(1:end-4);
end

id = sprintf( '%s-%s-%s.mat', ct, tt, date );

end