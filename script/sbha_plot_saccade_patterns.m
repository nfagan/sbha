%%

% files = {'nc-congruent-twotarg-03-Dec-2018' ...
%   , '04-Dec-2018 16_47_05'};

files = { ...
    'nc-congruent-twotarg-03-Dec-2018 16_27_28' ...
  , 'nc-congruent-twotarg-03-Dec-2018 16_14_54' ...
  , 'nc-congruent-twotarg-03-Dec-2018 17_54_41' ...
  , '04-Dec-2018 16_47_05' ...
  };

is_rt_task = true;

event_name = ternary( is_rt_task, 'cue_onset', 'target_onset' );

outs = sbha_run_saccade_patterns( ...
    'files_containing', files ...
  , 'is_parallel', true ...
  , 'event_name', event_name ...
  , 'time_offsets', [0, 1000] ...
);

labs = outs.labels';

%%

plot_percents = true;

pl = plotlabeled.make_common();

mask = fcat.mask( labs ...
  , @find, 'made-selection-true' ...
  , @find, 'rt' ...
);

if ( plot_percents )  
  perc_each = { 'conscious-type' };  
  percs_of = { 'saccade-pattern' };
  
  [pltdat, pltlabs] = proportions_of( labs', perc_each, percs_of, mask );
else
  pltlabs = labs(mask);
  pltdat = rowones( numel(mask) );
  pl.summary_func = @sum;
end

xcats = { 'saccade-pattern' };
gcats = { 'conscious-type' };
pcats = {};

axs = pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

