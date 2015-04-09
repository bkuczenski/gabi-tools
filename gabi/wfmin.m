function scenario=wfmin(scenario)

numscenarios=length(scenario);
numcats=length(scenario(1).category);

if isfield(scenario(1).category(1),'fdata')
  %% find mins and maxs for each category in each scenario group
  allscensf=zeros(numscenarios,...
                  length(scenario(1).category(1).fdata));
  allscensimp=zeros(numscenarios,...
                    length(scenario(1).category(1).impdata));
  allscensons=zeros(numscenarios,...
                    length(scenario(1).category(1).onsdata));
  
  for s=1:numscenarios
    for c=1:numcats
      allscensf(s,:,c)=[scenario(s).category(c).fdata];
      allscensimp(s,:,c)=[scenario(s).category(c).impdata];
      allscensons(s,:,c)=[scenario(s).category(c).onsdata];
    end
  end

  for c=1:numcats
    Sf=zeros(9,1);
    myall=allscensf(:,:,c);
    [Sf(1,1) Sf(2,1) Sf(3,1)]=maxmin(myall);
    if ~isempty(allscensimp)
      [Sf(4,1) Sf(5,1) Sf(6,1)]=maxmin(allscensimp(:,:,c));
      myall=[myall allscensimp(:,:,c)];
    end
    if ~isempty(allscensons)
      [Sf(7,1) Sf(8,1) Sf(9,1)]=maxmin(allscensons(:,:,c));
      myall=[myall allscensons(:,:,c)];
    end
    [smin,maxcons,maxatt]=maxmin(Sf);
    try
      maxy=max(max(abs(myall)));
    catch
      keyboard
    end
    maxf=max(abs(allscensf(:,:,c)));
    
    for s=1:numscenarios
      scenario(s).category(c).min=smin;
      scenario(s).category(c).maxcons=maxcons;
      scenario(s).category(c).maxatt=maxatt;
      scenario(s).category(c).maxy=maxy;
      scenario(s).category(c).maxf=maxf;
    end
  end


else
  %% find mins and maxs for each category in each scenario group
  
  allscens=[];
  for s=1:numscenarios
    for c=1:numcats
      d=scenario(s).category(c).data;
      for i=1:length(d)
        li=length(d{i});
        if li>0
          allscens(numscenarios*(i-1)+s,[1:li],c)=d{i};
          if i==length(d)
            allscensf(s,[1:li],c)=d{i};
          end
        end
      end
    end
  end

  
  for c=1:numcats
    [smin,maxcons,maxatt]=maxmin(allscens(:,:,c)); % goes along rows
    [~,mc,ma]=maxmin(allscensf(:,:,c)); % goes along rows

    for s=1:numscenarios
      scenario(s).category(c).min=smin;
      scenario(s).category(c).maxcons=maxcons;
      scenario(s).category(c).maxatt=maxatt;
      scenario(s).category(c).maxy=max([abs(maxcons),abs(maxatt),abs(smin)]);
      scenario(s).category(c).maxf=max([abs(mc),abs(ma),abs(smin)]);
    end
  end
end  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% I thought I got rid of this...
function [minval,maxconsval,maxattval] = maxmin(input)

sums=cumsum(input,2);

input(find(input<0))=deal(0);
attmax=sum(input,2)';

minval=min([min(sums),0]);
maxconsval=max([max(sums),0]);
try
  maxattval=max([attmax,0]);
catch
  keyboard
end

