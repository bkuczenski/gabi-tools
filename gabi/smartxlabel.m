function smartxlabel(ax)
% function smartxlabel
% function smartxlabel(ax)
% sets axes labels smartly.  todo: user-specified level of precision or other
% formatting information.  Works best on axes with xticklabelmode=auto set prior
% to plot.
%
% with no args, uses gca.

if nargin==0
  ax=gca;
end

% fix x axis exponent
xt=get(ax,'xtick');
exponent=3*floor(max(round(log10(abs(xt(find(xt))))/3)));
if exponent==0
  xtickl=cellfun(@num2str,num2cell(xt),'uniformoutput',false);
else
  suffix=num2str(exponent);
  xtl=xt/10^(exponent);
  
  %xtl=round(xt*10^(-min(floor(log10(abs(xt(find(xt))))))))
  for j=1:length(xt)
    if log10(xt(j))+3<exponent
      xtickl{j}='0';
    else
      if abs(xtl(j))<0.2
        xtickl{j}=sprintf('%.2fe%i',xtl(j),exponent);
      elseif abs(xtl(j))<2
        xtickl{j}=sprintf('%.1fe%i',xtl(j),exponent);
      else
        xtickl{j}=sprintf('%de%i',xtl(j),exponent);
      end
    end
  end
end
set(ax,'xticklabel',xtickl)
