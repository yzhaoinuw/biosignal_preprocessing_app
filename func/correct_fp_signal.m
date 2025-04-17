function signal = correct_fp_signal(bioSignal, refSignal, rangeInd, meanFilterOrder)
    arguments
        bioSignal (1,:) double
        refSignal (1,:) double
        rangeInd (1,:) double = (1:length(bioSignal));
        meanFilterOrder (1,1) double = 1000
    end

    MeanFilter = ones(meanFilterOrder,1)/meanFilterOrder;  
    reg = polyfit(refSignal(rangeInd), bioSignal(rangeInd), 1);
    a = reg(1);
    b = reg(2);
    controlFit = a.*refSignal + b;
    controlFit =  filtfilt(MeanFilter,1,controlFit);
    normDat = (bioSignal - controlFit)./controlFit;
    deltaSignal = normDat * 100;
    % smoothing traces
    signal = filtfilt(MeanFilter,1,deltaSignal);
end