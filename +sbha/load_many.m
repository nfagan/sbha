function files = load_many(kinds, varargin)

kinds = cellstr( kinds );
files = containers.Map();

for i = 1:numel(kinds)
  files(kinds{i}) = sbha.load1( kinds{i}, varargin{:} );
end

end