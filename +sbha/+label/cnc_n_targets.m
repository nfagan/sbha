function labs = cnc_n_targets(labs)

addcat( labs, 'n-targets' );

is_one_target = find( labs, 'one-target' );
is_two_targets = find( labs, 'two-targets' );

setcat( labs, 'n-targets', 'n-targets-1', is_one_target );
setcat( labs, 'n-targets', 'n-targets-2', is_two_targets );

end