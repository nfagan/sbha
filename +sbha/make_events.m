function result = make_events(varargin)

defaults = sbha.get_common_make_defaults();

inputs = 'unified';
output = 'events';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_events_main, params );

end

function events_file = make_events_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );

dat = unified_file.DATA;

[~, I] = max( arrayfun(@(x) numel(fieldnames(x.events)), dat) );

event_names = fieldnames( dat(I).events );

n_trials = numel( dat );
n_event_types = numel( event_names );

events = nan( n_trials, n_event_types );
event_key = containers.Map();

for i = 1:n_trials
  evts = dat(i).events;
  
  for j = 1:n_event_types
    event_name = event_names{j};
    
    if ( i == 1 ), event_key(event_name) = j; end
    if ( ~isfield(evts, event_name) ), continue; end
    
    events(i, j) = evts.(event_name);
  end
end

events_file = struct();
events_file.identifier = unified_file.identifier;
events_file.params = params;
events_file.events = events;
events_file.event_key = event_key;

end