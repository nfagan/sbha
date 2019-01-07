function selection_filename = get_trial_selection_criterion_filename(identifier, prefix)

if ( nargin < 2 )
  prefix = 'TRIALS_';
end

identifier_sans_ext = strrep( identifier, '.mat', '' );
selection_filename = sprintf( '%s%s.xlsx', prefix, identifier_sans_ext );

end