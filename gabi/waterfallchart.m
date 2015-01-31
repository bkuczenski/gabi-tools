function f=waterfallchart(wfstruct,scenname)
% function f=waterfallchart(wfstruct,scenname)
%
% draws a stack of waterfall charts by use case, from a waterfall structure
% created from GaBi via wfread.

if nargin<2
  scenname='';
end
f=[];
chartconfig

numscenarios=length(wfstruct);
numcats=length(wfstruct(1).category);

if numscenarios>4
  figheight=1.7;
end
%numstages=length([fcols,impcols,onscols]);

if numcats>size(colors,1)
  fprintf('Not enough colors..\n')
  keyboard
end

% determine bounds for each category
wfstruct=wfmin(wfstruct);

%% making the graphs
%close all
for s=1:numscenarios
    for c=1:numcats
    
    if isfield(wfstruct(s).category(c),'fdata')
      % use TZ encoding
      informal=strncmp(wfstruct(s).name,'20',2);
      
      f(s,c)=figure;
      if informal
        set(f(s,c),'PaperPositionMode','auto',...
                  'units','inches','Position', [5 3 figwidth tallfigheight]);
      else
        set(f(s,c),'PaperPositionMode','auto',...
                  'units','inches','Position', [5 3 figwidth figheight]);
      end
      
      Q=bkwf(wfstruct(s).category(c),informal,colors(c,:));
      set(gca,'fontsize',mainfontsize')
      title(strcat(wfstruct(s).name,scenname),'FontSize',titlefontsize);
      if informal
        set(gca,'YTickLabel',wfstruct(s).stages,'FontSize',mainfontsize);
      else
        set(gca,'YTickLabel',wfstruct(s).stages(Q:end),...
                'FontSize',mainfontsize);
      end
    else
      % use BK encoding
      % assume each scenario-category encodes its own column groups and stage
      % names in cell arrays.  cell arrays required!
      %fprintf('you fool!\n')

      if norm([wfstruct(s).category(c).data{:}])~=0
      
          f(s)=figure;
          
          set(f(s),'PaperPositionMode','auto',...
                   'units','inches','Position', [5 3 figwidth 0.96]);

          bkwf2(wfstruct(s).category(c),colors(c,:))
          if isempty(scenname)
              title(strcat(wfstruct(s).name,[' - ' wfstruct(s).category(c).name]),'FontSize',titlefontsize);
          else
              title(strcat(wfstruct(s).name,[' - ' scenname]),'FontSize',titlefontsize);
          end
      end
      
    end
  end
end

