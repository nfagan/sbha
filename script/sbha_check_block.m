dat = sbha.load1('unified', 'nc-incongruent');

%%

data = dat.DATA;

trial_ns = 1:numel(data);
did_select = [ data.made_selection ];
entered_break = arrayfun( @(x) isfield(x.events, 'break_display_image') && ...
  ~isnan(x.events.break_display_image), data );

break_starts = find( entered_break );

inds = zeros( numel(break_starts)-1, 1 );

for i = 1:numel(break_starts)-1
  start = break_starts(i) + 1;
  stop = break_starts(i+1) - 1;
  
  inds(i) = sum( did_select(start:stop) );
end
%%

conf = sbha.config.load();

fcats = cellfun( @(x) fcat.from(shared_utils.io.fload(x)) ...
  , shared_utils.io.findmat(sbha.gid('labels', conf)), 'un', 0 );

labs = vertcat( fcat(), fcats{:} );

%%
