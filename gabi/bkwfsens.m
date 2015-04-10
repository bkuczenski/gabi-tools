function bkwfsens(wfstruct,cat,mycolor,stages)
% multiple clusters is not supported

my_cat=wfstruct(1).category(cat);

if nargin<4
    stages=my_cat.stages;
end

errorbar_1=[wfstruct(2).category(cat).data{:}]-[my_cat.data{:}];
errorbar_2=[wfstruct(3).category(cat).data{:}]-[my_cat.data{:}];

% load configuration
chartconfig
if ~iscell(my_cat.data)
  error('must be cell!')
end

numstages=length(stages);
maxy=labelcutoff*my_cat.maxy;

buffer=0.01*(my_cat.maxcons-my_cat.min);
fmean=mean([my_cat.min,mean(my_cat.maxcons)]);

% set graphics options
% pureattrib - not sure what this is for
if pureattrib=='y'
  axis([my_cat.min,my_cat.maxatt,...
        0.5,numstages+1.9]);
else
    axis([my_cat.min,my_cat.maxcons,...
        0.5,numstages+1.9]);
end
hold on

% delete y axis (set by option)
if noyaxis=='y'
  xlims=get(gca,'xlim');
  vvvv=vline(xlims(1,1),'-');
  set(vvvv,'color',[1 1 1]);
  set(gca,'TickLength',[.005,.000]);
end
% plot the figure
offs=0;
offs=drawbars(my_cat.data{1}(1:numstages),mycolor,buffer,fmean,maxy,offs,errorbar_1,errorbar_2);

set(gca,'YTick',[1:numstages+1]);
set(gca,'YTickLabel',[stages 'Total Sens'],'FontSize',mainfontsize);
set(gca,'YDir','reverse','box','off','TickDir','out','TickLength',[.005,.005]);

%         attributional total vline
if drawattribtotal=='y'
  if pureattrib=='n'
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


%---------------------------------------
function offs=drawbars(fdata,mycolor,buffer,fmean,maxy,offs,e1,e2)
chartconfig

if nargin<6
  offs=0;
end
fc=length(fdata);
if fc==0
  return
end
x=offs+repmat(1:fc,2,1)';
fspaces(1,2:fc)=cumsum(fdata(1,1:end-1));
datagroupf=[fspaces;fdata]';
try
g1=barh(x,datagroupf,barwidth,'stacked','EdgeColor','none');
catch
  keyboard
  end
set(g1(1),'visible','off');
set(g1(2),'FaceColor',mycolor);
drawconsline(fdata,fspaces,offs);
% plot the errorbars
drawerrorbars(fdata,e1,e2)
drawbardatalabels(fdata,fspaces,fmean,buffer,maxy,offs,e1,e2);

baseline_handle = get(g1(2),'BaseLine');
set(baseline_handle,'Color',[0.5 0.5 0.5],'XData',[0 0],'YData',get(gca,'ylim'));
offs=offs+fc;
hold on



%---------------------------------------
function drawerrorbars(fdata,error_1,error_2)
fc=length(fdata);
if fc==0
    return
end
for i=1:length(fdata)
    if (error_1(i)~=0 || error_2(i)~=0)
        ebar(sum(fdata(1:i)),i,error_1(i),error_2(i));
    end
end

errs=sum(fdata)+[sum(error_1) sum(error_2)];
theerror=sprintf('%10.3g - %-10.3g',min(errs),max(errs));

ebar(sum(fdata),length(fdata)+1,sum(error_1),sum(error_2),theerror);
    




%---------------------------------------
function drawbardatalabels(fdata,fspaces,fmean,buffer,maxy,offs,e1,e2)
chartconfig

if nargin<6
  offs=0;
end
fc=length(fdata);
for i=1:fc
  errb=false;
  if (e1(i)==0 && e2(i)==0)
      thetext=num2str(fdata(1,i),'%10.3G');
  else
      es=fdata(1,i)+[e1(i) e2(i)];
      thetext=[num2str(min(es),'%10.3G') '-' num2str(max(es),'%10.3G')];
      errb=true;
  end
  if abs(fdata(1,i))>maxy && errb==false
    text((fspaces(1,i-0)+fdata(1,i)/2),i+offs,...
         thetext,'backgroundcolor',[1 1 1],...
         'horiz','center','vert','middle','FontSize',mainfontsize)
  else 
    if (fdata(1,i)+fspaces(1,i))<fmean
      if fdata(1,i)>0
        text((fspaces(1,i)+fdata(1,i)+buffer),i+offs,...
             thetext,'backgroundcolor',[1 1 1],...
             'horizontalalignment','left','vert','middle',...
             'FontSize',mainfontsize)
      else
        text(fspaces(1,i)+buffer,i+offs,...
             thetext,'backgroundcolor',[1 1 1],...
             'horizontalalignment','left','vert','middle',...
             'FontSize',mainfontsize)
      end
    else
      if fdata(1,i)<0
        text((fspaces(1,i)+fdata(1,i)-buffer),i+offs,...
             thetext,...
             'horizontalalignment','right','vert','middle',...
            'FontSize',mainfontsize)
      else
        text(fspaces(1,i)-buffer,i+offs,...
             thetext,...
             'horizontalalignment','right','vert','middle',...
             'FontSize',mainfontsize)
      end
    end
  end
end
  
%---------------------------------------
function drawconsline(fdata,fspaces,offs)
chartconfig

k=barwidth/2;
fc=length(fdata);
if nargin<3
  offs=0;
end
if drawconstotal=='y'; 
  for i=2:fc+1;
    if i==fc+1
      line('XData', (fspaces(1,i-1)+fdata(1,i-1))*[1 1],...
           'YData', offs+[i-1-k i], ...
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

