function f=waterfallsens(wfstruct,varargin)
% function f=waterfallsens(wfstruct,scenname,categories)
% draw waterfall chart with errorbars for sensitivity scenario
% approach: wfstruct should be 3-element array; first is baseline; second and
% third are sensitivities.
%
% categories is a vector of indices into wfstruct().cats-- NOT an index into the
% spreadsheet!  Makes one plot for each category named. If categories is omitted,
% makes one plot for each category.

chartconfig

switch nargin
  case 1
    scenname='';
    cats=1:length(wfstruct(1).category);
  case 2
    if ischar(varargin{1})
        scenname=[' - ' varargin{1}];
        cats=1:length(wfstruct(1).category);
    else
        cats=varargin{1};
        scenname='';
    end
  case 3
    scenname=[' - ' varargin{1}];
    cats=varargin{2};
  otherwise
    error('Arrrg!uments')
end

wfstruct=wfmin(wfstruct);

fprintf('%30.30s: \t%10.10s\t%10.10s\t%10.10s\n',...
        ['Sensitivity ' scenname],...
        'Baseline','A','B')
fprintf('%s\n',repmat('-',1,70))

for c=1:length(cats)
    cat=cats(c);
    if wfstruct(1).category(cat).min~=wfstruct(1).category(cat).maxatt
        
        f(c)=figure;
            
        set(f(c),'PaperPositionMode','auto',...
                   'units','inches','Position', [5 3 figwidth 1.05]);
        bkwfsens(wfstruct,cat,colors(cat,:))

        fprintf('%30.30s: \t%10.3g\t%10.3g\t%10.3g\n',...
                wfstruct(1).category(cat).name,...
                sum([wfstruct(1).category(cat).data{:}]),...
                sum([wfstruct(2).category(cat).data{:}]- ...
                    [wfstruct(1).category(cat).data{:}]),...
                sum([wfstruct(3).category(cat).data{:}]- ...
                    [wfstruct(1).category(cat).data{:}]));

        
        titlestr=sprintf('%s%s - %s','Sensitivity',scenname,wfstruct(1).category(cats(c)).name);
        title(titlestr,'FontSize',titlefontsize);
    end
end

        