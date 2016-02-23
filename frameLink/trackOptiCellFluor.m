function fl = trackOptiCellFluor( fluor, mask, r_offset )
% trackOptiCellFluor : Computes fluorescence statistics
%
% INPUT :
%       fluor: fluor image
%       mask : cell mask
%       r_offset : offset in global coordinates
% OUTPUT :
%       fl.r :
%       fl.Ixx :
%       fl.Iyy :
%       fl.Ixy :
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.


fl = [];
fl.sum = sum(double(fluor(mask(:))));
im_size   = size(mask);
im_size_x = im_size(2);
im_size_y = im_size(1);

xx = (1:im_size_x)+r_offset(1)-1;
yy = (1:im_size_y)+r_offset(2)-1;
[X,Y] = meshgrid( xx, yy );

Xcm = sum( X(mask(:)).*double(fluor(mask(:))))/fl.sum;
Ycm = sum( Y(mask(:)).*double(fluor(mask(:))))/fl.sum;

fl.r = [Xcm,Ycm];
fl.Ixx = sum(double(fluor(mask(:))).*(X(mask(:))-Xcm).^2)/fl.sum;
fl.Iyy = sum(double(fluor(mask(:))).*(Y(mask(:))-Ycm).^2)/fl.sum;
fl.Ixy = sum(double(fluor(mask(:))).*(Y(mask(:))-Ycm).*(X(mask(:))-Xcm))/fl.sum;

end
