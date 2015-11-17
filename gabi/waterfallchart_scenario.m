function f=waterfallchart_scenario(wfstruct,scenname,cats,subfig)
% function f=waterfallchart_scenario(wfstruct,scenname)
%
% Variation of waterfallchart that creates subfigures across categories for one
% scenario instead of subfigures across scenarios for one category.
%
% draws a stack of waterfall charts by use case, from a waterfall structure
% created from GaBi via wfread.
%
% f=waterfallchart(wfstruct,scenname,cats)
% only generate data for the named categories.
%
% f=waterfallchart(wfstruct,scenname,cats,subfig)
% arrange all plots for a given category on subplots instead of separate figures. 
% subfig should be a 1x2 array containing the first two arguments to subplot().

if nargin<4
    subfig=[];
end

if nargin<3
    cats=1:length(wfstruct(1).category);
end

if nargin<2 
  scenname='';
end

if isempty(scenname)
  title_append='';
else
  title_append=[' - ' scenname];
end
    
f=[];
global chartconfig

numscenarios=length(wfstruct);
numcats=length(cats);

if numscenarios>4
  figheight=1.7;
end
%numstages=length([fcols,impcols,onscols]);

if numcats>size(chartconfig.colors,1)
  fprintf('Not enough colors..\n')
  keyboard
end

% determine bounds for each category
wfstruct=wfmin(wfstruct);

%% making the graphs
%close all

min_size=0.96;
        
numstages=length(wfstruct(1).groups);
ax_height=min_size + 0.185*numstages;

for s=1:numscenarios

    if ~isempty(subfig)
        f(s)=figure;
        
        set(f(s),'PaperPositionMode','auto',...
                   'units','inches','Position', ...
                 [5, 3, chartconfig.figwidth*subfig(2), ax_height*subfig(1) ]);

    end
        
    for c=1:numcats
    
      % use BK encoding
      % assume each scenario-category encodes its own column groups and stage
      % names in cell arrays.  cell arrays required!
      %fprintf('you fool!\n')

      if norm([wfstruct(s).category(c).data{:}])~=0
      
          if isempty(subfig)
              f(c,s)=figure;
              set(f(c,s),'PaperPositionMode','auto',...
                         'units','inches','Position', ...
                         [5, 3, chartconfig.figwidth, ax_height ]);
          else
              subplot(subfig(1),subfig(2),c)
          end
          
          bkwf2(wfstruct(s).category(c),chartconfig.colors(c,:),wfstruct(1).groups)

          % draw x-axis label?
          if chartconfig.drawxaxislabel
              xlabel(wfstruct(s).category(c).units,'FontSize',chartconfig.mainfontsize);
              %else
              %  xlabel(' ','FontSize',chartconfig.mainfontsize);
          end
          
          title({wfstruct(s).category(c).name},'FontSize',chartconfig.titlefontsize);
      end
      
    end
end

