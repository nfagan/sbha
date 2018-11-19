
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = sbha.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( sbha.util.get_project_folder() );
PATHS.data_root = '';

% DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { 'shared_utils' };

% EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;

if ( do_save )
  sbha.config.save( conf );
end

end