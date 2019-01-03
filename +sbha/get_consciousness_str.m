function str = get_consciousness_str(is_nonconscious)

str = ternary( is_nonconscious, 'nonconscious', 'conscious' );

end