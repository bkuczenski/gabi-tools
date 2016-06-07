function f=waterfallchart(wfstruct,scenname,cats,subfig)
% function f=waterfallchart(wfstruct,scenname)
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
%
% if prod(subfig) == length(wfstruct) * length(cats), draws a "big grid" with
% categories by column, scenarios by row, omitting y axis labels for inner plots.

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

biggrid=false;

if ~isempty(subfig)
    if prod(subfig)==numscenarios*numcats
        biggrid=true;
    end
end


if numscenarios>4
  figheight=1.7;
end
%numstages=length([fcols,impcols,onscols]);

if max(cats)>size(chartconfig.colors,1)
  fprintf('Not enough colors..\n')
  keyboard
end

% determine bounds for each category
wfstruct=wfmin(wfstruct);

%% making the graphs
%close all

min_size=0.96;
        
numstages=length(wfstruct(1).groups);
ax_height=min_size + 0.145*numstages;
draw_ytick=true;

for c=1:numcats

    if ~isempty(subfig) && ( biggrid==false || c==1)
        f(c)=figure;
        
        set(f(c),'PaperPositionMode','auto',...
                   'units','inches','Position', ...
                 [5, 3, chartconfig.figwidth*subfig(2), ax_height*subfig(1) ]);

    end

    fprintf('\n%s\n', wfstruct(1).category(cats(c)).name)
    fprintf('%30.30s','')
    fprintf(' %19s', wfstruct(1).groups{:})
    fprintf('\n%s\n',repmat('=',1,30+20*length(wfstruct(1).groups)))
    
    for s=1:numscenarios
    
      % use BK encoding
      % assume each scenario-category encodes its own column groups and stage
      % names in cell arrays.  cell arrays required!
      %fprintf('you fool!\n')

      my_cat=wfstruct(s).category(cats(c));
      
      if norm([my_cat.data{:}])~=0
      
          if isempty(subfig)
              f(c,s)=figure;
              set(f(c,s),'PaperPositionMode','auto',...
                         'units','inches','Position', ...
                         [5, 3, chartconfig.figwidth, ax_height ]);
          else
              if biggrid
                  subplot(subfig(1),subfig(2), ...
                          numcats*(s-1)+c)
                  if c>1
                      draw_ytick=false;
                  end

              else
                  subplot(subfig(1),subfig(2),s)
              end
          end
          
          bkwf2(my_cat,chartconfig.colors(cats(c),:),wfstruct(1).groups,draw_ytick)

          fprintf('%30.30s',wfstruct(s).name{1})
          fprintf('        %12g', my_cat.data{1}(1:length(wfstruct(1).groups)))
          fprintf('\n')
          
          if isempty(subfig)
          
              % draw x-axis label?
              if chartconfig.drawxaxislabel
                  xlabel(my_cat.units,'FontSize',chartconfig.mainfontsize);
                  %else
                  %  xlabel(' ','FontSize',chartconfig.mainfontsize);
              end
              
              title({my_cat.name,[wfstruct(s).name{1} title_append]},'FontSize',...
                    chartconfig.titlefontsize);
          else
              if s==1
                  title({my_cat.name,[wfstruct(s).name{1} title_append]},'FontSize',...
                        chartconfig.titlefontsize);
              else
                  title([wfstruct(s).name{1} title_append],'FontSize', ...
                      chartconfig.titlefontsize);
              end
              if s==numscenarios
                  if chartconfig.drawxaxislabel
                      xlabel(my_cat.units,'FontSize',chartconfig.mainfontsize);
                      %else
                      %  xlabel(' ','FontSize',chartconfig.mainfontsize);
                  end
              end
          end
      end
      
    end
end

