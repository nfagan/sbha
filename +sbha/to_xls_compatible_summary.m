function summary = to_xls_compatible_summary(unified_file)

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

ncols = numel( scalar_fields ) + 3;
nrows = numel( trial_data ) + 1;

header = cshorzcat( scalar_fields, 'target_type', 'consciousness_type', 'congruency' );

summary = cell( nrows, ncols );
summary(1, :) = header;

for i = 1:numel(trial_data)
  for j = 1:numel(scalar_fields)
    summary{i+1, j} = trial_data(i).(scalar_fields{j});
  end
  
  summary{i+1, j+1} = targ_type;
  summary{i+1, j+2} = consciousness_type;
  summary{i+1, j+3} = trial_type;
end

d = 10;


end