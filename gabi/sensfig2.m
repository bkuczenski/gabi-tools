function f=sensfig2(wfstruct,cats,cases)
% function f=sensfig2(wfstructs,cats,cases)
%
% Draws a sensitivity figure.  
%
% wfstructs is a cell array of 2- or 3-element wfstruct arrays, containing base and 
% sensitivity (optionally sensitivity low and high or somesuch).  Each item
% results in a bar on a sensitivity subplot.  'cats' is a vector of indices into
% the wfstruct categories.  cases is a cell array of sensitivity case
% descriptors, to be used as y-axis labels.
%
% if an element of wfstructs is a singleton wfstruct, it is interpreted as a
% header row, which generates a space and a bold heading with the corresponding
% cases element.

global chartconfig

%% argument handling

numbars=length(wfstruct);

if nargin<3
    cases=strcat('Case ',cellfun(@(x){[' ' num2str(x)]},num2cell(1:numbars)));
end
if nargin<2
    cats=1:length(wfstruct{1}(1).category);
end

numcats=length(cats);

%% determine header rows, x range, and y indices

count=1;
y_pos=[];
headers=zeros(1,numbars);

for i=1:numbars
  if length(wfstruct{i})==1
    headers(i)=1;
    if count ~=1;  count=count+1; end
  end
  y_pos=[y_pos count];
  count=count+1;
end

%% chart setup

entry_height=0.18;% inches

marker={'kx','kx'};
f=figure;
sfh=ceil(numcats/2);
fig_height=sfh*(entry_height*( max(y_pos))+0.95);
set(f,'PaperPositionMode','auto','units','inches',...
      'Position', [5 1 chartconfig.figwidth*2 fig_height]);


%% draw plots
for c=1:numcats
  subplot(sfh,2,c);
  
  for i=1:numbars
    dat(i,:)=gen_dat_from_wf(wfstruct{i},cats(c));
  end
  mx=max(max(dat));
  mx=max([0 mx]);
  mn=min(min(dat));
  mn=min([mn 0]);
  x_lim=mn+(mx-mn)*[-0.1 1.1];
  y_lim=[0,max(y_pos)+0.9];
  axis([x_lim,y_lim]);
  hold on
  vline(0,'k-')
  
  %% now step through and draw the bars-- in reverse- so header decorations come
  %out on top
  
  endpos=0;
  for i=numbars:-1:1
    % how far to draw the datum line, when we get to it
    endpos=max([endpos,i]);
    if headers(i)==1 
      % header row
      datum = dat(i,1);
      text(x_lim(1),y_pos(i),[cases{i} '  '],'horizontalalign','right','verticalalign','cap',...
           'fontsize',chartconfig.mainfontsize,'fontweight','bold');
      startpos=i;
      if startpos ~= endpos
        line(datum*[1 1],...
             [y_pos(startpos)-0.5*chartconfig.barwidth y_pos(endpos)+0.5*chartconfig.barwidth],...
             'color',0.3*[1 1 1],'linestyle','-')
        plot(datum,y_pos(startpos),'ko')
        zz=text(datum,y_pos(startpos),[' -' wfstruct{i}.name{1}],...
             'horizontalalign','left','verticalalign','middle')
      end
     
      % reset for next datum line
      endpos=0;
    else
      % data row
      sensline([min(dat(i,:)) max(dat(i,:))],y_pos(i),chartconfig.barwidth,...
           chartconfig.colors(cats(c),:));
      % draw points for visibility
      if dat(i,1)~=dat(i,2)
        plot(dat(i,1),y_pos(i),marker{1})
      end
      if dat(i,3)~=dat(i,2)
        plot(dat(i,3),y_pos(i),marker{2})
      end
      text(x_lim(1),y_pos(i),[cases{i} '  '],'fontsize',chartconfig.mainfontsize,...
           'horizontalalign','right','verticalalign','cap');
    end
  end
  set(gca,'YTick',[],'FontSize',chartconfig.mainfontsize,'YDir','reverse',...
          'box','off','TickDir','out','TickLength',[0.005,0.01],'YTickLabel',{})

  
  title(wfstruct{1}(1).category(cats(c)).name , 'FontSize',chartconfig.titlefontsize)
  xlabel(  wfstruct{1}(1).category(cats(c)).units ,'FontSize',chartconfig.mainfontsize);

  %keyboard
end
    

for c=1:numcats
  subplot(sfh,2,c);
  smartxlabel(gca)
end


  



% function f=sensfig(dat)
% creates a figure + axes for sensitivity results for a given data set.
%
% function f=sensfig(dat,numbars)
% creates a figure+axes for sensitivity results for a given data set with a given
% number of bars.


%-------------------------------
function sensline(x,y,width,c)
y0=y-0.5*width;
y1=y0+width;
patch([x(1) x(1) x(2) x(2)],[y0 y1 y1 y0],c,'edgecolor','none')
line([x;x],[y0 y0; y1 y1],'color',0.3*[1 1 1]);

function [dat]=gen_dat_from_wf(wfstruct,c)
header_flag=false;
if isempty(wfstruct)
    dat=[0,0,0];
    return
end

base=1;
sa=2;
sb=length(wfstruct);
if sb<3 sa=1; end

dat = [sum(wfstruct(sa).category(c).data{:}),...
       sum(wfstruct(base).category(c).data{:}),...
       sum(wfstruct(sb).category(c).data{:})];
