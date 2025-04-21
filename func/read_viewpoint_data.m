function [viewpointData, info] = read_viewpoint_data(viewpointPath)
    info=loadEXP(viewpointPath, 'no');
    bin_filenames = {info.BinFiles.FileName};
    video_names = {info.VideosFiles.Files.FileName};
    video_dirs = {info.VideosFiles.Files.Dir};
    TimeReldebSec = 0; %start extract data from the beginning (first bin)
    % use inf as the end time instead of summing the duration of all bins
    % because duration includes gaps between nins and thus not accurate
    TimeRelEndSec = Inf; 
    [viewpointData, time] = ExtractContinuousData([],info,[],TimeReldebSec, TimeRelEndSec,[],1);
end