function sbha_make_xls(varargin)

defaults = sbha.get_common_make_defaults();

params = sbha.parsestruct( defaults, varargin );

raw_data_p = fullfile( sbha.dataroot(params.config), 'raw' );
folders = shared_utils.io.dirnames( raw_data_p, 'folders' );

sbha.make_unified( folders, params );
sbha.make_xls_summary( params );

end