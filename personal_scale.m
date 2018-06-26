%matlab归一化
function x = personal_scale(x, bound, col)
% bound:: [bmin bmax]
% x :: input matrix
 
if nargin < 3
    col = 0;
end
bmin = bound(1);
bmax = bound(2);
if col == 0
    for i = 1:size(x,1)
            xmin = min(x(i,:));
            xmax = max(x(i,:));     
            x(i,:) = bmin + (bmax-bmin) * ((x(i,:)-xmin) / (xmax-xmin));
    end
else
    for i = 1:size(x,2)
        xmin = min(x(:,i));
        xmax = max(x(:,i));     
        x(:,i) = bmin + (bmax-bmin) * ((x(:,i)-xmin) / (xmax-xmin));     
    end
end
 
end