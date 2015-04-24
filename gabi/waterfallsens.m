function f=waterfallsens(wfstruct,varargin)
% function f=waterfallsens(wfstruct,scenname,categories)
% draw waterfall chart with errorbars for sensitivity scenario
% approach: wfstruct should be 3-element array; first is baseline; second and
% third are sensitivities.
%
% categories is a vector of indices into wfstruct().cats-- NOT an index into the
% spreadsheet!  Makes one plot for each category named. If categories is omitted,
% makes one plot for each category.
%
% function f=waterfallsens(wfstruct,scenname,cats,subfig)
% Arrange all plots on subplots instead of separate figures.  subfig should be a
% 1x2 array containing the first two arguments to subplot().

global chartconfig

subfig=[];

switch nargin
  case 1
    scenname='';
    cats=1:length(wfstruct(1).category);
  case 2
    if ischar(varargin{1})
        scenname=varargin{1};
        cats=1:length(wfstruct(1).category);
    else
        cats=varargin{1};
        scenname='';
    end
  case 3
    scenname=varargin{1};
    cats=varargin{2};
  case 4
    scenname=varargin{1};
    cats=varargin{2};
    subfig=varargin{3};
  otherwise
    error('Arrrg!uments')
end

if isempty(scenname)
    scenname=wfstruct(1).name{1};
end

wfstruct=wfmin(wfstruct);

fprintf('%30.30s: \t%10.10s\t%10.10s\t%10.10s\n',...
        ['Sensitivity ' scenname],...
        'Baseline','A','B')
fprintf('%s\n',repmat('-',1,70))


min_size=1.05;
        
numstages=length(wfstruct(1).groups);
ax_height=min_size + 0.145*numstages;

if ~isempty(subfig)
    f=figure;
    set(f,'PaperPositionMode','auto',...
          'units','inches','Position', ...
          [5 3 chartconfig.figwidth*subfig(2) ax_height*subfig(1)]);
end
    

for c=1:length(cats)
    cat=cats(c);
    if wfstruct(1).category(cat).min~=wfstruct(1).category(cat).maxatt
        
        if isempty(subfig)
            f(c)=figure;
            
            set(f(c),'PaperPositionMode','auto',...
                     'units','inches','Position', [5 3 chartconfig.figwidth ax_height]);
        else
            subplot(subfig(1),subfig(2),c);
        end
        if isfield(wfstruct(1),'TotalSens')
        bkwfsens(wfstruct,cat,chartconfig.colors(cat,:),wfstruct(1).groups,wfstruct(1).TotalSens)
        else
        bkwfsens(wfstruct,cat,chartconfig.colors(cat,:),wfstruct(1).groups)
        end
        
        fprintf('%30.30s: \t%10.3g\t%10.3g\t%10.3g\n',...
                wfstruct(1).category(cat).name,...
                sum([wfstruct(1).category(cat).data{:}]),...
                sum([wfstruct(2).category(cat).data{:}]- ...
                    [wfstruct(1).category(cat).data{:}]),...
                sum([wfstruct(3).category(cat).data{:}]- ...
                    [wfstruct(1).category(cat).data{:}]));

        % titlestr=sprintf('%s%s - %s','Sensitivity',scenname,wfstruct(1).category(cats(c)).name);
        titlestr=wfstruct(1).category(cats(c)).name;
        title(titlestr,'FontSize',chartconfig.titlefontsize);
        % draw x-axis label?
        % if isempty(subfig)
            if chartconfig.drawxaxislabel
                xlabel(wfstruct(1).category(cats(c)).units,'FontSize',chartconfig.mainfontsize);
                %else
                %  xlabel(' ','FontSize',chartconfig.mainfontsize);
            end
        % else
        %     if c==1
        %         titlestr={[wfstruct(1).category(cats(c)).name ' - Sensitivity'],...
        %                   scenname};
        %     else
        %         titlestr=scenname;
        %     end
        %     title(titlestr,'FontSize',titlefontsize);
        %     if c==length(cats)
        %         % draw x-axis label?
        %         if chartconfig.drawxaxislabel=='y'
        %             xlabel(wfstruct(1).category(cats(c)).units,'FontSize',chartconfig.mainfontsize);
        %             %else
        %             %  xlabel(' ','FontSize',chartconfig.mainfontsize);
        %         end
        %     end
        end
    end
end

        