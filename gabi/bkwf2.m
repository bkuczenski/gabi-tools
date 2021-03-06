function bkwf2(my_cat,mycolor,stages,draw_ytick)

if nargin<4
    draw_ytick=true;
end
if nargin<3
    stages=my_cat.stages;
end

% load configuration
global chartconfig
if ~iscell(my_cat.data)
  error('must be cell!')
end

numclusters=length(my_cat.data);
numstages=length(stages);
maxy=chartconfig.labelcutoff*my_cat.maxy;

buffer=0.01*(my_cat.maxcons-my_cat.min);
fmean=mean([my_cat.min,mean(my_cat.maxcons)]);

% set graphics options
% pureattrib - not sure what this is for
if chartconfig.pureattrib
  axis([my_cat.min,my_cat.maxatt,...
        0.5,numstages+0.9]);
else
    axis([my_cat.min,my_cat.maxcons,...
        0.5,numstages+0.9]);
end
hold on

% delete y axis (set by option)
if chartconfig.noyaxis
  xlims=get(gca,'xlim');
  vvvv=vline(xlims(1,1),'-');
  set(vvvv,'color',[1 1 1]);
  set(gca,'TickLength',[.005,.000]);
end
% plot the figure
offs=0;
for k=1:numclusters
  offs=drawbars(my_cat.data{k}(1:numstages),mycolor,buffer,fmean,maxy,offs);
  if k~=numclusters & offs>0
    %  hhhh=hline(offs+0.5);
    %  set(hhhh,'color',[.5 .5 .5]);
    set(hline(offs+0.5),'color',[.5 .5 .5]);
  end
end

set(gca,'YTick',[1:numstages],'FontSize',chartconfig.mainfontsize);
if draw_ytick
    set(gca,'YTickLabel',stages);
else
    set(gca,'YTickLabel',{});
end
set(gca,'YDir','reverse','box','off','TickDir','out','TickLength',[.005,.005]);

%         attributional total vline
if chartconfig.drawattribtotal
  if ~chartconfig.pureattrib
    for j=1:length(fdata); % includes negative impacts from onsite
      attr(j,1)=sum(fdata(1:j));
      attrmax=max(attr);
    end
    vvv=vline(attrmax);
  else
    vvv=vline(sum([fdata(fdata>0),my_cat.specialcol1]));
  end
  set(vvv,'color',[44 139 202]/255);
end

% set x label to scientific notation
smartxlabel(gca)

%---------------------------------------
function offs=drawbars(fdata,mycolor,buffer,fmean,maxy,offs)
global chartconfig

if nargin<6
  offs=0;
end
fc=length(fdata);
if fc==0
  return
end
if fc==1
    fspaces=0;
    x=offs+1;
    g1=barh(x,fdata,chartconfig.barwidth,'EdgeColor','none');
    g1=[0 g1];
else
    fspaces(1,2:fc)=cumsum(fdata(1,1:end-1));
    datagroupf=[fspaces;fdata]';
    x=offs+repmat(1:fc,2,1)';
    try
        g1=barh(x,datagroupf,chartconfig.barwidth,'stacked','EdgeColor','none');
    catch
        keyboard
    end
    set(g1(1),'visible','off');
    drawconsline(fdata,fspaces,offs);
end    
set(g1(2),'FaceColor',mycolor);
if chartconfig.barlabels
    drawbardatalabels(fdata,fspaces,fmean,buffer,maxy,offs);
end

baseline_handle = get(g1(2),'BaseLine');
set(baseline_handle,'Color',[0.5 0.5 0.5],'XData',[0 0],'YData',get(gca,'ylim'));
offs=offs+fc;
hold on




%---------------------------------------
function drawbardatalabels(fdata,fspaces,fmean,buffer,maxy,offs)
global chartconfig

if nargin<6
  offs=0;
end
fc=length(fdata);
for i=1:fc
  if abs(fdata(1,i))>maxy
    text((fspaces(1,i-0)+fdata(1,i)/2),i+offs,...
         num2str(fdata(1,i),'%10.3G'),...
         'horiz','center','vert','middle','FontSize',chartconfig.labelfontsize)
  else 
    if (fdata(1,i)+fspaces(1,i))<fmean
      if fdata(1,i)>0
        text((fspaces(1,i)+fdata(1,i)+buffer),i+offs,...
             num2str(fdata(1,i),'%10.3G'),...
             'horizontalalignment','left','vert','middle',...
             'FontSize',chartconfig.labelfontsize)
      else
        text(fspaces(1,i)+buffer,i+offs,...
             num2str(fdata(1,i),'%10.3G'),...
             'horizontalalignment','left','vert','middle',...
             'FontSize',chartconfig.labelfontsize)
      end
    else
      if fdata(1,i)<0
        text((fspaces(1,i)+fdata(1,i)-buffer),i+offs,...
             num2str(fdata(1,i),'%10.3G'),...
             'horizontalalignment','right','vert','middle',...
            'FontSize',chartconfig.labelfontsize)
      else
        text(fspaces(1,i)-buffer,i+offs,...
             num2str(fdata(1,i),'%10.3G'),...
             'horizontalalignment','right','vert','middle',...
             'FontSize',chartconfig.labelfontsize)
      end
    end
  end
end
  
%---------------------------------------
function drawconsline(fdata,fspaces,offs)
global chartconfig

k=chartconfig.barwidth/2;
fc=length(fdata);
if nargin<3
  offs=0;
end
if chartconfig.drawconstotal
  for i=2:fc+1;
    if i==fc+1
      line('XData', (fspaces(1,i-1)+fdata(1,i-1))*[1 1],...
           'YData', offs+[i-1-k i-2*k], ...
           'LineStyle', '-', 'LineWidth', 2, 'Color',[1 0 1]);
    else
      line('XData', fspaces(1,i)*[1 1], 'YData', offs+[i-1-k i+.9*k], ...
           'LineStyle', '-', 'LineWidth', 1, 'Color',[.5 .5 .5]);
    end
  end
else
  for i=2:fc;
    line('XData', fspaces(1,i-1)*[1 1], 'YData', offs+[i-1-k i+.9*k], ...
           'LineStyle', '-', 'LineWidth', 1, 'Color',[.5 .5 .5]);e
  end
end

