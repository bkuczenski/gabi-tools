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
chartconfig

numscenarios=length(wfstruct);
numcats=length(cats);

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

min_size=0.96;
        
numstages=length(wfstruct(1).groups);
ax_height=min_size + 0.145*numstages;

for c=1:numcats

    if ~isempty(subfig)
        f(c)=figure;
        
        set(f(c),'PaperPositionMode','auto',...
                   'units','inches','Position', ...
                 [5, 3, figwidth*subfig(2), ax_height*subfig(1) ]);

    end
        
    for s=1:numscenarios
    
      % use BK encoding
      % assume each scenario-category encodes its own column groups and stage
      % names in cell arrays.  cell arrays required!
      %fprintf('you fool!\n')

      if norm([wfstruct(s).category(c).data{:}])~=0
      
          if isempty(subfig)
              f(c,s)=figure;
              set(f(c,s),'PaperPositionMode','auto',...
                         'units','inches','Position', ...
                         [5, 3, figwidth, ax_height ]);
          else
              subplot(subfig(1),subfig(2),s)
          end
          
          bkwf2(wfstruct(s).category(c),colors(c,:),wfstruct(1).groups)

          if isempty(subfig)
          
              % draw x-axis label?
              if drawxaxislabel=='y'
                  xlabel(my_cat.units,'FontSize',mainfontsize);
                  %else
                  %  xlabel(' ','FontSize',mainfontsize);
              end
              
              title({wfstruct(s).category(c).name,[wfstruct(s).name{1} title_append]},'FontSize',titlefontsize);
          else
              if s==1
                  title({wfstruct(s).category(c).name,[wfstruct(s).name{1} title_append]},'FontSize',titlefontsize);
              else
                  title([wfstruct(s).name{1} title_append],'FontSize', ...
                      titlefontsize);
              end
              if s==numscenarios
                  if drawxaxislabel=='y'
                      xlabel(wfstruct(s).category(c).units,'FontSize',mainfontsize);
                      %else
                      %  xlabel(' ','FontSize',mainfontsize);
                  end
              end
          end
      end
      
    end
end

