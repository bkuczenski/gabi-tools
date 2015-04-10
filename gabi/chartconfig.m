
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

figwidth=6;             % figure width in inches
%halfwidth=3.25;

titlefontsize=10;       
mainfontsize=8;

% colors
colors=[...
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
 
barwidth=0.65;          % bar width=1 leaves no gap between bars
labelcutoff=0.14;       % minimum percent of groupcategory maximum value to center bar label
drawattribtotal='n';    % set to 'y' to draw dashed attributional total markers
pureattrib='n';         % set to 'y' to only count positive impacts in attributional total
drawconstotal='y';      % set to 'y' to draw fat consequential total markers
drawxaxislabel='y';     % make a units label for x axis?
noyaxis='n';            % remove y axis line?

