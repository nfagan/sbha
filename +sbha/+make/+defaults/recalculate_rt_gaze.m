function defaults = recalculate_rt_gaze(varargin)

defaults = sbha.get_common_make_defaults( varargin{:} );

defaults.t_window = [0, 1e3];
defaults.saccade_velocity_threshold = 300;
defaults.duration_samples_threshold = 50;

end