function namesOut = sanitizeSignalNames(namesIn)
    % Ensure we have a cell array of char
    if isstring(namesIn)
        namesIn = cellstr(namesIn); 
    end

    namesOut = cell(size(namesIn));
    for i = 1:numel(namesIn)
        name = namesIn{i};
        % Replace any non-alphanumeric or underscore characters with '_'
        name = regexprep(name, '[^A-Za-z0-9_]', '_');
        % Collapse multiple consecutive underscores into one
        name = regexprep(name, '_+', '_');
        % Ensure the first character is not a digit
        if ~isempty(name) && isstrprop(name(1), 'digit')
            name = ['x' name];
        end
        % Trim leading/trailing underscores
        name = regexprep(name, '^_+|_+$', '');
        namesOut{i} = name;
    end
end