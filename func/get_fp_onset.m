function onsetFP = get_fp_onset(TDTData, ttlChannel, fpFrequency)
    if ~strcmp(ttlChannel, 'none')
        ttlFP = TDTData.epocs.(ttlChannel).onset;
        ttlGap = diff(ttlFP) > 6;
        if isempty(find(ttlGap == 1, 1))
            ttlOnset = ttlFP(1);  % when TTL pulse train is only started once
        else 
            ttlOnset = ttlFP(find(ttlGap==1)+1); % when TTL pulse train is started more than once
        end
        onsetFP = round(ttlOnset(1)*fpFrequency); 
    else
        onsetFP = 1;
    end
end