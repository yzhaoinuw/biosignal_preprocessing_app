function setup_version_control
%SETUP_VERSION_CONTROL Enable this repository's App Designer Git workflow.
%   Run once after cloning:
%       matlab -batch "setup_version_control"

    projectDir = fileparts(mfilename('fullpath'));
    previousDir = pwd;
    cleanup = onCleanup(@() cd(previousDir));
    cd(projectDir);

    export_app_source;

    [status, output] = system("git config --local core.hooksPath .githooks");
    if status ~= 0
        error("biosignal_preprocessing_app:GitHookSetupFailed", ...
            "Could not configure the repository Git hooks:\n%s", output);
    end

    fprintf("Configured core.hooksPath=.githooks\n");
    fprintf("App Designer export workflow is ready.\n");
end
