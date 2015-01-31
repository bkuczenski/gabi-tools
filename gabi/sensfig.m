function f=sensfig(wfstruct,cases)

% function f=sensfig(dat)
% creates a figure + axes for sensitivity results for a given data set.
%
% function f=sensfig(dat,numbars)
% creates a figure+axes for sensitivity results for a given data set with a given
% number of bars.

chartconfig

numbars=(length(cases));
numcats=length(wfstruct(1).category);

entry_height=0.18;% inches

marker={'kx','kx'};
f=figure;
sfh=ceil(length(wfstruct(1).category)/2);
fig_height=sfh*(entry_height*( numbars)+0.95);
set(f,'PaperPositionMode','auto','units','inches',...
      'Position', [5 1 6.5 fig_height]);
for c=1:numcats
    dat=[];
    subplot(sfh,2,c);
    
    for i=1:numbars
        dat(i,:)=[sum(wfstruct(2*i).category(c).data{:}),...
                  sum(wfstruct(1).category(c).data{:}),...
                  sum(wfstruct(2*i+1).category(c).data{:})];
    end
    mx=max(max(dat));
    mx=max([0 mx]);
    mn=min(min(dat));
    mn=min([mn 0]);
    axis([mn+(mx-mn)*[-0.1 1.1],0,numbars+0.9]);

    % disable x axis exponent
    set(gca,'xticklabelmode','manual')
    
    set(f,'userdata',mn+(mx-mn)*0.1);
    hold on

    gdat=[min(dat,[],2) max(dat,[],2)-min(dat,[],2)];
    g1=barh(gdat,barwidth,'stacked','EdgeColor','none','facecolor',colors(c,:));
    set(g1(1),'visible','off')
    set(g1,'showbaseline','off')
    vbars([min(dat,[],2) max(dat,[],2)],barwidth);
    % draw points again for visibility
    for i=1:numbars
        if dat(i,1)~=dat(i,2)
            plot(dat(i,1),i,marker{1})
        end
        if dat(i,3)~=dat(i,2)
            plot(dat(i,3),i,marker{2})
        end
    end
    
    set(gca,'YTick',[1:numbars],'FontSize',mainfontsize,'YDir','reverse',...
            'box','off','TickDir','out','TickLength',[0.01,0.01])
    set(gca,'YTickLabel',cases)
    
    smartxlabel(gca)
    f=g1(2:end);

    % base case marker
    line(dat(1,2)*[1 1],[1-0.5*barwidth numbars+0.5*barwidth],'color',0.5*[1 1 1],'linestyle','--')
    
    title({wfstruct(1).category(c).name} )
    xlabel( [' [' wfstruct(1).category(c).units ']'] ,'FontSize',get(gca,'fontsize'));
end


%-------------------------------
function vbars(dat,width,colors)
if nargin<3
  colors=0.3*[1 1 1];
end
x=dat(:)';
y=cumsum(ones(size(dat)),1);
y=y(:)'-0.5*width;
line([x;x],[y;y+width],'color',colors);
