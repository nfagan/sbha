function axs = plot_traces(t, x, y, time_points, x_points, y_points, varargin)

defaults = struct();
defaults.y_lims = [];
defaults.time_point_colors = [];
defaults.x_point_colors = [];
defaults.y_point_colors = [];
params = sbha.parsestruct( defaults, varargin );

if ( nargin < 4 )
  time_points = [];
end

if ( nargin < 5 )
  x_points = [];
end

if ( nargin < 6 )
  y_points = [];
end

axs = {};

ax = subplot( 1, 2, 1 );
axs{1} = ax;
cla( ax );

plot( ax, t, x, 'r' );
hold( ax, 'on' );
configure_axes_common( ax, t, params );

t_hs = shared_utils.plot.add_vertical_lines( ax, time_points );
x_hs = shared_utils.plot.add_horizontal_lines( ax, x_points );

configure_line_colors( t_hs, params.time_point_colors );
configure_line_colors( x_hs, params.x_point_colors );

ax = subplot( 1, 2, 2 );
cla( ax );
axs{2} = ax;

plot( ax, t, y, 'b' );
hold( ax, 'on' );
configure_axes_common( ax, t, params );

t_hs = shared_utils.plot.add_vertical_lines( ax, time_points );
y_hs = shared_utils.plot.add_horizontal_lines( ax, y_points );

configure_line_colors( t_hs, params.time_point_colors );
configure_line_colors( y_hs, params.y_point_colors );

axs = [ axs{:} ];

end

function configure_line_colors(hs, colors)

if ( isempty(colors) )
  return;
end

if ( numel(colors) ~= numel(hs) )
  error( 'Colors do not match lines.' );
end

arrayfun( @(x, y) set(x, 'color', y{1}), hs(:)', colors(:)' );

end

function configure_axes_common(ax, t, params)

xlim( ax, [min(t), max(t)] );

if ( ~isempty(params.y_lims) )
  ylim( ax, params.y_lims );
end

end
