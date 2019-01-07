function use_trial_index = get_trial_selection_criterion(selection_filename, conf)

if ( nargin < 2 || isempty(conf) )
  conf = sbha.config.load();
end

selection_dir = fullfile( sbha.dataroot(conf), 'misc', 'position_frequency_trial_selection' );
selection_file = fullfile( selection_dir, selection_filename );

if ( ~shared_utils.io.fexists(selection_file) )
  error( 'No such file: "%s".', selection_file );
end

xls = xlsread( selection_file );

try
  use_trial_index = parse_trial_selection_excel_file( xls );
catch err
  throw( err );
end


end

function use_trial_index = parse_trial_selection_excel_file(xls)

validateattributes( xls, {'double'}, {'column'}, mfilename, 'xls file' );
use_trial_index = xls;

end
