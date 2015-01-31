function wf=workflow(wf,c)
% function wf=workflow(wf,c)
% special-purpose workflow implementation for plotting LCIA results, originally
% from the Used Oil CalRecycle project.  Takes two struct arguments:
%
% wf is a workflow structure containing all information required to produce the
% plots. 
% wf fields:
%
% do -- list of booleans directing desired behavior; see c
% opt -- control behavior; passthru to wfread.m
%        2- for DIM: multiple inventory tables per sheet
% use -- passthru to wfread.m
%
% groups, cases, markers -- special args to senscats.m
%
% IA_xls -- spreadsheet containing impact assessment GaBi paste
% IA_sheet -- worksheet(s) containing impact assessment results
% cats -- category list (input to Gcats)
% IA_DATA -- store impact assessment results (output of Gcats)
%
% Co_xls -- spreadsheet containing coproduct GaBi paste
% Co_sheet -- worksheet(s) containing coproduct results
% invcats -- category list for coproduct (input to Gcats)
% Co_DATA -- store inventory results (output of Gcats)
%
% xls -- output spreadsheet (default: use input spreadsheet)
% doc -- output word doc
%
% c fields-- basically just an enum index into wf.do, plus a set of color specs 
% c.MASTER=1;
% c.CAT_TABLES=2;
% c.INV_TABLES=3;
% c.WATERFALLS=4;
% c.SENS=5;
% c.OUTPUT=6;
% c.DIM_WATERFALL=true;
% c.FORCE_READ=true;
% c.CLOSE_ALL=false;
% c.colors = list of [r, g, b] colorspecs on 0-1 scale


if wf.do(c.MASTER)
  % First, read the data
  % need IA data?
  need_IA=wf.do(c.CAT_TABLES)|wf.do(c.WATERFALLS)|wf.do(c.SENS);
  need_Co=wf.do(c.INV_TABLES);
  if (need_IA)
    if c.FORCE_READ || ~isfield(wf,'IA_DATA') || isempty(wf.IA_DATA)
    for i=1:length(wf.IA_sheet)
      IM(i)=Gcats(Gopen(wf.IA_xls,wf.IA_sheet{i}),wf.cats);
      [IM(i).cats.color]=c.colors{:};
    end
    wf.IA_DATA=IM;
    else
    IM=wf.IA_DATA;
    end
  end
  if (need_Co)
    if (c.FORCE_READ  | isempty(wf.Co_DATA))
    for i=1:length(wf.Co_sheet)
      inv=Gopen(wf.Co_xls,wf.Co_sheet{i});
      try
      if iscell(wf.invcats{1}) % if cell array of cell arrays, assume indexed
        Co(i)=Gcats(inv,wf.invcats{i});
      else
        Co(i)=Gcats(inv,wf.invcats);
      end
      catch
        keyboard
      end
    end
    if exist('Co')
      wf.Co_DATA=Co;
    end
    else
    Co=wf.Co_DATA;
    end
  end
  
  %------------------------------
  % inventory: table, varies by case.  
  if wf.do(c.INV_TABLES)
    if wf.opt==2 % DIM
                 % do base case + comparisons
      CT=invtable(Co(1));
      for i=2:length(Co)
        CT=[CT; invtable(Co(i),Co(1))];
      end
      write_to='Inv Tables';
    else
      CT=invtable(Co);
      write_to='Inventory Table';
    end
    
    if wf.do(c.OUTPUT)
      if ~isempty(wf.xls)
        out=wf.xls;
      else
        out=Co(1).xls;
      end
      xlsout(Co(1).xls,CT,write_to);
    end
  end % if c.INV_TABLES
  
  %------------------------------
  % LCIA categories: tables (spit back to excel) and charts (spit to doc)
  if wf.opt==2 % DIM
    if wf.do(c.CAT_TABLES)|wf.do(c.WATERFALLS)
      for i=1:length(IM)
        IM_W{i}=wfread(IM(i),wf.use,wf.opt);
      end
    end
    fprintf('DIM LCIA tables\n')
    if wf.do(c.CAT_TABLES)
      % print all categories by scenario, magnitude comparisons to baseline
      CT=scenariolcia(IM_W{1});
      xlsout(wf.xls,CT,IM_W{1}(1).sheet);
      for i=2:length(IM_W)
        CT=scenariolcia(IM_W{i},IM_W{1});
        if wf.do(c.OUTPUT)
          xlsout(wf.xls,CT,IM_W{i}(1).sheet);
        end
      end
    end
    if wf.do(c.WATERFALLS)
      % originally all categories by scenario; 
      % the new alternative is all scenarios by category
      % in either case, it is helpful to mash these together into a single figure
      % per scenario*category.
      % IM_W is IM_W{LCIA Sheet}(use).category(cats).data{groups}
      % we want to reorg it into IM_W{1}(LCIA Sheet).category(cats).data{use}
      IM_W=collapse(IM_W);
      keyboard
      delete_flag=true;
      %for i=1:length(IM_W)
      IM_W(1).name={'BL'};
      f_b=dimbarchart(IM_W);
      wf.doc=regexprep(wf.doc,'waterfall','bar');
      if c.DIM_WATERFALL
        IM_W(1).name={'Baseline'};
        f_w=waterfallchart(IM_W(1));
        for i=1:length(f_w)
          set(findobj(f_w(i),'type','axes'),'xlim',...
                            get(findobj(f_b(i),'type','axes'),'xlim'));
        end
        f_b=[f_b(:)' ; f_w(:)'];
      end
      if wf.do(c.OUTPUT)
        wordout(wf.doc,f_b(:),delete_flag);
        close(f_b(:));
      end
      delete_flag=false;
      if c.CLOSE_ALL
        close(intersect(get(0,'children'),f_w(:)));
      end
    end % if c.WATERFALLS
      
  else % opt~=2
    % category table prints formal management stages by scenario for all cats
    % (section 5.1)
    if wf.do(c.CAT_TABLES)|wf.do(c.WATERFALLS)
      for i=1:length(IM)
        IM_W{i}=wfread(IM(i),wf.use,wf.opt);
      end
      fprintf('non-DIM LCIA tables\n')
      for i=1:length(IM_W)
        if wf.do(c.CAT_TABLES)
          CT=categorytable(IM_W{i});
          
          if wf.do(c.OUTPUT)
            if isfield(wf,'xls') && ~isempty(wf.xls)
              out=wf.xls;
            else
              out=IM_W{i}(1).xls;
            end
            xlsout(out,CT,[IM_W{i}(1).sheet ' Table']);
          end
        end
        if wf.do(c.WATERFALLS)
          if isfield(wf,'wf_suffix') && ~isempty(wf.wf_suffix)
              suffix=wf.wf_suffix;
          else
              suffix='';
          end
          f_w=waterfallchart(IM_W{i},suffix);
          if wf.do(c.OUTPUT)
            wordout(wf.doc,f_w(:),true);
          end
          if c.CLOSE_ALL
            close(intersect(get(0,'children'),f_w(:)));
          end
        end
      end % foreach IM_W
    end % if c.CAT_TABLES | c.WATERFALLS
  end % if opt == 2

  %------------------------------
  % Sensitivity analysis:
  if wf.do(c.SENS)
      if length(IM)==1 | wf.opt==3
      for i=1:length(IM)
        if wf.opt==3
          [IM(i).cats.color]=deal(c.colors{i});
        end
        IM_S=sensread(IM(i));
        keyboard
        if ischar(wf.cases{1})
          IM_S.cases=wf.cases;
        else
          IM_S.cases=wf.cases{i};
        end
        IM_S.markers=wf.markers{i};
        f_s(:,i)=senscats(IM_S);
      end
    else
      for i=1:length(IM)
        IM_S(i)=sensread(IM(i));
      end
      [IM_S.title]=wf.name{:}
      [IM_S.cases]=wf.cases{:}
      [IM_S.markers]=wf.markers{:}
      %keyboard
      for i=1:length(wf.cats)
        f_s(1:length(IM),i)=senscompare(IM_S,i);
      end
    end
    if wf.do(c.OUTPUT)
      wordout(wf.doc,f_s(:),false);
    end
    if c.CLOSE_ALL
      close(intersect(get(0,'children'),f_s(:)));
    end
  end % if c.SENS
end % if c.MASTER

%if exist(wf.doc,'file') & wf.opt~=3
%  movefile(wf.doc,'..')
%end
%if exist(wf.xls,'file')
%  movefile(wf.xls,'..')
%end



%------------------------------
function xlsout(x,d,s)
try
  xlswrite(x,d,s)
catch
  input(['Please close worksheet ' x ' for table output']);
  xlswrite(x,d,s)
end

function wordout(outputfile,figs,del_out)
input('Review plots and close word docs prior to output');
if nargin<3
  del_out=false;
end
if nargin<2
  figs=get(0,'Children');
end
if del_out
  delete(outputfile)
end
for j=1:length(figs)
  if ishandle(figs(j))
    save2word(outputfile,figs(j))
  end
end



function W=collapse(W)
% collapses all use cases into groups
% W is W{LCIA Sheet}(use).category(cats).data{groups}
% W cell array maps to uses
% groups get stacked
% groupnames come from use
for i=1:length(W)      % i is sheet
  for k=1:length(W{i}(1).category) % k is category
    W{i}(1).category(k).stages=use_append(W{i}(1).category(k).stages,...
                                          strcat(W{i}(1).name,': '));
    W{i}(1).groups{1}=W{i}(1).name{1};
    for j=2:length(W{i}) % j is case
      W{i}(j).category(k).stages=use_append(W{i}(j).category(k).stages,...
                                          strcat(W{i}(j).name,': '));
      W{i}(1).category(k).data=[W{i}(1).category(k).data;
                          W{i}(j).category(k).data];
      W{i}(1).category(k).stages=[W{i}(1).category(k).stages;
                          W{i}(j).category(k).stages];
      W{i}(1).groups{j}=W{i}(j).name{1};
    end
  end
  W{i}=W{i}(1);
  W{i}.groupnames=W{i}.groups;
  W{i}.name={W{i}.sheet};
end
W=[W{:}];
      

function c=use_append(c,pre)
for i=1:length(c)        
  c{i}=strcat(pre,c{i});
end

