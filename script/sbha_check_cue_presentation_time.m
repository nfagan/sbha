function out = sbha_check_cue_presentation_time(varargin)

inputs = { 'events', 'labels' };
defaults = sbha.get_common_make_defaults();

[params, runner] = sbha.get_params_and_loop_runner( inputs, '', defaults, varargin );
runner.convert_to_non_saving_with_output();

results = runner.run( @main );
results(~[results.success]) = [];
outputs = [ results.output ];

out = struct();
out.presentation_duration = vertcat( outputs.presentation_duration );
out.labels = vertcat( fcat(), outputs.labels );

end

function out = main(files)

events_file = shared_utils.general.get( files, 'events' );
labels_file = shared_utils.general.get( files, 'labels' );

labels = fcat.from( labels_file );

event_times = events_file.events;
event_key = events_file.event_key;

task_type = char( combs(labels, 'task-type') );
offset_event = 'mask_onset';

switch ( task_type )
  case 'c-nc'
    onset_event = 'target_onset';
    conscious_type = char( combs(labels, 'conscious-type') );
    
    if ( strcmp(conscious_type, 'conscious') )
      offset_event = 'choice_feedback';
    end
  case 'rt'
    onset_event = 'cue_onset';
  otherwise
    error( 'Unaccounted for task type: "%s".', task_type )
end

try
  onset_times = event_times(:, event_key(onset_event));
  offset_times = event_times(:, event_key(offset_event));
catch err
  error( 'Missing some events: "%s | %s".', onset_event, offset_event );
end

presentation_duration = offset_times - onset_times;

out = struct();
out.presentation_duration = presentation_duration;
out.labels = labels;

end