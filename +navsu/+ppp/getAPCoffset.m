function offset = getAPCoffset(atxData, PRN, constInds, epochs)

%% getAPCoffset
%   
% Retrieve the antenna phase center (APC) offset for a given satellite.
% 
% Required Inputs:
%  atxData             - stucture containing data from IGS ATX file- can be
%                        produced by navsu.readfiles.readAtx.m
%  PRN                 - N-length vector of PRN
%  constInds           - N-length vector of constellation indices
%  epochs              - epochs at which to retrieve APC data. Can be
%                        scalar or N-length
% 
% Outputs:
%  offset              - 3 x N matrix of APC offset in satellite coordinate
%                        system

if numel(epochs) == 1
    epochs  = epochs * ones(size(PRN));
end
if numel(constInds) == 1
    constInds = constInds * ones(size(PRN));
end

% convert PRN to SV number
SVN = navsu.svprn.prn2svn(PRN, navsu.time.epochs2jd(epochs), constInds);

% get logical matrix of atx data matching the PRNs
% 
logMat = ([atxData.type] == constInds ...
        & [atxData.svn] == SVN ...
        & [atxData.epochStart] <= epochs ...
        & [atxData.epochEnd] >= epochs)';

% logMat = ([atxData.type] == constInds ...
%         & [atxData.prn] == PRN ...
%         & [atxData.epochStart] <= epochs ...
%         & [atxData.epochEnd] >= epochs)';

% get indices within atxData
nATX = length(atxData);
adx = mod(find(logMat), nATX);
% fix 0 behavior of mod function
adx(adx == 0) = nATX;

% get indices within satellites
sdx = find(any(logMat, 1));

% preallocate result vec
offset = NaN(3, length(PRN));

for ii = 1:length(adx) 
    if ~isempty(atxData(adx(ii)).apc)
        switch constInds(1)
            case '3'    % GAL
                offset(:, sdx(ii)) = (2.26*atxData(adx(ii)).apc(4,:) - 1.26*atxData(adx(ii)).apc(1,:)) * 1e-3;
            otherwise    % GPS, GLO, BDS, etc.
                try
                    if ismember(atxData(adx(ii)).prn, [4, 11, 14, 18, 23, 28])
%                         offset(:,sdx(ii)) = offset(:,sdx(ii)).*[-1; -1; 1] - [0;0;89.35].*1e-3;
%                         offset(:, sdx(ii)) = (atxData(adx(ii)).apc(1,:) + [0 0 500])* 1e-3;
                        offset(:, sdx(ii)) = atxData(adx(ii)).apc(1,:) * 1e-3;
                    else
                        offset(:, sdx(ii)) = atxData(adx(ii)).apc(1,:) * 1e-3;
                    end
                catch
                    print('setting a dummy breakpoint')
                end
        end
    end
end

end

