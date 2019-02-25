function summary = to_xls_compatible_summary(unified_file)

summary = struct();
summary.trial_data = get_trial_data( unified_file );
summary.events = get_event_info( unified_file );
summary.timing_info = get_timing_info( unified_file );
summary.stimulus_info = get_stimulus_info( unified_file );
summary.meta_info = get_meta_info( unified_file );

end

function meta = get_meta_info(unified_file)

id = unified_file.identifier;

date = strrep( id(end-23:end-4), '_', ':' );
subject = unified_file.opts.META.subject;
notes = unified_file.opts.META.notes;

meta = cell( 2, 3 );
meta(1, :) = { 'date', 'subject', 'notes' };
meta(2, :) = { date, subject, notes };

end

function stim_mat = get_stimulus_info(unified_file)

stim_setup = unified_file.opts.STIMULI.setup;

stim_names = fieldnames( stim_setup );
[~, I] = max( structfun(@(x) numel(fieldnames(x)), stim_setup) );

non_used_fields = { 'non_editable', 'image_matrix', 'class', 'placement' };

use_fields = cssetdiff( fieldnames(stim_setup.(stim_names{I})), non_used_fields );

stim_mat = cell( numel(stim_names) + 1, numel(use_fields)+1 );

stim_mat(1, :) = cshorzcat( 'name', use_fields(:)' );

for i = 1:numel(stim_names)
  stimulus = stim_setup.(stim_names{i});
  stim_mat{i+1, 1} = stim_names{i};
  
  for j = 1:numel(use_fields)
    if ( ~isfield(stimulus, use_fields{j}) ), continue; end
    
    val = stimulus.(use_fields{j});
    
    if ( ~ischar(val) && numel(val) > 1 ), val = mat2str( val ); end
    
    stim_mat{i+1, j+1} = val;
  end
end

end

function timing = get_timing_info(unified_file)

time_in = unified_file.opts.TIMINGS.time_in;
timing = [ fieldnames(time_in)'; struct2cell(time_in)' ];

end

function events = get_event_info(unified_file)

dat = unified_file.DATA;

if ( isempty(dat) )
  events = [];
  return
end

[~, I] = max( arrayfun(@(x) numel(fieldnames(x.events)), dat) );

event_names = fieldnames( dat(I).events );

sz = [ numel(dat) + 1, numel(event_names) ];
events = cellfun( @(x) nan(1), cell(sz), 'un', 0 );
events(1, :) = event_names;

for i = 1:numel(dat)
  evts = dat(i).events;
  
  for j = 1:numel(event_names)
    if ( ~isfield(evts, event_names{j}) ), continue; end
    
    events{i+1, j} = evts.(event_names{j});
  end
end

end

function summary = get_trial_data(unified_file)

scalar_fields = { 'acquired_initial_fixation', 'was_correct', 'made_selection' ...
  , 'direction', 'selected_direction' };

if ( unified_file.opts.STRUCTURE.is_two_targets )
  targ_type = 'two-targets';
else
  targ_type = 'one-target';
end

if ( unified_file.opts.STRUCTURE.is_masked )
  consciousness_type = 'nonconscious';
else
  consciousness_type = 'conscious';
end

trial_type = unified_file.opts.STRUCTURE.trial_type;
trial_data = unified_file.DATA;
rt_target_field = 'rt_correct_direction';

is_objective_trial_type = strcmp( trial_type, 'objective' );

if ( isfield(trial_data, rt_target_field) )
  scalar_fields{end+1} = rt_target_field;
end

ncols = numel( scalar_fields ) + 3;
nrows = numel( trial_data ) + 1;

header = cshorzcat( scalar_fields, 'target_type', 'consciousness_type', 'congruency' );

summary = cell( nrows, ncols );
summary(1, :) = header;

for i = 1:numel(trial_data)
  for j = 1:numel(scalar_fields)
    scalar_field = scalar_fields{j};
    
    if ( is_objective_trial_type )
      summary{i+1, j} = get_objective_trial_data( trial_data, scalar_field, i );
    else
      summary{i+1, j} = trial_data(i).(scalar_field);
    end
  end
  
  summary{i+1, j+1} = targ_type;
  summary{i+1, j+2} = consciousness_type;
  summary{i+1, j+3} = trial_type;
end

rt = get_rt( unified_file );
rt_cell = arrayfun( @(x) x, rt, 'un', 0 );
summary(2:end, end+1) = rt_cell;
summary{1, end} = 'rt';

end

function res = get_objective_trial_data(trial_data, fieldname, trial_number)

res = trial_data(trial_number).(fieldname);

switch ( fieldname )
  case { 'was_correct', 'selected_direction' }
    selected_index = trial_data(trial_number).selected_target_index;
    direction = trial_data(trial_number).direction;
    
    if ( strcmp(fieldname, 'was_correct') )
      res = objective_was_correct( selected_index, direction );
      
    elseif ( strcmp(fieldname, 'selected_direction') )
      if ( isnan(selected_index) )
        res = '';
      elseif ( selected_index == 1 )
        res = 'left';
      else
        assert( selected_index == 2, 'Unhandled case: %d.', selected_index );
        res = 'right';
      end
    else
      error( 'Unhandled case: "%s".', fieldname );
    end
end

end

function was_correct = objective_was_correct(selected_index, direction)

correct_left = selected_index == 1 && strcmp( direction, 'left' );
correct_right = selected_index == 2 && strcmp( direction, 'right' );

was_correct = correct_left || correct_right;

end

function rt = get_rt(unified_file)

trial_data = unified_file.DATA;
structure = unified_file.opts.STRUCTURE;

rt = nan( numel(trial_data), 1 );

if ( ~isfield(structure, 'task_type') || ~strcmp(structure.task_type, 'rt') )
  return
end

stim = unified_file.opts.STIMULI.setup.left_image1;

choice_time = stim.target_duration;

for i = 1:numel(trial_data)  
  events = trial_data(i).events;
  
  targ_on = shared_utils.struct.field_or( events, 'rt_target_onset', nan );
  targ_acq = shared_utils.struct.field_or( events, 'target_acquired', nan );
  
  rt(i) = targ_acq - targ_on - choice_time;
end

end