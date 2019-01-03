function labs = rt_cue_direction(labs)

is_cue_left_one = find( labs, {'congruent-left'} );
is_cue_right_one = find( labs, {'congruent-right'} );

% Cue is on opposite side as selection
is_cue_right_two_correct = find( labs, {'congruent-two', 'selected-left', 'correct-true'} );
is_cue_right_two_incorrect = find( labs, {'congruent-two', 'selected-right', 'correct-false'} );

is_cue_left_two_correct = find( labs, {'congruent-two', 'selected-right', 'correct-true'} );
is_cue_left_two_incorrect = find( labs, {'congruent-two', 'selected-left', 'correct-false'} );

is_cue_left_two = union( is_cue_left_two_correct, is_cue_left_two_incorrect );
is_cue_right_two = union( is_cue_right_two_correct, is_cue_right_two_incorrect );

is_cue_left = union( is_cue_left_one, is_cue_left_two );
is_cue_right = union( is_cue_right_one, is_cue_right_two );

addcat( labs, 'cue-direction' );
setcat( labs, 'cue-direction', 'left-cue', is_cue_left );
setcat( labs, 'cue-direction', 'right-cue', is_cue_right );

end