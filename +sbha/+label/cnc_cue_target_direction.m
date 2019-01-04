function labs = cnc_cue_target_direction(labs)

is_cue_left_congruent = find( labs, {'congruent-left', 'c-nc'} );
is_cue_right_congruent = find( labs, {'congruent-right', 'c-nc'} );

is_cue_left_incongruent = find( labs, {'incongruent-left', 'c-nc'} );
is_cue_right_incongruent = find( labs, {'incongruent-right', 'c-nc'} );

is_cue_left = union( is_cue_left_congruent, is_cue_left_incongruent );
is_cue_right = union( is_cue_right_congruent, is_cue_right_incongruent );

cue_targ_cat = 'cue-target-direction'; 

addcat( labs, cue_targ_cat );
setcat( labs, cue_targ_cat, 'left-cue', is_cue_left );
setcat( labs, cue_targ_cat, 'right-cue', is_cue_right );

end