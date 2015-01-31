function k=ebar(x,y,lo,hi,size,txtin)
% function k=ebar(x,y,lo,hi,size)
% plots a horizontal error bar at location (x,y) with dimensions lo, hi
% optional 'size' specifies length of error tics

dotext=false;

if nargin<5
    size=0.3;
end

if nargin==5
    if ischar(size)
        txtin=size;
        size=0.3;
        dotext=true;
    end
end


k=plot(x+[lo hi],[y y],'linewidth',1,'color',[0 0 0]);
vhash(x+lo,y,size)
vhash(x+hi,y,size);

plot(x,y,'.k','markersize',12)

if nargin==6 || dotext
    text(x+min([lo hi]),y,txtin,'horizontalalignment','right','vert','middle',...
         'FontSize',8);
end

function vhash(x,y,size)
try
plot(x*[1 1],y+size*[-1 1],'k-','linewidth',0.75);
catch
    keyboard
end