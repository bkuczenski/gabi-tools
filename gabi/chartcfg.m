
%% this needs to be in workflow var
%% for Patagonia
% in_groups={{'PA66','PET','Mfg'},'DC','Retail','Use','EOL'};
% in_stages={'Upstream Production','Distribution Ctr',...
%            'Retail','Consumer Use','End of Life'};

%% for Toray
% in_groups={'Raw Materials','Fiber','Fabric','Sewing','Transport'}
% in_stages=in_groups;

%% for Toray-by-material
%in_groups = {'PA66','PET','Mfg'};
%in_stages = {'PA66','PET','Manufacture'}

global chartconfig

chartconfig.figwidth=6;             % figure width in inches
%halfwidth=3.25;

chartconfig.titlefontsize=10;       
chartconfig.mainfontsize=8;
chartconfig.labelfontsize=6.5;

% colors
chartconfig.colors=[...
    175,228,235;
    201,245,143;
    232,194,230;
    242,221,134;
    197,217,205;
    219,175,175;
    178,232,188;
    183,185,247;
    255,0,0;]/255;


%% plot parameters
 

chartconfig.barwidth=0.65;          % bar width=1 leaves no gap between bars
chartconfig.labelcutoff=0.14;       % minimum percent of groupcategory maximum value to center bar label
chartconfig.drawattribtotal=false;  % set to true to draw dashed attributional total markers
chartconfig.pureattrib=false;       % set to 'y' to only count positive impacts in attributional total
chartconfig.drawconstotal=true;     % set to 'y' to draw fat consequential total markers
chartconfig.drawxaxislabel=true;    % make a units label for x axis?
chartconfig.noyaxis=false;          % remove y axis line?
chartconfig.barlabels=true;

chartconfig.print_to_file=false;    % added for print -depsc

chartconfig.draw_markers=false;
