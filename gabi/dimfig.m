function f = dimfig(Ws, cats, cases)
% function f = dimfig(wfstruct, cats)
% since I'm sick of this, this is going to be a quick and dirty function without a
% lot of flexibility.  in fact, time trial: Fri 04-24 15:37:55 -0700
% wfstruct is a cell array of wfstruct arrays.  Each one just draws the total.
% cats is a vector of indices into wfstruct{k}(j).category
%
% skip a bar between each scenario object and draw an hline.
%
% ok, call it done at: Fri 04-24 16:04:08 -0700


global chartconfig

numscenarios = length(Ws);

if nargin<3
    cases=strcat('Case ',cellfun(@(x){[' ' num2str(x)]},num2cell(1:numscenarios)));
end
if nargin<2
    cats=length(Ws{1}(1).categories);
end

numcats=length(cats);
bars=[];
labels={};

for i=1:numscenarios
    bars=[bars 0 ones(1,length(Ws{i}))];
    labels=[labels cases{i} Ws{i}.name];
end
numbars=length(bars);
thebars=find(bars);

entry_height=0.18;% inches
f=figure;
sfh=ceil(numcats/2);
fig_height=sfh*(entry_height*( numbars)+0.95);
set(f,'PaperPositionMode','auto','units','inches',...
      'Position', [5 1 chartconfig.figwidth*1.4 fig_height]);
for c=1:numcats
    dat=[];
    subplot(sfh,2,c)
    for i=1:numscenarios
        for j=1:length(Ws{i})
            numgroups=length(Ws{i}(j).groups);
            dat=[dat sum(Ws{i}(j).category(cats(c)).data{1}(1:numgroups))];
        end
    end
    
    mymax=max([0 dat]);
    mymin=min([0 dat]);
    bounds=mymin+(mymax-mymin)*[-0.1 1.1];

    
    axis([bounds(1) bounds(2) 0.5 numbars+0.5])
    hold on

    set(gca,'fontsize',chartconfig.mainfontsize);
  
    xlabel(Ws{1}(1).category(cats(c)).units,'FontSize',chartconfig.mainfontsize);

    g1=barh(thebars,dat,chartconfig.barwidth,'EdgeColor','none',...
            'FaceColor',chartconfig.colors(cats(c),:));
    baseline_handle=get(g1,'BaseLine');
    set(baseline_handle,'Color',[0.5 0.5 0.5],'XData',[0 0],'YData',get(gca,'ylim'));

    % barlabel
    for i=1:length(dat)
        if abs(dat(i))>0.15*diff(bounds)
            text(dat(i)/2,thebars(i),num2str(dat(i),'%10.3G'),...
                 'horiz','center','vert','middle','FontSize',get(gca,'FontSize'))
        else
            text(dat(i)*1.02,thebars(i),num2str(dat(i),'%10.3G'),...
                 'horiz','left','vert','middle','FontSize',get(gca,'FontSize'))
        end
    end

    headers=setdiff(find(bars==0),1);
    for i=1:length(headers)
        set(hline(headers(i)),'color',[.5 .5 .5]);
    end
    
    set(gca,'YTick',1:numbars,'FontSize',chartconfig.mainfontsize);
    if mod(c,2)==1
        set(gca,'YTickLabel',[labels]);
    else
        set(gca,'YTickLabel',{});
    end
    set(gca,'YDir','reverse','box','off','TickDir','out','TickLength',[.005,.005]);

    title(Ws{1}(1).category(cats(c)).name,'FontSize',chartconfig.titlefontsize);

    smartxlabel(gca);
    
end
