conf = sbha.config.load();

files = {};
prefix = '';
do_save = true;

out = sbha_check_cue_presentation_time( ...
    'config', conf ...
  , 'files_containing', files ...
);

labels = out.labels';
cue_durations = out.presentation_duration;

assert_ispair( cue_durations, labels );

plot_p = fullfile( sbha.dataroot(conf), 'plots' ...
  , 'cue_presentation_durations', datestr(now, 'mmddyy') );

%%

pcats = { 'identifier', 'task-type', 'conscious-type' };

mask = fcat.mask( labels ...
  , @find, 'made-selection-true' ...
);

I = findall( labels, 'identifier', mask );

for i = 1:numel(I)
  pl = plotlabeled.make_common();
  subset_cue_durations = cue_durations(I{i}) * 1e3; % convert to ms
  subset_labels = labels(I{i});
  
  axs = pl.hist( subset_cue_durations, subset_labels, pcats, 100 );
  
  med = nanmedian( subset_cue_durations );
  
  shared_utils.plot.hold( axs, 'on' );
  shared_utils.plot.add_vertical_lines( axs, med );
  shared_utils.plot.xlabel( axs, 'Milliseconds' );
  
  if ( do_save )
    dsp3.req_savefig( gcf, plot_p, subset_labels, pcats, prefix );
  end
end
