function S=stages_struct(G,cols)
% function S=stages(G)
% returns a struct array S containing the stages and substages corresponding to
% each 
% 
H=G.H;
[H(find(cisnan(H)))]=deal({''});

fnames={'Scenario','Stage'}
n=size(H,1)-2;
d=ceil(log10(n+1));

for i=1:size(H,1)-2
    fnames=[fnames sprintf('SubGroup%*d',d,i)];
end

if nargin>1
    for i=1:length(cols)
        % also add data columns
        % if 'D', read straight from D
        % if 'cats', index into cats
        if isfield(G,'D')
            if iscell(cols)
                dat=sum(G.D(cols{i},:),1);
                nam=[G.T(cols{i}(1)) repmat('+',1,length(cols{i})-1)];
            else
                dat=G.D(cols(i));
                nam=G.T(cols(i));
            end
        elseif isfield(G,'cats')
            dat=G.cats(cols(i)).data;
            nam=G.cats(cols(i)).name;
        else
            error('Don''t recognize G.');
        end
        nam=tr(nam,' .+,','');
        H=[H;num2cell(dat)];
        fnames=[fnames nam];
    end
end


S = cell2struct(H,fnames);
