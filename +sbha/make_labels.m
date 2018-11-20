function result = make_labels(varargin)

defaults = sbha.get_common_make_defaults();

inputs = { 'trials', 'meta' };
output = 'labels';

[params, loop_runner] = sbha.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_labels_main, params );

end

function labels_file = make_labels_main(files, params)

trials_file = shared_utils.general.get( files, 'trials' );
meta_file = shared_utils.general.get( files, 'meta' );

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
  
  init_str = ternary( acq_init, 'initiated-true', 'initiated-false' );
  correct_str = ternary( was_correct, 'correct-true', 'correct-false' );
  select_str = ternary( made_selection, 'made-selection-true', 'made-selection-false' );
  selected_direction = sprintf( 'selected-%s', selected_direction );
  congruent_direction = sprintf( 'congruent-%s', congruent_direction );
  
  cats = { 'initiated', 'correct', 'made-selection' ...
    , 'selected-direction', 'congruent-direction' };
  
  tmp_labs = addcat( fcat(), cats );
  setcat( tmp_labs, cats, {init_str, correct_str, select_str ...
    , selected_direction, congruent_direction} );
  
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