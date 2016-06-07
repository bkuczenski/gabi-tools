function f = dimfig_line(Ws, cats, labels, cases)
% function f = dimfig_line(Ws, cats, labels, cases)
% re-implementation of dimfig to use a line chart instead of a bar chart to meet
% the editor's requirements about copying content.  Told Roland this would take me
% "about 15 minutes"... Tue 2016-06-07 13:07:09 -0700
% break for meeting ... Tue 2016-06-07 13:51:59 -0700

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

linestyles={'k-*', 'b--x'};

numscenarios = length(Ws);

if nargin<4
    cases = {}
end
if nargin<3
    labels=[Ws{1}.name];
end
if nargin<2
    cats=length(Ws{1}(1).categories);
end

numcats=length(cats);
numbars=length(labels);
xind=1:numbars;

%for i=1:numscenarios
%    bars=[bars 0 ones(1,length(Ws{i}))];
%end

f=figure;
sfh=ceil(numcats/2);
fig_height=chartconfig.figwidth*0.8;
set(f,'PaperPositionMode','auto','units','inches',...
      'Position', [5 1 chartconfig.figwidth*1.2 fig_height]);
for c=1:numcats
    subplot(sfh,2,c)
    for i=1:numscenarios
        dat{i} = [];
        entries = [Ws{i}.name];
        for j=1:length(labels)
            ind = find(strcmp(entries, labels{j}));
            if isempty(ind)
                dat{i}(j) = NaN
            else
                numgroups=length(Ws{i}(j).groups);
                dat{i}(j)=sum(Ws{i}(j).category(cats(c)).data{1}(1:numgroups));
            end
        end
    end
    
    mymax=max([0 dat{:}]);
    mymin=min([0 dat{:}]);
    bounds=mymin+(mymax-mymin)*[-0.1 1.1];

    
    axis([0.5 numbars+0.5 bounds(1) bounds(2) ])
    hold on

    set(gca,'fontsize',chartconfig.mainfontsize);
  
    ylabel(Ws{1}(1).category(cats(c)).units,'FontSize',chartconfig.mainfontsize);

    for i=1:numscenarios
        plot(xind, dat{i}, linestyles{i}, 'linewidth', 2, 'markersize', 6)
    end
    hline(0,'k-')
    
    %g1=barh(thebars,dat,chartconfig.barwidth,'EdgeColor','none',...
    %        'FaceColor',chartconfig.colors(cats(c),:));
    %baseline_handle=get(g1,'BaseLine');
    %set(baseline_handle,'Color',[0.5 0.5 0.5],'XData',[0 0],'YData',get(gca,'ylim'));

    %% barlabel
    %for i=1:length(dat)
    %    if abs(dat(i))>0.15*diff(bounds)
    %        text(dat(i)/2,thebars(i),num2str(dat(i),'%10.3G'),...
    %             'horiz','center','vert','middle','FontSize',get(gca,'FontSize'))
    %    else
    %        text(dat(i)*1.02,thebars(i),num2str(dat(i),'%10.3G'),...
    %             'horiz','left','vert','middle','FontSize',get(gca,'FontSize'))
    %    end
    %end

    %headers=setdiff(find(bars==0),1);
    %for i=1:length(headers)
    %    set(hline(headers(i)),'color',[.5 .5 .5]);
    %end
    
    set(gca,'FontSize',chartconfig.mainfontsize);
    %if mod(c,2)==1
    set(gca, 'xtick', xind, 'XTickLabel',[labels]);
    %else
    %    set(gca,'XTickLabel',{});
    %end
    set(gca,'box','off','TickDir','out','TickLength',[.005,.005]);

    title(Ws{1}(1).category(cats(c)).name,'FontSize',chartconfig.titlefontsize);

    smartylabel(gca);
    
end

if ~isempty(cases)
    legend(cases{:})
end