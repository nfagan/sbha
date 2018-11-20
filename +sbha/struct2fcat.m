function f = struct2fcat(x)

validateattributes( x, {'struct'}, {'scalar'}, mfilename );

vals = struct2cell( x )';
names = fieldnames( x );

is_valid = cellfun( @(x) ischar(x) || iscellstr(x), vals );

f = fcat.from( vals(is_valid), names(is_valid) );

end