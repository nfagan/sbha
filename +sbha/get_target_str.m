function str = get_target_str(is_two_targets)

str = ternary( is_two_targets, 'two-targets', 'one-target' );

end