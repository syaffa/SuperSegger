function [data,touch_list] = makeTrainingData (data,FLAGS)
% makeTrainingData : user can click on segments or regions to change score
% from 0 to 1 or vice versa. It updates scores, cell mask, good and bad
% segs.
%
% INPUT : 
%       data : data file with segments to be modified
%       FLAGS : im_flag = 1 for segments, 2 for regions.
% INPUT : 
%       data : data file with modified segments
%       touch_list : list with modified segments/regions
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

if ~exist('FLAGS','var') ||  ~isfield(FLAGS,'im_flag')
    FLAGS.im_flag  = 1;
    FLAGS.S_flag  = 0;
    FLAGS.t_flag  = 0;
end

im_flag = FLAGS.im_flag ;
touch_list = []
ss = size(data.phase);
selectMode = true;

    
    while selectMode
        figure(2)
        imshow(data.phase);
        figure(1);
        showSegRule( data, FLAGS ,1)
       
        disp ('Click on segment/region to modify. To exit press enter while image is selected.');
        x = floor(ginput(1));
        disp(x);
        
        if ~isempty(x)
            % creates an image of 51 x 51 of gaussian like point
            tmp = zeros([51,51]);
            tmp(26,26) = 1;
            tmp = 8000-double(bwdist(tmp));
            
            rmin = max([1,x(2)-25]);
            rmax = min([ss(1),x(2)+25]);
            
            cmin = max([1,x(1)-25]);
            cmax = min([ss(2),x(1)+25]);
            
            rrind = rmin:rmax;
            ccind = cmin:cmax;
            
            pointSize = [numel(rrind),numel(ccind)];
            
            
            if im_flag == 1
                
                segs = data.segs.segs_good(rrind,ccind) + ...
                    data.segs.segs_bad(rrind,ccind);
                segs = segs>0;
                tmp = tmp(26-x(2)+rrind,26-x(1)+ccind).*segs ;
                
                [~,ind] = max( tmp(:) );
                
                % indices in point image for max / closest segment
                [sub1, sub2] = ind2sub( pointSize, ind );
                
                % closest segments id
                ii = data.segs.segs_label(rmin+sub1-1,cmin+sub2-1);
                
                if ii ~=0
                    
                    hold on;
                    plot( sub2-1+cmin, sub1-1+rmin, 'w.','MarkerSize', 30)
                    
                    % xx and yy are the segments coordinates
                    [xx,yy] = getBB( data.segs.props(ii).BoundingBox );
                    
                    if data.segs.score(ii) % score is 1
                        data.segs.score(ii) = 0; % set to 0
                        data.segs.segs_good(yy,xx) = 0;
                        data.segs.segs_bad(yy,xx) = 1;
                    else
                        data.segs.score(ii) = 1;
                        data.segs.segs_good(yy,xx) = 1;
                        data.segs.segs_bad(yy,xx) =  0;
                        
                    end
                    
                    % updates cell mask
                    data.mask_cell   = double((data.mask_bg - data.segs.segs_good - data.segs.segs_3n)>0);
                    touch_list = [touch_list, ii];
                end
            elseif im_flag == 2
                tmp = tmp(26-x(2)+rrind,26-x(1)+ccind).*data.mask_cell(rrind,ccind);
                try
                    [~,ind] = max( tmp(:) );
                catch ME
                    printError(ME);
                end
                
                [sub1, sub2] = ind2sub( pointSize, ind );
                ii = data.regs.regs_label(sub1-1+rmin,sub2-1+cmin);
                plot( sub2-1+cmin, sub1-1+rmin, 'g.' );
                
                if ii
                    data.regs.score(ii) = ~data.regs.score(ii);
                end
            end
        else
            selectMode = 0;
        end
    end
    
end