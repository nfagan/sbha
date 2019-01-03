function defaults = edf_trials(varargin)

defaults = sbha.get_common_make_defaults( varargin{:} );
defaults.look_back = -500;
defaults.look_ahead = 500;
defaults.event_name = '';

end