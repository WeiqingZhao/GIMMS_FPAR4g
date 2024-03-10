function [lut] = Cal_maj_lut_in_box(ndvi_img,fpar_img,lc_img,box,lat,lon,xdataRange,ydataRange,validPercent,classes,pct)
%       box :  box(1)  Up;
%              box(2)  Bottom;
%              box(3)  Left;
%              box(4)  Right;

lut = [];

% lc_type, mean_ndvi,mean_lai, std_ndvi, std_lai
box_ndvi = ndvi_img(box(1):box(2),box(3):box(4));
box_fpar = fpar_img(box(1):box(2),box(3):box(4));
box_lc = lc_img(box(1):box(2),box(3):box(4));

% Clear invalid data:
box_flag = ones(size(box_ndvi));
box_flag(box_ndvi > xdataRange(2) | box_ndvi < xdataRange(1)) = 0;
box_flag(box_fpar > ydataRange(2) | box_fpar < ydataRange(1)) = 0;

counter = 0;
for i = classes
    if counter == 0
        lcmask = (box_lc == i);
        counter = 1;
    else
        lcmask = lcmask | (box_lc == i);
    end
end
box_flag(~lcmask) = 0;
box_flag(isnan(box_ndvi)|isnan(box_fpar)) = 0;
box_lc(box_flag == 0) = NaN;

% eliminate outliers in box
xmean=nanmean(box_fpar(:));
xstd=nanstd(box_fpar(:));
box_fpar(box_fpar<xmean-2*xstd|box_fpar>xmean+2*xstd) = nan;
xmean=nanmean(box_ndvi(:));
xstd = nanmean(box_ndvi(:));
box_ndvi(box_ndvi<xmean-2*xstd|box_ndvi>xmean+2*xstd) = nan;
box_flag(isnan(box_ndvi)|isnan(box_fpar)) = 0;
box_lc(box_flag == 0) = NaN;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lut=[];
for i = 1:length(pct)
    
    p = pct(i);
    temp_lut = GetMajorValueinbox(box_ndvi, box_fpar, box_lc,lat,lon,validPercent, p);
    lut=[lut;temp_lut];
    clear p temp_lut
    
end



% Free memory
clear box_ndvi;
clear box_fpar;
clear box_lc;
clear box_flag;
clear lcmask;
clear tempBox_lc;
end