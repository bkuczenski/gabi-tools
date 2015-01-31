function S=wfread(G,use,opt)
% function S=wfread(G)
% creates a scenario data structure from a GaBi category structure according to
% arguments or chartconfig.  G should come from Gcats.
%
% Generates a structure array with the following fields:
% (first entry only):
%   xls
%   sheet
%   groups
%   groupnames
% (array: uses - or unique first column headings in gabi paste)
%   name: NAME of use
%   category: array of length G.cats
%    name: NAME of category
%    units: units of category
%    data: extracted data
%    stages: extracted stages
%    S(i).category(j).name=G.cats(j).name;
%    S(i).category(j).units=G.cats(j).units;
%    S(i).name=use(i);
%    S(i).category(j).data=dat;
%    S(i).category(j).stages=stg;
%   
%
% function S=wfread(G,use)
% specify which cases to use.  cases are unique first-row header entries.
%
% note: this function is still wonky.  note that quantity-view pastes are
% different from flow-view pastes in that the former do not have total rows. 

% Teplate is results-ver1.53_Template.xlsx.  GaBi data should be pasted into 'GaBi
% Paste'!B4 or 'GaBi Paste'!C4 depending on the hierarchy level selected in quantity
% view.  all other information is determined automatically from the spreadsheet.
%
% use = which scenarios to include.  cell array of strings.  scenario names are
% drawn from row 6 of the% gabi paste.
% 
% cats = which categories to include.  vector of doubles or cell array of double
% vectors.  Category names are drawn from column F of the spreadsheet.  The doubles
% should be indexed from the TOP OF THE DATA SET (i.e. count from the first
% non-header row).  In the cell array case, the rows in each vector are added
% together.  If the [autodetected] units for added rows don't match, throws an error!
%
% The column structure is configured in chartconfig.
%
% function S=wfread(G,use,opt)
% with a third argument, configure output in an ad hoc fashion.
% opt=
%      absent or 0: in_stages default with management hack
%      1: improper: read all into stacked data, 3-bar condensed mgmt
%      1.5: improper: read all into stacked data, 1-bar conseq total mgmt
%      2: DIM: all 3 conseq net totals stacked
%
% can be all done in post

cases=unique(G.H(1,cellfun(@isstr,G.H(1,:))));

if nargin<3
  opt=0;
end

if nargin<2 | isempty(use)
  use=cases;
else
  use=intersect(use,cases);
end

% sort use entries by the order they appear in H
for i=1:length(use)
  firstind(i)=min(find(strcmp(G.H(1,cellfun(@isstr,G.H(1,:))),use{i})));
end
[~,I]=sort(firstind);
use=use(I);

fprintf('Selecting cases:\n')
fprintf('%30s\n',use{:})

t=G.cats.name;

% long term plan: everything is contextual
% we make a list of level 2 groups to handle separately
%
% short term plan: we specify which level 2+3 groups to use in chartconfig
%
chartconfig
%G=Gopen(xls,sheet);
S.xls=G.xls;
S.sheet=G.sheet;

t={G.cats.name};
for j=1:length(G.cats)
  dd(j,:)=G.cats(j).data;
end

% now pull the data from columns as configured
%
S.groups=in_groups;
S.groupnames=in_stages;

for j=1:length(G.cats)
  for i=1:length(use)
    % reimplement from scratch: we are populating:
    % S(i).categories(j).data
    % S(i).categories(j).stages
    % and the question is how we group a data row into stages
    % 2nd row of H is "groups" 
    % if H has 2 rows-- just create one data entry per column.
    %    sequence of groups defined by in_groups variable in chartconfig
    %    display name of groups defined by in_stages "" "" "" 
    % if H has 3 rows-- well, we'll deal with that
    fprintf('\t');
    dat=[];stg=[];k=0;
    S(i).category(j).name=G.cats(j).name;
    S(i).category(j).units=G.cats(j).units;

    % select only columns in our H1 use
    S(i).name=use(i);
    sc_cols=find(strcmp(G.H(1,:),use(i))); % true indices
    % sc_cols gets attenuated
    
    switch (size(G.H,1))
      case 2
        % one entry per column-- take stage names from H
        % sequence 
        for k=1:length(in_groups)
            data_cols=[];
            group=in_groups{k};
            if iscell(group)
                for kk=1:length(group)
                    data_cols=[data_cols, ...
                               intersect(sc_cols,find(strcmp(G.H(2,:), ...
                                                             group{kk})))];
                end
            else
                data_cols=intersect(sc_cols,find(strcmp(G.H(2,:),group)));
            end
            dat{1}(k)=sum(dd(j,data_cols));
            stg{1}{k}=in_stages{k};
            sc_cols=setdiff(sc_cols,data_cols);
        end
      otherwise
        keyboard
    end
    
    %dat={[dat{:}]};
    %stg={[stg{:}]};
    optstr='standard column stacking';
  
    % assign
    S(i).category(j).data=dat;
    S(i).category(j).stages=stg;

  end
  fprintf('%s',optstr);
end
fprintf('\n\n')
