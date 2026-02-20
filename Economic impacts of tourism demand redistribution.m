%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% This code file is based on the projected changes in tourism revenue in 181 countries by 2030, and uses the MRIO model to measure the resulting changes in employment and GDP.
%% 1 Initialisation
 clear; clc; close all;

% Change with local directory !!
workdir = 'C:\Users\uqwzhou4\OneDrive - The University of Queensland\Desktop\2025_Tourism_paper2\2025_Tourism\';

gloriadir = [workdir 'RawData/GLORIA/'];
rawdatadir = [workdir 'RawData/']; 
concdir = [workdir 'Concordances/'];
processeddatadir = [workdir 'ProcessedData/'];
resultdir = [workdir 'ResultFiles/']; 


%% 2 Load classifications, concordances, and data
disp(['Loading and processing raw tourism data.']);

% 2.1 Load classifications
% 2.1.1 Load GLORIA country names and acronyms
load([concdir 'countryNames.mat']); load([concdir 'countryAcros.mat']); NCOUN = size(countryNames,1);
% 2.1.2 Load TSA country names and acronyms
load([concdir 'UNAcr.mat']); load([concdir 'UNCountry.mat']);
% 2.1.3 Load GLORIA sector names
load([concdir 'sectorNames.mat']);
% 2.1.4 Load 16 sector names (We aggregated the final result into 15
% categories, please see Supplementary Information for details)
FPsecLabels = {'Agriculture';'Mining';'Food';'Goods';'Utilities';'Recreational services';'Trade';'Other services';'Accommodation';'Private vehicles';'Fuel';'Road transport';'Rail transport';'Air transport';'Water transport';'Transport services'};
FPsecAbbrev = {'Ag';'Min';'Food';'Goods';'Utils';'RecServ';'Trade';'Sv';'Acc';'PV';'Fuel';'Road';'Rail';'Air';'Water';'TranSv'};
cmp         = [[0.0  0.1   0.0    0.9     1.0     0.0      0.8     0.7  1.0   1.0  0.7    0.5    0.4    0.3   0.0     0.7]', ... 
               [0.5  0.8   1.0    0.9     1.0     0.0      0.4     0.7  0.5   0.2  0.7    0.5    0.4    0.3   0.0     0.9]', ...    
               [0.0  0.1   0.0    0.9     0.0     0.0      0.1     0.7  0.5   0.2  1.0    1.0    1.0    1.0   1.0     1.0]'];

% 2.2 Load concordances
% 2.2.1 Load TSA to GLORIA concordances
load([concdir 'concGLORIA2TSAreg.mat']); load([concdir 'concGLORIA2TSAsec.mat']);
% 2.2.2 Load income class concordance
load([concdir 'concIncGL.mat']);
load([concdir 'concClim.mat']);
% 2.2.3 Load domestic concordance
concDom1 = diag(ones(NCOUN,1));
concDom = ones(16,1); conc = concDom; 
for cc=1:NCOUN-1; conc = blkdiag(conc,concDom); end; concDom = conc; clear conc;
concDomGL = ones(120,1); conc = concDomGL; 
for cc=1:NCOUN-1; conc = blkdiag(conc,concDomGL); end; concDomGL = conc; clear conc;
% 2.2.4 Load 16 sectors concordance
concSec = repmat(diag(ones(16,1)),[NCOUN 1]);

% 2.3 Load data
% 2.3.1 Load tourism final demand array
ytourbase = importdata([processeddatadir 'ytourbase.mat']) * 1e3; 
ytournew = importdata([processeddatadir 'ytournew.mat']) * 1e3;

% Remove countries without tourism data
load([processeddatadir 'nodata.mat']); 
% load([concdir 'Agg16.mat']); 
conc16 = xlsread([concdir 'ConcGLORIA16sec' '.xlsx'],'Sheet1','D4:S123')';
Agg16 = xlsread([concdir 'ConcGLORIA16sec' '.xlsx'],'Sheet1','D4:S123')';
Agg = Agg16; for cc=1:NCOUN-1; Agg = blkdiag(Agg,Agg16); end; Agg16 = Agg; clear Agg;
save([concdir 'Agg16.mat'],'Agg16');
load([concdir 'Agg1.mat']);
ytourbase(logical(Agg16' * Agg1' * nodata),:,:) = 0; ytourbase(:,nodata,:) = 0; % correct 120-sector array
ytournew(logical(Agg16' * Agg1' * nodata),:,:) = 0; ytournew(:,nodata,:) = 0; % correct 120-sector array

checkytourbase = squeeze(sum(sum(ytourbase,2),1)); % check total
checkytournew = squeeze(sum(sum(ytournew,2),1)); % check total

% 2.3.3 Load supporting data 
load([processeddatadir 'GLflow.mat']); % tourist flows
xout = importdata([rawdatadir '\GLORIA\059\' 'x_2028.mat']); % total output
load([processeddatadir 'hhDomFull.mat']); load([processeddatadir 'hhTotFull.mat']); % household consumption

%% 3 Carry-out calculations
% 3.1 Calculate direct and indirect effect
if exist([resultdir 'direct_emp.mat'],'file')
    load([resultdir 'direct_emp.mat']);
    load([resultdir 'direct_vad.mat']);
    load([resultdir 'full_emp.mat']);
    load([resultdir 'full_vad.mat']);
else
    load([processeddatadir '059\' 'L_2028' '.mat']);

    % Employment
    disp(['Calculating employment ' num2str(2028) '.']);
    load([processeddatadir 'qEmploy.mat']); % employment
    direct_emp(:,:,1) = qEmploy .* (eye(size(qEmploy,1)) * squeeze(ytourbase));   
    direct_emp(:,:,2) = qEmploy .* (eye(size(qEmploy,1)) * squeeze(ytournew));
    full_emp(:,:,1) = diag(qEmploy) * L * squeeze(ytourbase); 
    full_emp(:,:,2) = diag(qEmploy) * L * squeeze(ytournew); 
    
    % GDP
    disp(['Calculating gdp ' num2str(2028) '.']);
    load([processeddatadir 'qVadd.mat']); % gdp
    direct_vad(:,:,1) = qVadd .* (eye(size(qVadd,1)) * squeeze(ytourbase));
    direct_vad(:,:,2) = qVadd .* (eye(size(qVadd,1)) * squeeze(ytournew));
    full_vad(:,:,1) = diag(qVadd ) * L * squeeze(ytourbase); 
    full_vad(:,:,2) = diag(qVadd ) * L * squeeze(ytournew); 

    %clear L qVadd qEmploy
    save([resultdir 'direct_emp.mat'],'direct_emp');
    save([resultdir 'direct_vad.mat'],'direct_vad');
    save([resultdir 'full_emp.mat'],'full_emp');
    save([resultdir 'full_vad.mat'],'full_vad');
end
direct_vad(:,:,3) = direct_vad(:,:,2) - direct_vad(:,:,1);
direct_emp(:,:,3) = direct_emp(:,:,2) - direct_emp(:,:,1);
full_vad(:,:,3) = full_vad(:,:,2) - full_vad(:,:,1);
full_emp(:,:,3) = full_emp(:,:,2) - full_emp(:,:,1);
%}
% 3.2 Convert to 16 sectors
for k=1:3
    % Employment
    FP16_emp(:,:,k) = Agg16 * squeeze(full_emp(:,:,k)); 
    FP16direct_emp(:,:,k) = Agg16 * squeeze(direct_emp(:,:,k));
    
    % GDP
    FP16_vad(:,:,k) = Agg16 * squeeze(full_vad(:,:,k)); 
    FP16direct_vad(:,:,k) = Agg16 * squeeze(direct_vad(:,:,k));
end
% Expenditure
yt16(:,:,1) = Agg16 * squeeze(ytourbase);
yt16(:,:,2) = Agg16 * squeeze(ytournew);
yt16(:,:,3) = yt16(:,:,2) - yt16(:,:,1);

% Exclude countries with no data
FP16_emp(logical(Agg1' * nodata),:,:) = 0; FP16_emp(:,nodata,:) = 0; % correct 16-sector array
FP16_vad(logical(Agg1' * nodata),:,:) = 0; FP16_vad(:,nodata,:) = 0; % correct 16-sector array

FP16direct_emp(logical(Agg1' * nodata),:,:) = 0; FP16direct_emp(:,nodata,:) = 0; % correct 16-sector array
FP16direct_vad(logical(Agg1' * nodata),:,:) = 0; FP16direct_vad(:,nodata,:) = 0; % correct 16-sector array

% Get indirect effect
FP16indirect_emp = FP16_emp - FP16direct_emp;
FP16indirect_vad = FP16_vad - FP16direct_vad;

checkFPfull_emp = squeeze(sum(sum(FP16_emp,2),1)); % check total
checkFPfull_vad = squeeze(sum(sum(FP16_vad,2),1)); % check total
checkFPdirect_emp = squeeze(sum(sum(FP16direct_emp,2),1)); % check total
checkFPdirect_vad = squeeze(sum(sum(FP16direct_vad,2),1)); % check total

% 3.3 Aggregate to country level
for k=1:3
    FP1_emp(:,:,k) = Agg1 * squeeze(FP16_emp(:,:,k));
    FP1_vad(:,:,k) = Agg1 * squeeze(FP16_vad(:,:,k));
    FP1direct_emp(:,:,k) = Agg1 * squeeze(FP16direct_emp(:,:,k));
    FP1direct_vad(:,:,k) = Agg1 * squeeze(FP16direct_vad(:,:,k));
    FP1indirect_emp(:,:,k) = Agg1 * squeeze(FP16indirect_emp(:,:,k));
    FP1indirect_vad(:,:,k) = Agg1 * squeeze(FP16indirect_vad(:,:,k));
end

% Tourism expenditure
yt1(:,:,1) = Agg1 * squeeze(yt16(:,:,1));
yt1(:,:,2) = Agg1 * squeeze(yt16(:,:,2));
yt1(:,:,3) = yt1(:,:,2) - yt1(:,:,1);
  
yTSA_base = squeeze(sum(yt1(:,:,1))); yMRIO_base = squeeze(sum(yt1(:,:,1)));
yTSA_new = squeeze(sum(yt1(:,:,2))); yMRIO_new = squeeze(sum(yt1(:,:,2)));

%% 3.4 Summarise Values by country
% 3.4.1 Employment
    flowControl = []; flowLabel = {};

    tt1 = Agg1 * Agg16 * xout ./ 1e3; uu = {'xout'};
    flowControl = cat(2,flowControl,tt1); flowLabel = cat(2,flowLabel,uu);        

    tt2 = Agg1 * Agg16 * employ'; uu = {'employment'};
    flowControl = cat(2,flowControl,tt2); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(yt1(:,:,1)) .* eye(NCOUN),1)' ./ 1e6; uu = {'yDom_base'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);

    tt = sum(squeeze(yt1(:,:,2)) .* eye(NCOUN),1)' ./ 1e6; uu = {'yDom_new'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);

    tt = sum(squeeze(yt1(:,:,3)) .* eye(NCOUN),1)' ./ 1e6; uu = {'yDom_delta'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);

    tt = sum(squeeze(yt1(:,:,1)) .* (1-eye(NCOUN)),2) ./ 1e6; uu = {'yInt_base'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(yt1(:,:,2)) .* (1-eye(NCOUN)),2) ./ 1e6; uu = {'yInt_new'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 
    
    tt = sum(squeeze(yt1(:,:,3)) .* (1-eye(NCOUN)),2) ./ 1e6; uu = {'yInt_delta'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(yt1(:,:,1),2) ./ 1e6; uu = {'yDBA_base'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(yt1(:,:,2),2) ./ 1e6; uu = {'yDBA_new'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(yt1(:,:,3),2) ./ 1e6; uu = {'yDBA_delta'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);      

    tt = sum(squeeze(FP1direct_emp(:,:,1)),2); uu = {'base_direct_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1indirect_emp(:,:,1)),2); uu = {'base_indirect_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(squeeze(FP1_emp(:,:,1)),2); uu = {'base_total_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(squeeze(FP1direct_emp(:,:,2)),2); uu = {'new_direct_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1indirect_emp(:,:,2)),2); uu = {'new_indirect_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(squeeze(FP1_emp(:,:,2)),2); uu = {'new_total_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(squeeze(FP1direct_emp(:,:,3)),2); uu = {'delta_direct_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1indirect_emp(:,:,3)),2); uu = {'delta_indirect_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(squeeze(FP1_emp(:,:,3)),2); uu = {'delta_total_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(squeeze(FP1_emp(:,:,1)),2) ./ sum(yt1(:,:,1),2); uu = {'q_base_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1_emp(:,:,2)),2) ./ sum(yt1(:,:,2),2); uu = {'q_new_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = tt2 ./ tt1; uu = {'q_GLORIA_emp'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    dFprofile = ['Country' 'Acronym' flowLabel; countryNames countryAcros num2cell(flowControl)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'SummaryResults' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet','employment');


% 3.4.2 GDP
    flowControl = []; flowLabel = {};

    tt1 = Agg1 * Agg16 * xout ./ 1e3; uu = {'xout'};
    flowControl = cat(2,flowControl,tt1); flowLabel = cat(2,flowLabel,uu);        

    tt2 = Agg1 * Agg16 * vadd'; uu = {'gdp'};
    flowControl = cat(2,flowControl,tt2); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(yt1(:,:,1)) .* eye(NCOUN),1)' ./ 1e6; uu = {'yDom_base'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);

    tt = sum(squeeze(yt1(:,:,2)) .* eye(NCOUN),1)' ./ 1e6; uu = {'yDom_new'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);

    tt = sum(squeeze(yt1(:,:,3)) .* eye(NCOUN),1)' ./ 1e6; uu = {'yDom_delta'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);

    tt = sum(squeeze(yt1(:,:,1)) .* (1-eye(NCOUN)),2) ./ 1e6; uu = {'yInt_base'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(yt1(:,:,2)) .* (1-eye(NCOUN)),2) ./ 1e6; uu = {'yInt_new'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 
    
    tt = sum(squeeze(yt1(:,:,3)) .* (1-eye(NCOUN)),2) ./ 1e6; uu = {'yInt_delta'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(yt1(:,:,1),2) ./ 1e6; uu = {'yDBA_base'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(yt1(:,:,2),2) ./ 1e6; uu = {'yDBA_new'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(yt1(:,:,3),2) ./ 1e6; uu = {'yDBA_delta'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);      

    tt = sum(squeeze(FP1direct_vad(:,:,1)),2); uu = {'base_direct_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1indirect_vad(:,:,1)),2); uu = {'base_indirect_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(squeeze(FP1_vad(:,:,1)),2); uu = {'base_total_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(squeeze(FP1direct_vad(:,:,2)),2); uu = {'new_direct_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1indirect_vad(:,:,2)),2); uu = {'new_indirect_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(squeeze(FP1_vad(:,:,2)),2); uu = {'new_total_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   

    tt = sum(squeeze(FP1direct_vad(:,:,3)),2); uu = {'delta_direct_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1indirect_vad(:,:,3)),2); uu = {'delta_indirect_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = sum(squeeze(FP1_vad(:,:,3)),2); uu = {'delta_total_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);   


    tt = sum(squeeze(FP1_vad(:,:,1)),2) ./ sum(yt1(:,:,1),2); uu = {'q_base_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    tt = sum(squeeze(FP1_vad(:,:,2)),2) ./ sum(yt1(:,:,2),2); uu = {'q_new_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu); 

    tt = tt2 ./ tt1; uu = {'q_GLORIA_vad'};
    flowControl = cat(2,flowControl,tt); flowLabel = cat(2,flowLabel,uu);    

    dFprofile = ['Country' 'Acronym' flowLabel; countryNames countryAcros num2cell(flowControl)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'SummaryResults' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet','gdp');
%% 
% 3.6 Country-sector breakdown
% 3.6.1 Employment
    tt = squeeze(FP16direct_emp(:,:,3)); tres = []; uu = {'delta_direct_emp'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));

    tt = squeeze(FP16indirect_emp(:,:,3)); tres = []; uu = {'delta_indirect_emp'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));
 
    tt = squeeze(FP16_emp(:,:,3)); tres = []; uu = {'delta_total_emp'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));


% 3.6.2 GDP
       
    tt = squeeze(FP16direct_vad(:,:,3)); tres = []; uu = {'delta_direct_vad'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));

 
    tt = squeeze(FP16indirect_vad(:,:,3)); tres = []; uu = {'delta_indirect_vad'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));
 
    tt = squeeze(FP16_vad(:,:,3)); tres = []; uu = {'delta_total_vad'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));
%% 
% percentage compared to baseline
tt = squeeze(FP16direct_emp(:,:,1)); tres = []; uu = {'base_direct_emp'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors_base' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));

    tt = squeeze(FP16indirect_emp(:,:,1)); tres = []; uu = {'base_indirect_emp'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors_base' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));
 
    tt = squeeze(FP16_emp(:,:,1)); tres = []; uu = {'base_total_emp'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors_base' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));


% 3.6.2 GDP
       
    tt = squeeze(FP16direct_vad(:,:,1)); tres = []; uu = {'base_direct_vad'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors_base' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));

 
    tt = squeeze(FP16indirect_vad(:,:,1)); tres = []; uu = {'base_indirect_vad'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors_base' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));
 
    tt = squeeze(FP16_vad(:,:,1)); tres = []; uu = {'base_total_vad'};
    for j=1:NCOUN
        tres(:,j) = sum(tt(((j-1)*16)+1:j*16,:),2);
    end

    dFprofile = ['sector' 'Acronym' countryNames'; FPsecLabels FPsecAbbrev num2cell(tres)];
    MfullTab = array2table(dFprofile);
    filename = [resultdir 'Summary Sectors_base' '.xlsx'];
    writetable(MfullTab,filename,'WriteVariableNames',false,'Sheet',char(uu));
