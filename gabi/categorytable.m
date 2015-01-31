function CT=categorytable(S,cat,varargin)
% function CT=categorytable(S,category,varargin)
% 
% creates a cell array table of indicator category results from S.
% category must be an index into S.category.  
%
% function CT=categorytable(S) without arguments generates a table and writes it
% to the excel file specified in S(1).xls, sheet [S(1).sheet ' Table']
%
% function CT=categorytable(S,spreadsheet) with char argument generates a table
% and writes it to the excel file specified in the second argument, to a worksheet
% called 'Cat Table' 
%
% function CT=categorytable(S,spreadsheet,worksheet) with char argument generates
% a table and writes it to the excel file specified in the second argument, to the
% worksheet specified in the third argument.

%

if nargin<3
  sht='Cat Table';
  if nargin<2
    cat=S(1).xls;
    sht=[S(1).sheet ' Table'];
  end
else
  sht=varargin{1};
end

CT=[];
base=repmat({NaN},1,1+length(S));
if ischar(cat)
  % recursive case
  for i=1:length(S(1).category)
    CT=[CT; base; categorytable(S,i)];
  end
else
  % base case
  % number of columns = length + 1
  row=base;
  row{1}=S(1).category(cat).name;
  CT=[CT; row];

  row=[[ '[' S(1).category(cat).units ']'] S(:).name];
  CT=[CT; row];
  
  % first, determine and order all the data rows
  scens=[];
  for i=1:length(S)
    stg=S(i).category(cat).stages;
    for j=1:length(stg)
      stgn=stg{j};
      for k=1:length(stgn)
          scens=[scens; {sprintf('%02d-%02d-%s',j,k,stgn{k})}];
      end
    end
  end
  scens=sort(unique(scens));
  expr='([0-9]{2})-([0-9]{2})-(.*$)';
  grps=cellfun(@str2num,regexprep(scens,expr,'$1'));
  stgs=cellfun(@str2num,regexprep(scens,expr,'$2'));
  names=regexprep(scens,expr,'$3');

  tot=0;
  for i=1:max(grps)
    recs=find(grps==i);
    D=zeros(length(recs),length(S));
    for j=1:length(recs)
      row=base;
      row(1)=names(recs(j));
      for k=1:length(S)
        d=S(k).category(cat).data{i};
        if ~isempty(d)
          if length(d)>=stgs(recs(j)) 
            D(j,k)=d(stgs(recs(j)));
            row{k+1}=d(stgs(recs(j)));
          end
        end
      end
      CT=[CT; row];
    end
    subtot=sum(D,1);
    tot=tot+subtot;
    if max(grps)>1
      row=base;
      row{1}=[S(1).groups{i} ' Subtotal'];
      row(2:end)=num2cell(subtot);
      CT=[CT; row];
    end
  end
  row=base;
  row{1}='Net Total';
  row(2:end)=num2cell(tot);
  CT=[CT; row];

end
