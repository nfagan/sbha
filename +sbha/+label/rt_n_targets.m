function labs = rt_n_targets(labs)

addcat( labs, 'n-targets' );

is_two_targets = find( labs, 'congruent-two' );
is_one_target = find( labs, {'congruent-left', 'congruent-right'} );

setcat( labs, 'n-targets', 'n-targets-2', is_two_targets );
setcat( labs, 'n-targets', 'n-targets-1', is_one_target );

end