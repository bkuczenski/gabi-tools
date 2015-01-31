function G=Gopen(xls,varargin)
% function G=Gopen(xls)
% function G=Gopen(xls,sheet)
% Reads in a data table pasted from GaBi.  Default sheet name is 'GaBi Paste'


if nargin<2
  sheet='GaBi Paste';
else
  sheet=varargin{1};
end

fprintf('Opening %s, sheet %s...\n',xls,sheet)
[~,~,C]=xlsread(xls,sheet);
% crop trailing all-NaN rows and columns
C=ccrop(C);

% first header row
start(1)=findfirst(C(:,end)); 
% first data column
dstart(2)=findfirst(C(start(1),:)); 
% first data row after first header row
dstart(1)=findfirst(C(start(1):end,dstart(2)-1))+start(1)-1; 
% first header column
start(2)=findfirst(C(dstart(1),:)); 

% crop C and offset dstart
C=C(start(1):end,start(2):end);
dstart=dstart-start+[1 1];

% Pull data as all numeric
D=cell2mat(C(dstart(1):end,dstart(2):end));

% Header should be all strings- except NaNs should remain NaN
H=C(1:dstart(1)-1,dstart(2):end);
H=cellfun(@ifnum2str,H,'UniformOutput',false);
[H(strcmp(H,'NaN'))]=deal({NaN});

% 'titles' are degenerate row headings
T=C(dstart(1):end,1:dstart(2)-1);
if size(T,2)>1
  fprintf('%s\n','Multilevel row headings not implemented.. using last row only')
  %keyboard
  T=T(:,end);
  % ignore total rows.  total rows identified as: all rows for which the next row
  % is a higher (i.e. more detailed) rank 
end

% units extracted from titles in regexp .*[(\1)]$'
expr='^([^\[]+) \[([^\]]+)\].*$';
U=regexprep(T,expr,'$2'); % U takes only units
[U(strcmp(T,U))]=deal({''}); % kill null units

% titles
T=regexprep(T,expr,'$1'); % U takes only units

G.xls=xls;
G.sheet=sheet;

G.T=T;
G.U=U;
G.H=H;
G.D=D;


% Hierarchical data interpretation: 
% a heading's hierarchical rank is its column number (row headings) or row number
% (column headings).  Higher rank implies greater specificity.  
%
% every rank must be specified.  if an entry has a gap in specificity, it must
% inherit the last-encountered entry at that level
%
% no- it's different for rows and for columns.  For rows, unspecified entries are
% implied.  for columns, unspecified entries 
% no- it's different for leading and trailing NaNs!!
% everything must have a first-level specification, so those read down.  but each
% subsequent row / column is a total of subsequent non-total entries.  so total
% rows and columns must be identified; and then root data rows and columns

% so: identify the data starts (as above) and then the highest-ranked rows and
% columns are the data entries.  any NaN in that row is a total row.
% then is the difference between hierarchical and non-hierarchical categories:
% whether or not "unspecified" is allowed.  For column headings, unspecified is
% allowed, but for row headings everything must be specified.  what's the
% difference?
%
% the rows are measurements and the columns are classifications.  

% anyway, I want to ignore every total row- and simply fully populate the
% classification for every data point, and the point is- yeah- reading rownames I
% should auto-propagate headings so that the row headings have no NaNs.  How do I
% determine data rows, then?
% I have to read them sequentially in order to determine whether they are data or
% totals.  Only the last row before a deepening level is a total.


function n=findfirst(C)
C=C(:);
[C(cellfun(@isstr,C))]=deal({0});
n=min(find(~cellfun(@isnan,C)));
if isempty(n)
  keyboard
end
return

%function C=cisnan(C) % made into a util function
%% 
%C(~cellfun(@isnumeric,C))=deal({0});
%C=cellfun(@isnan,C);
