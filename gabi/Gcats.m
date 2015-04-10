function G=Gcats(G,cats)
% function G=Gcats(G,cats)
%
% Extracts impact category data from a quantity-view-based GaBi data structure.
% 'cats' is either a vector of row indices or a cell array of indices.  In the
% latter case, each entry in the cell array indicates rows that should be added
% together.  Throws an error if two rows to be added have different units.
%
% NOTE: the index value in cats should be given from the TOP OF THE DATA BLOCK, 
% and not the row number of the spreadsheet.  This is because the spreadsheet
% offset is useless elsewhere, whereas the data block is used throughout the code.
% If you are lazy and only want to read spreadsheet row numbers, you will have to 
% adjust them with a command like:
%
% cats_corrected = cats - firstrow + 1 % if cats is a double array
% cats_corrected = cellfun(@(x) x - firstrow + 1, cats) % if cats is a cell array
%
% where 'firstrow' is the row number of the first data row.
% 
% function S=Gcats(G,use,cats)
%
% use is a cell array of first-level column headings to include.  Default is to
% use all columns.

% switch length(varargin)
%   case 1
%     cats=varargin{1};
%     use=[];
%   case 2
%     use=varargin{1};
%     cats=varargin{2};
% %    sheet='GaBi Paste';
% %  case 3
% %    use=varargin{2};
% %    cats=varargin{3};
% %    sheet=varargin{1};
%   otherwise
%     error('Improper number of arguments')
% end

if nargin<2 | isempty(cats)
  cats=1:size(G.D,1);
end

if ~iscell(cats)
  cats=num2cell(cats);
end

% parse out the categories
fprintf('\nSelecting Categories:\n')
for j=1:length(cats)
  rows=cats{j};
  if rows>0
    u=unique(G.U(rows));
    t{j}=G.T{rows(1)};
    d=zeros(1,size(G.D,2));
    if length(rows)>1
      % check units
      if length(u)>1
        warning('Unit mismatch in rows to be summed!')
        for k=1:length(rows)
          fprintf('%s [%s]\n',G.T{rows(k)},G.U{rows(k)})
        end
        keyboard
      end
      % craft a suitable title for the agg row
      a=strvcat(G.T(rows));
      m=size(a,2);
      for k=2:size(a,1);
        m=min([m find(a(k-1,:)~=a(k,:))]);
      end
      for k=2:length(rows)
        t{j}=[t{j} '+' G.T{rows(k)}(m:end)];
      end
    end
    for k=1:length(rows)
      d=d+G.D(rows(k),:);
    end
    my_cats(j).name=t{j};
    my_cats(j).units=u{1};
    my_cats(j).data=d;
    fprintf('%s [%s]\n',t{j},u{1})
  end
end
G.cats=my_cats;
% get rid of this- it's been pulled.
G=rmfield(G,{'T','U','D'}); 
