function signal = correct_fp_signal(bioSignal, refSignal, opts)
    arguments
        bioSignal (1,:) double
        refSignal (1,:) double
        opts.rangeInd (1,:) double = 1:length(bioSignal)
        opts.meanFilterOrder (1,1) double = 1000
        opts.invert (1,1) logical = false
    end

    rangeInd = opts.rangeInd;
    meanFilterOrder = opts.meanFilterOrder;
    invert = opts.invert;

    MeanFilter = ones(meanFilterOrder,1)/meanFilterOrder;  
    reg = polyfit(refSignal(rangeInd), bioSignal(rangeInd), 1);
    a = reg(1);
    b = reg(2);
    controlFit = a.*refSignal + b;
    controlFit =  filtfilt(MeanFilter,1,controlFit);
    normDat = (bioSignal - controlFit)./controlFit;
    deltaSignal = normDat * 100;
    if invert
        deltaSignal = deltaSignal*(-1);
    end
    % smoothing traces
    signal = filtfilt(MeanFilter,1,deltaSignal);
end