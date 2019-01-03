function labs = monkey_from_subject(labs)

addcat( labs, 'monkey' );

subjects = combs( labs, 'subject' );
lowercase_subjects = lower( subjects );

monks = { 'ephron', 'hitch', 'lynch', 'tarantino' };

for i = 1:numel(subjects)
  for j = 1:numel(monks)
    is_match = ~isempty( strfind(lowercase_subjects{i}, monks{j}) );
    
    if ( is_match )
      matching_ind = find( labs, subjects{i} );
      setcat( labs, 'monkey', sprintf('monkey-%s', monks{j}), matching_ind );
      break;
    end
  end
end

end