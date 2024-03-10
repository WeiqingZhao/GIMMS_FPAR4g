function lut = GetTrainingSamples(ndvi_img,fpar_img,lc_img,lat_box_pNum,lon_box_pNum,xdataRange,ydataRange,validPercent,classes,pct)

img_size = size(lc_img);
lon_pNum = img_size(2);
lat_pNum = img_size(1);
latPixelSize = single(180.0./single(lat_pNum));
lonPixelSize = single(360.0./single(lon_pNum));
half_lat_box_pNum = floor(lat_box_pNum./2.0);
half_lon_box_pNum = floor(lon_box_pNum./2.0);
latitude = 90-latPixelSize/2:-latPixelSize:-90+latPixelSize/2;
longitude = -180+lonPixelSize/2:lonPixelSize:180-lonPixelSize/2;

total_counter = 0;

lut = [];


for row = 1:lat_box_pNum:lat_pNum - lat_box_pNum
    
    for col = 1:lon_box_pNum:lon_pNum - lon_box_pNum

        center_row = row + half_lat_box_pNum;
        center_col = col + half_lon_box_pNum;
        trueLat = latitude(center_row);
        trueLon = longitude(center_col);

        box = [row,row + lat_box_pNum - 1,col,col + lon_box_pNum - 1];        
        [tempLut] = Cal_maj_lut_in_box(ndvi_img,fpar_img,lc_img,box,trueLat,trueLon,xdataRange,ydataRange,validPercent,classes,pct);        
        if isempty(tempLut)
        else
            if total_counter == 0
                lut = tempLut;
                total_counter = 1;
            else
                lut = [lut;tempLut];
            end
        end
    end
end

if isempty(lut)
    error('Create_LUT_By_Box_ANN()--no lut!');
end

end