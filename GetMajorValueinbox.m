function lut = GetMajorValueinbox(box_ndvi, box_fpar, box_lc,lat,lon,validPercent, p)

% for the first majority land cover type
% Get the majority land cover type
tempBox_lc = reshape(box_lc,[],1);
lc = mode(tempBox_lc);
index_mj_lc = find(box_lc == lc);
percent = numel(index_mj_lc)./(numel(box_lc));

counter = 0;

lut=[];
while percent > validPercent
    m_ndvi = prctile(box_ndvi(index_mj_lc),p);
    m_fpar = prctile(box_fpar(index_mj_lc),p);
    if counter == 0
        lut = [lc,m_ndvi,m_fpar,lat,lon];
        counter = 1;
    else
        tempLut = [lc,m_ndvi,m_fpar,lat,lon];
        lut = [lut;tempLut];
    end
    
    box_lc(index_mj_lc) = NaN;
    tempBox_lc = reshape(box_lc,[],1);
    lc = mode(tempBox_lc);
    index_mj_lc = find(box_lc == lc);
    percent = numel(index_mj_lc)./(numel(box_lc));
end