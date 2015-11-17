function f=sensfig(wfstruct,cats,cases)
% function f=sensfig(wfstructs,cats,cases)
% wfstructs is a cell array of 2- or 3-element wfstructs, containing base and 
% sensitivity (optionally sensitivity low and high or somesuch).  Each item
% results in a bar on a sensitivity subplot.  'cats' is a vector of indices into
% the wfstruct categories.  cases is a cell array of sensitivity case descriptors.
%

% function f=sensfig(dat)
% creates a figure + axes for sensitivity results for a given data set.
%
% function f=sensfig(dat,numbars)
% creates a figure+axes for sensitivity results for a given data set with a given
% number of bars.

global chartconfig

numbars=length(wfstruct);

if nargin<3
    cases=strcat('Case ',cellfun(@(x){[' ' num2str(x)]},num2cell(1:numbars)));
end
if nargin<2
    cats=1:length(wfstruct{1}(1).category);
end

numcats=length(cats);

entry_height=0.18;% inches

marker={'kx','kx'};
f=figure;
sfh=ceil(numcats/2);
fig_height=sfh*(entry_height*( numbars)+0.95);
set(f,'PaperPositionMode','auto','units','inches',...
      'Position', [5 1 chartconfig.figwidth*2 fig_height]);
for c=1:numcats
    dat=[];
    subplot(sfh,2,c);
    headers=[];
    
    for i=1:numbars
        [dat(i,:),header_flag]=gen_dat_from_wf(wfstruct{i},cats(c));
        if header_flag==true
            headers=[headers i];
        end
    end
    mx=max(max(dat));
    mx=max([0 mx]);
    mn=min(min(dat));
    mn=min([mn 0]);
    axis([mn+(mx-mn)*[-0.1 1.1],0,numbars+0.9]);

    % disable x axis exponent
    %set(gca,'xticklabelmode','manual')
    
    set(f,'userdata',mn+(mx-mn)*0.1);
    hold on

    gdat=[min(dat,[],2) max(dat,[],2)-min(dat,[],2)];

    g1=barh(gdat,chartconfig.barwidth,'stacked','EdgeColor','none','facecolor',chartconfig.colors(cats(c),:));
    set(g1(1),'visible','off')
    set(g1,'showbaseline','off')

    nonheaders=logical(zeros(1,numbars));
    [nonheaders(setdiff(1:numbars,headers))]=deal(true);
    
    vbars([min(dat,[],2) max(dat,[],2)],nonheaders,chartconfig.barwidth);
    % draw points again for visibility
    for i=1:numbars
        if dat(i,1)~=dat(i,2)
            plot(dat(i,1),i,marker{1})
        end
        if dat(i,3)~=dat(i,2)
            plot(dat(i,3),i,marker{2})
        end
    end
    
    set(gca,'YTick',[1:numbars],'FontSize',chartconfig.mainfontsize,'YDir','reverse',...
            'box','off','TickDir','out','TickLength',[0.01,0.01])
    if mod(c,2)==1
        set(gca,'YTickLabel',cases)
    else
        set(gca,'YTickLabel',{})
    end
    % base case markers
    for i=1:length(headers)
        datum=dat(headers(i),1);
        if (datum ~=0)
            % draw a header
            startpoint=headers(i)+1;
            if i==length(headers)
                endpoint=numbars;
            else
                endpoint=headers(i+1)-1;
            end

            set(hline(headers(i)),'color',[.5 .5 .5]);

            if startpoint ~= endpoint
                line(datum*[1 1],...
                     [startpoint-0.5*chartconfig.barwidth endpoint+0.5*chartconfig.barwidth],...
                     'color',0.5*[1 1 1],'linestyle','-')
            end
        end
    end
    
    if prod(get(gca,'xlim'))<0
        vline(0,'k');
    end

    %set(gca,'looseinset',get(gca,'tightinset'))
    
    smartxlabel(gca)
 
    title(wfstruct{1}(1).category(cats(c)).name , 'FontSize',chartconfig.titlefontsize)
    xlabel(  wfstruct{1}(1).category(cats(c)).units ,'FontSize',chartconfig.mainfontsize);
end


%-------------------------------
function vbars(dat,draw,width,colors)
if nargin<4
  colors=0.3*[1 1 1];
end
x=dat([draw draw]);
y=[find(draw) find(draw)];
y=y(:)'-0.5*width;

line([x;x],[y;y+width],'color',colors);

function [dat,header_flag]=gen_dat_from_wf(wfstruct,c)
header_flag=false;
if isempty(wfstruct)
    dat=[0,0,0];
    return
end

base=1;
sa=2;
sb=length(wfstruct);
if sb<3 sa=1; end

if sb==1 header_flag=true; end

dat = [sum(wfstruct(sa).category(c).data{:}),...
       sum(wfstruct(base).category(c).data{:}),...
       sum(wfstruct(sb).category(c).data{:})];