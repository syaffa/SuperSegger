function convertImageNames(dirname, basename, timeFilterBefore, ...
    timeFilterAfter, xyFilterBefore,xyFilterAfter, channelNames )
% convertImageNames : Convert image names from to NIS Elements format
% The file naming convention for elements is basename_t1xy1c1.tif
% where c1 is brightfield and c2,c3 etc are the fluorescent channels.
% To convert using this program you need to specify what is before and
% after the time in your image filename, before and after the xy position
% and the channelNames used in your filenames starting with phase.
% If you leave both the before and after values as '', then it sets the
% value to 1 (can be used for snapshots, or a single xy position).
% For example, Micromanager has the convention img_00000000t_channel.tif,
% if we used BF for phase images and gfp for the 1st channel we would call
% this function as following :
% convertImageNames(dirname, 'img', '_', 't', '','' , {'BF','gfp'} )
% which would rename img_00000001t_BF.tif to img_t1xy1c1.tif
%
% INPUT : dirname : directory contains micromanager images
%         timeFilterBefore : string found before frame number
%         timeFilterAfter : string found after frame number
%         xyFilterBefore : string found before xy position number
%         xyFilterAfter : string found after xy position number
%         channelFilters : cell with strings for each channel name found
%         in the filenames. For example {'BF','gfp', 'mcherry'} will convert *BF*
%         images to *c1*, gfp to c2 and mcherry to c3 .
%
% Copyright (C) 2016 Wiggins Lab
% Unviersity of Washington, 2016
% This file is part of SuperSeggerOpti.



images = dir([dirname,filesep,'*.tif']);

% directory to move original images
dirOriginal  = [dirname,filesep,'original',filesep] ;
imagesInOrig = dir([dirOriginal,filesep,'*.tif']);

elementsTime='t';
elementsXY ='xy';
elementsPhase = 'c';


if exist([dirname,filesep,'raw_im'],'dir') && ~isempty(dir([dirname,filesep,'raw_im',filesep,'*tif*']))
    disp('Files already aligned');
elseif numel(dir(['.',filesep,'*t*c*.tif']))
    disp('File names in NIS-Elements format')
    disp('Procede to segmentation')
elseif isempty(images) && isempty(imagesInOrig)
    error('No image files found, please check directory');
else
    disp('File names not in Elements format : Converting..')
    
    if ~exist(dirOriginal,'dir') % make original directory
        mkdir(dirOriginal) ;
    end
    
    if isempty(imagesInOrig) % move original images 
        movefile('*.tif',dirOriginal); % move all images to dir original
    end
    
    images = dir([dirOriginal,filesep,'*.tif']);
    
    % go through every image
    for j = 1: numel (images)
        fileName = images(j).name;
        %disp(fileName);
        
        currentTime = findNumbers (fileName, timeFilterBefore, timeFilterAfter); % find out time
        if isempty(currentTime)
            disp (['time expression incorrect for filename', fileName, '- aborting']);
            return;
        end
        
        currentXY = findNumbers (fileName, xyFilterBefore, xyFilterAfter); % find out xy
        if isempty(currentXY)
            disp (['time expression incorrect for filename', fileName, '- aborting']);
            return;
        end
        
        channelPos = [];
        c = 0;
        while isempty(channelPos)
            c = c +1;
            channelPos = strfind(fileName, channelNames {c}); % find out channel
        end
        
        if isempty(channelPos)
            disp (['channel expression incorrect for filename', fileName, '- aborting']);
            return;
        end
        
        newFileName = [basename,elementsTime,sprintf('%05d',currentTime),elementsXY,sprintf('%02d',currentXY),elementsPhase,num2str(c)];
        copyfile([dirOriginal,filesep,images(j).name],[ newFileName,'.tif']);
        
    end
end
end


function numbers = findNumbers (fileName, patternBefore, patternAfter)
% findNumbers : finds numbers in fileName between patternBefore and patternAfter

is_num_mask = ismember( fileName,'01234567890'); % 1 where there are numbers
timeStart = 0 ;
timeEnd = 0 ;

% return []  if not found at all
if isempty(regexp(fileName,[patternBefore,'[0123456789]+',patternAfter], 'once'))
    numbers=[];
    return;
end

% both empty set numbers to 1
if strcmp(patternBefore, '') && strcmp(patternAfter, '')
    numbers = 1;
    return
end

% find starting number
if ~strcmp(patternBefore, '')
    timeStart = regexp(fileName,[patternBefore,'[0123456789]']) + 1;
end

% find ending number
if ~strcmp(patternAfter, '')
    timeEnd = regexp(fileName,['[0123456789]',patternAfter]);
end


if isempty(timeStart) ||isempty(timeEnd)
    disp (['pattern was not found',patternBefore,patternAfter,fileName,'setting to 1']);
    numbers = 1;
else
    if timeStart == 0 && timeEnd ~=0
        timeStart = find( ~is_num_mask(1:timeEnd),1,'last')+1;
    end
    if timeStart ~= 0 && timeEnd ==0
        timeEnd = timeStart + find( ~is_num_mask(timeStart:end),1,'first')-2;
    end
    numbers = str2double(fileName(timeStart:timeEnd));
end

end


