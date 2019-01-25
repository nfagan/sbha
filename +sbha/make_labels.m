function result = make_labels(varargin)

defaults = sbha.get_common_make_defaults();

inputs = { 'trials', 'meta' };
output = 'labels';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_labels_main, params );

end

function labels_file = make_labels_main(files, params)

import shared_utils.struct.field_or;

trials_file = shared_utils.general.get( files, 'trials' );
meta_file = shared_utils.general.get( files, 'meta' );

task_type = meta_file.task_type;
congruency = meta_file.congruency;

trial_dat = trials_file.data;
n_trials = numel( trial_dat );

labs = fcat();

for i = 1:n_trials
  current_trial = trial_dat(i);
  
  acq_init = current_trial.acquired_initial_fixation;
  made_selection = current_trial.made_selection;
  selected_direction = current_trial.selected_direction;
  congruent_direction = current_trial.direction;  
  was_correct = current_trial.was_correct;
  
  if ( isempty(congruent_direction) )
    congruent_direction = 'none';
  end
  
  if ( isempty(selected_direction) )
    selected_direction = 'none';
  end
  
  correct_direction = get_correct_direction( ...
    task_type, congruent_direction, congruency, current_trial );
  
  randomization_id = meta_file.randomization_id;
  
  init_str = ternary( acq_init, 'initiated-true', 'initiated-false' );
  correct_str = ternary( was_correct, 'correct-true', 'correct-false' );
  select_str = ternary( made_selection, 'made-selection-true', 'made-selection-false' );
  selected_direction = sprintf( 'selected-%s', selected_direction );
  congruent_direction = sprintf( 'congruent-%s', congruent_direction );
  correct_direction = sprintf( 'correct-%s', correct_direction );
  randomization_str = sprintf( 'randomization-%s', randomization_id );
  
  cats = { 'initiated', 'correct', 'made-selection' ...
    , 'selected-direction', 'congruent-direction' ...
    , 'correct-direction', 'randomization' };
  
  tmp_labs = addcat( fcat(), cats );
  setcat( tmp_labs, cats, {init_str, correct_str, select_str ...
    , selected_direction, congruent_direction, correct_direction, randomization_str} );
  
  append( labs, tmp_labs );
end

meta_labs = sbha.struct2fcat( meta_file );
meta_cats = getcats( meta_labs );

for i = 1:numel(meta_cats)
  renamecat( meta_labs, meta_cats{i}, strrep(meta_cats{i}, '_', '-') );
end

join( labs, meta_labs );

labels_file = struct();
labels_file.identifier = trials_file.identifier;
labels_file.params = params;
labels_file.labels = categorical( labs );
labels_file.categories = getcats( labs );

end

function str = get_opposite_direction(congruent_direction)

str = char( setdiff({'left', 'right'}, congruent_direction) );

end

function str = get_correct_direction(task_type, congruent_direction, congruency, current_trial)

is_congruent = strcmp( congruency, 'congruent' );

switch ( task_type )
  case 'rt'
    if ( isfield(current_trial, 'rt_correct_direction') )
      % Newer data embeds the correct direction directly.
      str = current_trial.rt_correct_direction;
    else
      if ( strcmp(congruent_direction, 'two') )
        % Older two-star trials were erroneously always on the right
        str = 'right';
      else
        % Correct is always incongruent.
        str = get_opposite_direction( congruent_direction );
      end
    end
  case 'c-nc'
    if ( is_congruent )
      str = congruent_direction;
    else
      str = get_opposite_direction( congruent_direction );
    end
  otherwise
    error( 'Correct direction not implemented for task type: "%s".', task_type );
end
end