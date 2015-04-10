function S=wfread(G,groups,use)
% function S=wfread(G) creates a scenario data structure from a GaBi category
% structure.  G should come from Gcats.
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
% By default, all first-level stages are reported, with sub-stages ignored.
%
% function S=wfread(G,stages) where stages is a cell array of stage names or
% subgroup names or cell arrays of stage names or subgroup names, will group
% together all records that match any elements of each subarray.  
%
% In order to avoid double counting, as soon as a record is matched, all records
% matching that record with ONE-LEVEL of LESSER specificity are removed (these
% represent total rows). Also all records with GREATER specificity are removed.
%
% At the end, nonzero values that have not been matched are grouped together in a
% catch all container.
%
% function S=wfread(G,stages,cases)
% specify which cases to use.  cases are unique first-row header entries. By
% default, all cases are used.
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

cases=unique(G.H(1,cellfun(@isstr,G.H(1,:))));

if nargin<3 | isempty(use)
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

stages=unique(G.H(2,cellfun(@isstr,G.H(2,:))));

% sort stages by the order they appear in H
for i=1:length(stages)
  firstind(i)=min(find(strcmp(G.H(2,cellfun(@isstr,G.H(2,:))),stages{i})));
end
[~,I]=sort(firstind);
stages=stages(I);

if nargin<2 | isempty(groups)
  groups=stages;
end



fprintf('Selecting cases:\n')
fprintf('%30s\n',use{:})

t=G.cats.name;

% long term plan: everything is contextual
% we make a list of level 2 groups to handle separately
%
% short term plan: we specify which level 2+3 groups to use in chartconfig
%
% chartconfig
% now we specify groups and stages on the command line
%G=Gopen(xls,sheet);
S.xls=G.xls;
S.sheet=G.sheet;

t={G.cats.name};
for j=1:length(G.cats)
  dd(j,:)=G.cats(j).data;
end

% now pull the data from columns as configured
%
for k=1:length(groups)
    if ~iscell(groups{k})
        groups{k}={groups{k}};
    end
end
verbose=false;

for i=1:length(use)
    % select only columns in our H1 use
    dat=[];stg=[];
    S(i).name=use(i);
    sc_cols=find(strcmp(G.H(1,:),use(i))); % true indices
    % sc_cols gets attenuated
    fprintf('\nScenario %s; ',use{i})
    
    for k=1:length(groups)
        mygroup=groups{k};
        S(i).groups{k}=[mygroup{:}];
        touse=[];
        fprintf('stage matching ')
        fprintf('%s ',mygroup{:})
        fprintf('\n')
        for kk=1:length(mygroup)
            st=[];
            [thisuse,remove]=match_cols(G.H(:,sc_cols),mygroup{kk});
            if verbose
                fprintf('Use: %d; ',sc_cols(thisuse))
                fprintf('Remove: %d; ',sc_cols(remove))
                fprintf('\n')
            end
            %keyboard
            touse=[touse sc_cols(thisuse)];
            for kkk=1:length(thisuse)
                my_st=supertotals(G.H(:,sc_cols),thisuse(kkk));
                if ~isempty(my_st)
                    if verbose
                        fprintf('Supertotals for %d: ',sc_cols(thisuse(kkk)))
                        fprintf('%d; ',sc_cols(my_st))
                        fprintf('\n')
                    end
                    st=unique([st my_st]);
                end
            end
            sc_cols([remove st])=[];
        end
        for j=1:length(G.cats)
            dat{j}(k)=sum(G.cats(j).data(touse));
            stg{j}{k}=touse;
        end
        sc_cols=setdiff(sc_cols,touse);
    end
    if ~isempty(sc_cols)
        fprintf('Omitted: ');
        fprintf('%d; ',sc_cols);
        fprintf('\n')
        %keyboard
    end
    for j=1:length(G.cats)
        S(i).category(j).name=G.cats(j).name;
        S(i).category(j).units=G.cats(j).units;
        if ~isempty(sc_cols)
            dat{j}(end+1)=sum(G.cats(j).data(sc_cols));
            stg{j}{end+1}=sc_cols;
            fprintf('%30.30s - Omitted Total: %g %s\n',...
                    G.cats(j).name,dat{j}(end),G.cats(j).units);
            %keyboard
        end
        S(i).category(j).data=dat(j);
        S(i).category(j).stages=stg(j);
    end
    if verbose
        fprintf('Check it:\n')
        keyboard
    end
end



function [use,remove]=match_cols(H,match)
% function [use,remove]=match_cols(H,match)
% returns a set of indices INTO sc_cols to use and remove, respectively. 
% H should be supplied as H(:,sc_cols)

deepest=size(H,1);

M=strcmp(H,match);
toplevel=min(find(sum(M,2)));

col_matches=find(M(toplevel,:));
if toplevel<deepest
    remove=intersect(col_matches,find(~cisnan(H(toplevel+1,:))));
    use=setdiff(col_matches,remove);
else
    use=col_matches;
    remove=[];
end

function totals=supertotals(H,col)
% for a given column, recursively identify records that include it in a total.
bottomlevel=max(find(~cisnan(H(:,col))));
if bottomlevel==1
    totals=[];
else
    shallower=find(cisnan(H(bottomlevel,:)));
    for i=bottomlevel-1:-1:1
        myparents=find(strcmp(H(i,:),H(i,col)));
        shallower=intersect(shallower,myparents);
    end
    if length(shallower)>1
        fprintf('This messy recursion is not working.\n')
        keyboard
    elseif length(shallower)==1
        totals=[shallower supertotals(H,shallower)];
    else
        totals=[];
    end
end


