function start_stops = find_saccades(x, y, varargin)

defaults = struct();
defaults.saccade_velocity_threshold = 300;
defaults.duration_samples_threshold = 50;
defaults.smooth_func = @(data) smoothdata( data, 'smoothingfactor', 0.05 );

params = sbha.parsestruct( defaults, varargin );

% Otherwise, find saccadd
smooth_func = params.smooth_func;

vel_thresh = params.saccade_velocity_threshold;
dur_thresh = params.duration_samples_threshold;

start_stops = hwwa.find_saccades( x, y, 1e3, vel_thresh, dur_thresh, smooth_func );

end