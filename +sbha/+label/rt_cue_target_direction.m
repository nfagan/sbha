function labs = rt_cue_target_direction(labs)

is_cue_left = find( labs, {'congruent-left'} );
is_cue_right = find( labs, {'congruent-right'} );

% Cue is on opposite side as selection
is_target_right_two_correct = find( labs, {'congruent-two', 'selected-right', 'correct-true'} );
is_target_right_two_incorrect = find( labs, {'congruent-two', 'selected-left', 'correct-false'} );

is_target_left_two_correct = find( labs, {'congruent-two', 'selected-left', 'correct-true'} );
is_target_left_two_incorrect = find( labs, {'congruent-two', 'selected-right', 'correct-false'} );

is_target_left = union( is_target_left_two_correct, is_target_left_two_incorrect );
is_target_right = union( is_target_right_two_correct, is_target_right_two_incorrect );

cue_targ_cat = 'cue-target-direction'; 

addcat( labs, cue_targ_cat );
setcat( labs, cue_targ_cat, 'left-cue', is_cue_left );
setcat( labs, cue_targ_cat, 'right-cue', is_cue_right );

setcat( labs, cue_targ_cat, 'left-target', is_target_left );
setcat( labs, cue_targ_cat, 'right-target', is_target_right );

end