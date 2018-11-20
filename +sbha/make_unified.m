function results = make_unified(subdirs, varargin)

defaults = sbha.get_common_make_defaults();

params = sbha.parsestruct( defaults, varargin );

conf = params.config;

raw_p = fullfile( sbha.dataroot(conf), 'raw' );

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

unified_file = shared_utils.general.get( files, keys{1} );

unified_file.identifier = identifier;
unified_file.edf_components = cshorzcat( params.edf_components, unified_file.edf_file );

end

function file = load_func(filename)
file = load( filename );
end

function id = get_identifier(file, filename)

s = file.opts.STRUCTURE;

trial_type = s.trial_type;
consciousness_type = ternary( s.is_masked, 'nc', 'c' );
target_type = ternary( s.is_two_targets, 'twotarg', 'onetarg' );

date = filename(end-23:end);

if ( shared_utils.char.ends_with(date, '.mat') )
  date = date(1:end-4);
end

id = sprintf( '%s-%s-%s-%s.mat', consciousness_type, trial_type, target_type, date );

end