function [chanRefIdx, trialFRBoth_Grasp, trialFRBoth_Carry, trialFRGrasp, trialTargetBoth, trialTargetGrasp] = Behavioral_Comp(DataSqueeze,DataGT)

%Channel Indexing
restrictM1 = zeros(1,1280);
allM1 = [1:5:316 481:5:956 1121:5:1276];%[641:5:956 1121:5:1276];
restrictM1(allM1) = ones(1,192);%ones(1,96);

% Breakout important data from structure - Squeeze
MeasurementGrasp = double(DataSqueeze.SpikeCount(~DataSqueeze.nan_idx,logical(restrictM1)));
KinematicsGrasp = [DataSqueeze.Kinematics.Control(~DataSqueeze.nan_idx,1:6) DataSqueeze.Kinematics.ActualVel(~DataSqueeze.nan_idx)];
CommandedGrasp = DataSqueeze.Kinematics.CommForce(~DataSqueeze.nan_idx,1);
CommandedGrasp = [nan(5,size(CommandedGrasp,2));CommandedGrasp;nan(500,size(CommandedGrasp,2))];
StatesGrasp = DataSqueeze.TaskStateMasks.state_num(~DataSqueeze.nan_idx);
StatesGrasp = [nan(1,5) StatesGrasp nan(1,500)];
StimIdxGrasp = DataSqueeze.stim_idx(~DataSqueeze.nan_idx);
StimIdxGrasp = [nan(1,5) StimIdxGrasp nan(1,500)];


[filtMeasGrasp, filtKinGrasp] = PrepDataForTest(MeasurementGrasp,KinematicsGrasp);  %440 ms exponential filter
filtMeasGrasp = [nan(5,size(filtMeasGrasp,2));filtMeasGrasp;nan(500,size(filtMeasGrasp,2))];

% Breakout important data from structure - G&T

MeasurementBoth = double(DataGT.SpikeCount(~DataGT.nan_idx,logical(restrictM1)));
KinematicsBoth = [DataGT.Kinematics.Control(~DataGT.nan_idx,1:6) DataGT.Kinematics.ActualVel(~DataGT.nan_idx)];
CommandedBoth = DataGT.Kinematics.CommForce(~DataGT.nan_idx,1);
CommandedBoth = [nan(5,size(CommandedBoth,2));CommandedBoth;nan(500,size(CommandedBoth,2))];
StatesBoth = DataGT.TaskStateMasks.state_num(~DataGT.nan_idx);
StatesBoth = [nan(1,5) StatesBoth nan(1,500)];
StimIdxBoth = DataGT.stim_idx(~DataGT.nan_idx);
StimIdxBoth = [nan(1,5) StimIdxBoth nan(1,500)];

[filtMeasBoth, filtKinBoth] = PrepDataForTest(MeasurementBoth,KinematicsBoth);  %440 ms exponential filter
filtMeasBoth = [nan(5,size(filtMeasBoth,2));filtMeasBoth;nan(500,size(filtMeasBoth,2))];

% Z-Score Firing Rates

tempMean = nanmean([filtMeasGrasp;filtMeasBoth]);

goodChans = tempMean>0.1; %Only include channels with FR > value*50Hz

chanRefIdx = find(goodChans);
chanRefIdx(chanRefIdx>64) = chanRefIdx(chanRefIdx>64)+32; %Leave space for medial SC chans
chanRefIdx(chanRefIdx>192) = chanRefIdx(chanRefIdx>192)+32;%Leave space for lateral SC chans


meanFR = nanmean([filtMeasGrasp(:,goodChans);filtMeasBoth(:,goodChans)]);
stdFR = nanstd([filtMeasGrasp(:,goodChans);filtMeasBoth(:,goodChans)]);

zScoredFRGrasp = (filtMeasGrasp(:,goodChans)-repmat(meanFR,size(filtMeasGrasp,1),1))./repmat(stdFR,size(filtMeasGrasp,1),1);

zScoredFRBoth = (filtMeasBoth(:,goodChans)-repmat(meanFR,size(filtMeasBoth,1),1))./repmat(stdFR,size(filtMeasBoth,1),1);

% Organize data by trial - Squeeze

trialNumGrasp = DataSqueeze.trial_num(~DataSqueeze.nan_idx)-1; %Ignoring the first trial to reach back in time far enough
trialStatesGrasp = nan(max(trialNumGrasp),100);
trialTargetGrasp = zeros(max(trialNumGrasp),1);

trialStimGrasp = nan(max(trialNumGrasp),100);
trialZScoreGrasp = nan(max(trialNumGrasp),50,size(zScoredFRGrasp,2));
trialFRGrasp = nan(max(trialNumGrasp),50,size(zScoredFRGrasp,2));
trialFRGraspBase = nan(max(trialNumGrasp),50,size(zScoredFRGrasp,2));

for i = 1:max(trialNumGrasp)
    firstIdx = find(trialNumGrasp == i & StimIdxGrasp(6:end-500),1,'first')+5;
    trialTargetGrasp(i) = max(CommandedGrasp(firstIdx-50:firstIdx+49));
    trialStatesGrasp(i,:) = StatesGrasp(firstIdx-50:firstIdx+49);
    trialZScoreGrasp(i,:,:) = zScoredFRGrasp(firstIdx:firstIdx+49,:); %Z-Scored Firing Rates
    trialFRGrasp(i,:,:) = filtMeasGrasp(firstIdx:firstIdx+49,goodChans); %filtered firing rates
    trialFRGraspBase(i,:,:) = filtMeasGrasp(firstIdx-50:firstIdx-1,goodChans);
    trialStimGrasp(i,:) = StimIdxGrasp(firstIdx-50:firstIdx+49);

end


% Organize data by trial - Grasp & Transport

trialNumBoth = DataGT.trial_num(~DataGT.nan_idx);
trialStatesBoth_Grasp = nan(max(trialNumBoth),100);
trialStatesBoth_Carry = nan(max(trialNumBoth),50);
trialStatesBoth_Reach = nan(max(trialNumBoth),50);

trialTargetBoth = zeros(max(trialNumBoth),1);
trialStimBoth_Grasp = nan(max(trialNumBoth),100);
trialStimBoth_Carry = nan(max(trialNumBoth),50);
trialStimBoth_Reach = nan(max(trialNumBoth),50);

trialFRBoth_Grasp = nan(max(trialNumBoth),50,size(zScoredFRBoth,2));
trialZScoreBoth_Grasp = nan(max(trialNumBoth),50,size(zScoredFRBoth,2));
trialFRBoth_GraspBase = nan(max(trialNumBoth),50,size(zScoredFRBoth,2));
trialFRBoth_Reach = nan(max(trialNumBoth),50,size(zScoredFRBoth,2));
trialFRBoth_Carry = nan(max(trialNumBoth),50,size(zScoredFRBoth,2));
trialZScoreBoth_Carry = nan(max(trialNumBoth),50,size(zScoredFRBoth,2));

trialDirBoth_Carry = nan(max(trialNumBoth),50,3);
trialDirBoth_Reach = nan(max(trialNumBoth),50,3);
trialDirBoth_Grasp = nan(max(trialNumBoth),100,1);

graspState = find(cellfun(@(x) strcmp('Grasp',x),DataGT.TaskStateMasks.states));
reachState = find(cellfun(@(x) strcmp('Reach',x),DataGT.TaskStateMasks.states));
carryState = find(cellfun(@(x) strcmp('Carry',x),DataGT.TaskStateMasks.states));

for i = 1:max(trialNumBoth)

    if sum(trialNumBoth == i & StatesBoth(6:end-500) == reachState) > 12
        firstIdx = find(trialNumBoth == i & StatesBoth(6:end-500) == reachState,1,'first')+5;
        trialDirBoth_Reach(i,:,:) = filtKinBoth(firstIdx:firstIdx+49,1:3);
        trialFRBoth_Reach(i,:,:) = filtMeasBoth(firstIdx:firstIdx+49,goodChans);  %filtered firing rates
        trialStimBoth_Reach(i,:) = StimIdxBoth(firstIdx:firstIdx+49);
        trialStatesBoth_Reach(i,:) = StatesBoth(firstIdx:firstIdx+49);
    end

    if sum(trialNumBoth == i & StatesBoth(6:end-500) == carryState) > 12
        firstIdx = find(trialNumBoth == i & StatesBoth(6:end-500) == carryState,1,'first')+5;
        trialDirBoth_Carry(i,:,:) = filtKinBoth(firstIdx:firstIdx+49,1:3);
        trialFRBoth_Carry(i,:,:) = filtMeasBoth(firstIdx:firstIdx+49,goodChans);  %filtered firing rates
        trialZScoreBoth_Carry(i,:,:) = zScoredFRBoth(firstIdx:firstIdx+49,:);  %Z-Scored firing rates
        trialStimBoth_Carry(i,:) = StimIdxBoth(firstIdx:firstIdx+49);
        trialStatesBoth_Carry(i,:) = StatesBoth(firstIdx:firstIdx+49);
    end

    if sum(trialNumBoth == i & StatesBoth(6:end-500) == graspState) > 12
        firstIdx = find(trialNumBoth == i & StimIdxBoth(6:end-500),1,'first')+5;
        trialTargetBoth(i) = max(CommandedBoth(firstIdx:firstIdx+49));
        trialFRBoth_Grasp(i,:,:) = filtMeasBoth(firstIdx:firstIdx+49,goodChans);  %filtered firing rates
        trialZScoreBoth_Grasp(i,:,:) = zScoredFRBoth(firstIdx:firstIdx+49,:);  %Z-Scored Firing Rates
        trialFRBoth_GraspBase(i,:,:) = filtMeasBoth(firstIdx-50:firstIdx-1,goodChans);  %filtered firing rates
        trialStimBoth_Grasp(i,:) = StimIdxBoth(firstIdx-50:firstIdx+49);
        trialStatesBoth_Grasp(i,:) = StatesBoth(firstIdx-50:firstIdx+49);
        trialDirBoth_Grasp(i,:,:) = filtKinBoth(firstIdx-50:firstIdx+49,7);
    end
    
end

% Organize by target

orgByTargetGrasp = cell(4,1);

for i = 1:4
    orgByTargetGrasp{i} = find(trialTargetGrasp == i*3);
end

orgByTargetBoth = cell(4,1);

for i = 1:4
    orgByTargetBoth{i} = find(trialTargetBoth == i*3);
end

% Cross-Validated Classification analysis 

numOfFoldsGrasp = min(cellfun(@(x) length(x),orgByTargetGrasp));
numOfFoldsBoth = min(cellfun(@(x) length(x),orgByTargetBoth));

shuffByTargetBoth = cellfun(@(x) x(randperm(length(x))),orgByTargetBoth,'UniformOutput',false);
shuffByTargetGrasp = cellfun(@(x) x(randperm(length(x))),orgByTargetGrasp,'UniformOutput',false);


cMatBoth_GraspCV = zeros(4,4);
cMatBoth_CarryCV = zeros(4,4);
cMatGraspCV = zeros(4,4);


classMeasBoth_Grasp = squeeze(nanmean(trialFRBoth_Grasp(:,1:25,:),2))-nanmean(squeeze(nanmean(trialFRBoth_GraspBase(:,26:50,:),2)));%nanmean(squeeze(nanmean(trialFRBoth_Grasp(:,1:25,:),2)));%
classMeasBoth_Carry = squeeze(nanmean(trialFRBoth_Carry(:,1:25,:),2))-nanmean(squeeze(nanmean(trialFRBoth_Reach(:,1:25,:),2)));%nanmean(squeeze(nanmean(trialFRBoth_Carry(:,1:25,:),2)));%Carry Phase 241:290
classMeasGrasp = squeeze(nanmean(trialFRGrasp(:,1:25,:),2))-nanmean(squeeze(nanmean(trialFRGraspBase(:,26:50,:),2)));%nanmean(squeeze(nanmean(trialFRGrasp(:,1:25,:),2)));%

predictLevelBoth_Grasp = nan(max(trialNumBoth),1);
predictLevelBoth_Carry = nan(max(trialNumBoth),1);
predictLevelGrasp = nan(max(trialNumGrasp),1);


for i = 1:numOfFoldsBoth
    testTrials = cellfun(@(x) x(i),shuffByTargetBoth);
    trainTrials = cell2mat(shuffByTargetBoth);
    testTrialIdx = ismember(trainTrials,testTrials);

    foldClassiBoth_Grasp = fitcdiscr(classMeasBoth_Grasp(trainTrials(~testTrialIdx),:),trialTargetBoth(trainTrials(~testTrialIdx)));
    predictLevelBoth_Grasp(testTrials) = predict(foldClassiBoth_Grasp,classMeasBoth_Grasp(testTrials,:));

    foldClassiBoth_Carry = fitcdiscr(classMeasBoth_Carry(trainTrials(~testTrialIdx),:),trialTargetBoth(trainTrials(~testTrialIdx)));
    predictLevelBoth_Carry(testTrials) = predict(foldClassiBoth_Carry,classMeasBoth_Carry(testTrials,:));
end
for i = 1:numOfFoldsGrasp
    testTrials = cellfun(@(x) x(i),shuffByTargetGrasp);
    trainTrials = cell2mat(shuffByTargetGrasp);
    testTrialIdx = ismember(trainTrials,testTrials);

    foldClassiGrasp = fitcdiscr(classMeasGrasp(trainTrials(~testTrialIdx),:),trialTargetGrasp(trainTrials(~testTrialIdx)));
    predictLevelGrasp(testTrials) = predict(foldClassiGrasp,classMeasGrasp(testTrials,:));
end

for i = 1:max([length(trialTargetBoth) length(trialTargetGrasp)])
    if length(predictLevelGrasp)>=i && ~isnan(predictLevelGrasp(i))
        cMatGraspCV(trialTargetGrasp(i)/3,predictLevelGrasp(i)/3) = cMatGraspCV(trialTargetGrasp(i)/3,predictLevelGrasp(i)/3)+1;
    end
    if length(predictLevelBoth_Grasp)>= i && ~isnan(predictLevelBoth_Grasp(i))
        cMatBoth_GraspCV(trialTargetBoth(i)/3,predictLevelBoth_Grasp(i)/3) = cMatBoth_GraspCV(trialTargetBoth(i)/3,predictLevelBoth_Grasp(i)/3)+1;
        cMatBoth_CarryCV(trialTargetBoth(i)/3,predictLevelBoth_Carry(i)/3) = cMatBoth_CarryCV(trialTargetBoth(i)/3,predictLevelBoth_Carry(i)/3)+1;
    end
end

pctAccBoth_GraspCV = trace(squeeze(cMatBoth_GraspCV(:,:)))/sum(sum(cMatBoth_GraspCV));
pctAccBoth_CarryCV = trace(squeeze(cMatBoth_CarryCV(:,:)))/sum(sum(cMatBoth_CarryCV));
pctAccGraspCV = trace(squeeze(cMatGraspCV(:,:)))/sum(sum(cMatGraspCV));

cMatBoth_Grasp = zeros(4,4);
cMatBoth_Carry = zeros(4,4);
cMatGrasp = zeros(4,4);


for i = 1:max([length(trialTargetBoth) length(trialTargetGrasp)])
    if length(predictLevelGrasp)>=i && ~isnan(predictLevelGrasp(i))
        cMatGrasp(trialTargetGrasp(i)/3,predictLevelGrasp(i)/3) = cMatGrasp(trialTargetGrasp(i)/3,predictLevelGrasp(i)/3)+1;
    end
    if length(predictLevelBoth_Grasp)>= i && ~isnan(predictLevelBoth_Grasp(i))
        cMatBoth_Grasp(trialTargetBoth(i)/3,predictLevelBoth_Grasp(i)/3) = cMatBoth_Grasp(trialTargetBoth(i)/3,predictLevelBoth_Grasp(i)/3)+1;
    end
    if length(predictLevelBoth_Carry)>= i && ~isnan(predictLevelBoth_Carry(i))
        cMatBoth_Carry(trialTargetBoth(i)/3,predictLevelBoth_Carry(i)/3) = cMatBoth_Carry(trialTargetBoth(i)/3,predictLevelBoth_Carry(i)/3)+1;
    end
end

% Cross-Condition Classification

predictLevelBG_BC = predict(foldClassiBoth_Grasp,classMeasBoth_Carry);
predictLevelBG_Grasp = predict(foldClassiBoth_Grasp,classMeasGrasp);


predictLevelBC_BG = predict(foldClassiBoth_Carry,classMeasBoth_Grasp);
predictLevelBC_Grasp = predict(foldClassiBoth_Carry,classMeasGrasp);


predictLevelGrasp_BG = predict(foldClassiGrasp,classMeasBoth_Grasp);
predictLevelGrasp_BC = predict(foldClassiGrasp,classMeasBoth_Carry);


cMatBG_BC = zeros(4,4);
cMatBG_Grasp = zeros(4,4);

cMatBC_BG = zeros(4,4);
cMatBC_Grasp = zeros(4,4);

cMatGrasp_BG = zeros(4,4);
cMatGrasp_BC = zeros(4,4);

for i = 1:max([length(trialTargetBoth) length(trialTargetGrasp)])
    if length(predictLevelGrasp)>=i && ~isnan(predictLevelGrasp(i))
        cMatBG_Grasp(trialTargetGrasp(i)/3,predictLevelBG_Grasp(i)/3) = cMatBG_Grasp(trialTargetGrasp(i)/3,predictLevelBG_Grasp(i)/3)+1;
        cMatBC_Grasp(trialTargetGrasp(i)/3,predictLevelBC_Grasp(i)/3) = cMatBC_Grasp(trialTargetGrasp(i)/3,predictLevelBC_Grasp(i)/3)+1;
    end
    if length(predictLevelBoth_Grasp)>= i && ~isnan(predictLevelBoth_Grasp(i))
        cMatBC_BG(trialTargetBoth(i)/3,predictLevelBC_BG(i)/3) = cMatBC_BG(trialTargetBoth(i)/3,predictLevelBC_BG(i)/3)+1;
        cMatGrasp_BG(trialTargetBoth(i)/3,predictLevelGrasp_BG(i)/3) = cMatGrasp_BG(trialTargetBoth(i)/3,predictLevelGrasp_BG(i)/3)+1;
    end
    if length(predictLevelBoth_Carry)>= i && ~isnan(predictLevelBoth_Carry(i))
        cMatBG_BC(trialTargetBoth(i)/3,predictLevelBG_BC(i)/3) = cMatBG_BC(trialTargetBoth(i)/3,predictLevelBG_BC(i)/3)+1;
        cMatGrasp_BC(trialTargetBoth(i)/3,predictLevelGrasp_BC(i)/3) = cMatGrasp_BC(trialTargetBoth(i)/3,predictLevelGrasp_BC(i)/3)+1;
    end
end



pctAccBG_BC = trace(squeeze(cMatBG_BC(:,:)))/sum(sum(cMatBG_BC));
pctAccGrasp_BC = trace(squeeze(cMatGrasp_BC(:,:)))/sum(sum(cMatGrasp_BC));

pctAccBC_BG = trace(squeeze(cMatBC_BG(:,:)))/sum(sum(cMatBC_BG));
pctAccGrasp_BG = trace(squeeze(cMatGrasp_BG(:,:)))/sum(sum(cMatGrasp_BG));

pctAccBC_Grasp = trace(squeeze(cMatBC_Grasp(:,:)))/sum(sum(cMatBC_Grasp));
pctAccBG_Grasp = trace(squeeze(cMatBG_Grasp(:,:)))/sum(sum(cMatBG_Grasp));

% Plotting

plotData = [pctAccGraspCV pctAccBG_Grasp pctAccBC_Grasp;...
    pctAccGrasp_BG pctAccBoth_GraspCV pctAccBC_BG;...
    pctAccGrasp_BC pctAccBG_BC pctAccBoth_CarryCV];


figure();
confusionMatrix(plotData)
colormap(flipud(bone))
caxis([0.25 1])
axis square;ax = gca;
ax.XTick = [1 2 3];ax.XTickLabel = {'Squeeze','Grasp','Transport'};
ax.YTick = [1 2 3];ax.YTickLabel = {'Squeeze','Grasp','Transport'};
ax.FontSize = 16;

title('Cross Condition Classification Performance','FontSize',24);
xlabel('Condition Tested','FontSize',22);ylabel('Condition Trained','FontSize',22);

% Individual Units by trial

classZScoreBoth_Grasp = squeeze(nanmean(trialZScoreBoth_Grasp,2));

classZScoreBoth_Carry = squeeze(nanmean(trialZScoreBoth_Carry,2));

classZScoreGrasp = squeeze(nanmean(trialZScoreGrasp,2));


% ANOVA

anovaData = [classZScoreGrasp;classZScoreBoth_Grasp;classZScoreBoth_Carry];
groupPhase = [repmat({'active'},size(classZScoreGrasp,1),1);...
    repmat({'grasp'},size(classZScoreBoth_Grasp,1),1);repmat({'carry'},size(classZScoreBoth_Carry,1),1)];
groupForce = [trialTargetGrasp;trialTargetBoth;trialTargetBoth];

p_ANOVA = nan(3,size(anovaData,2));
tbl_ANOVA = cell(1,size(anovaData,2));
stats_ANOVA = cell(1,size(anovaData,2));

for i = 1:size(anovaData,2)
    [p_ANOVA(:,i),tbl_ANOVA{i},stats_ANOVA{i}] = anovan(anovaData(:,i),{groupPhase groupForce},'model','interaction','varnames',{'Phase','Force'},'display','off');
end

interact_FStat = cellfun(@(x) x{4,6},tbl_ANOVA);
stim_FStat = cellfun(@(x) x{3,6},tbl_ANOVA);
switchIdx = interact_FStat./stim_FStat;


phaseAmpMedians = nan(4,3,size(p_ANOVA,2));

for i = 1:4
    phaseAmpMedians(i,:,:) = [median(classZScoreGrasp(trialTargetGrasp == i*3,:));...
        median(classZScoreBoth_Grasp(trialTargetBoth == i*3,:));median(classZScoreBoth_Carry(trialTargetBoth == i*3,:))];
end

% Plot Firing Rates
colorMap4 = [43 131 186; 171 221 164;253 174 97;215 25 28]/255;

for i = find(ismember(chanRefIdx,[54, 55, 151, 242]))%Alternatives: find(switchIdx < 0.1), find(ismember(chanRefIdx,[150 165 176 189 178])), find(ismember(chanRefIdx,[1 20 39 42 54 55 151 242]))
    yLimits = zeros(4,2);
    figure();
  
    subplot(1,4,1);
    meanTraj = squeeze(nanmean(trialFRGrasp(:,:,i),1))*50;
    plot(squeeze(nanmean(trialFRGrasp(trialTargetGrasp == 3,:,i),1))*50-meanTraj,'Color',colorMap4(1,:),'LineWidth',3);hold on;
    plot(squeeze(nanmean(trialFRGrasp(trialTargetGrasp == 6,:,i),1))*50-meanTraj,'Color',colorMap4(2,:),'LineWidth',3);
    plot(squeeze(nanmean(trialFRGrasp(trialTargetGrasp == 9,:,i),1))*50-meanTraj,'Color',colorMap4(3,:),'LineWidth',3);
    plot(squeeze(nanmean(trialFRGrasp(trialTargetGrasp == 12,:,i),1))*50-meanTraj,'Color',colorMap4(4,:),'LineWidth',3);
    axis([0 50 -10 10]);
    ax2 = gca;ax2.XTick = [];ax2.XColor = 'none';%ax2.YColor = 'none';ax2.YTick = [];
    ax2.YTick = [-10 0 10];ax2.FontSize = 14;ylabel('\Delta Firing Rate (Hz)','FontSize',16)
    box off;ax2.TickLength = [0 0]; title('Active','FontSize',16);yLimits(2,:) = ylim';

    
    subplot(1,4,2);
    meanTraj = squeeze(nanmean(trialFRBoth_Grasp(:,:,i),1))*50;
    plot(squeeze(nanmean(trialFRBoth_Grasp(trialTargetBoth == 3,:,i),1))*50-meanTraj,'Color',colorMap4(1,:),'LineWidth',3);hold on;
    plot(squeeze(nanmean(trialFRBoth_Grasp(trialTargetBoth == 6,:,i),1))*50-meanTraj,'Color',colorMap4(2,:),'LineWidth',3);
    plot(squeeze(nanmean(trialFRBoth_Grasp(trialTargetBoth == 9,:,i),1))*50-meanTraj,'Color',colorMap4(3,:),'LineWidth',3);
    plot(squeeze(nanmean(trialFRBoth_Grasp(trialTargetBoth == 12,:,i),1))*50-meanTraj,'Color',colorMap4(4,:),'LineWidth',3);
    axis([0 50 -10 10]);
    ax3 = gca;ax3.XTick = [];ax3.YTick = [];ax3.XColor = 'none';ax3.YColor = 'none';
    box off;ax3.TickLength = [0 0];title('Grasp','FontSize',16);yLimits(3,:) = ylim';
    
    subplot(1,4,3);
    meanTraj = squeeze(nanmean(trialFRBoth_Carry(:,:,i),1))*50;
    plot(squeeze(nanmean(trialFRBoth_Carry(trialTargetBoth == 3,:,i),1))*50-meanTraj,'Color',colorMap4(1,:),'LineWidth',3);hold on;
    plot(squeeze(nanmean(trialFRBoth_Carry(trialTargetBoth == 6,:,i),1))*50-meanTraj,'Color',colorMap4(2,:),'LineWidth',3);
    plot(squeeze(nanmean(trialFRBoth_Carry(trialTargetBoth == 9,:,i),1))*50-meanTraj,'Color',colorMap4(3,:),'LineWidth',3);
    plot(squeeze(nanmean(trialFRBoth_Carry(trialTargetBoth == 12,:,i),1))*50-meanTraj,'Color',colorMap4(4,:),'LineWidth',3);
    axis([0 50 -10 10]);
    ax4 = gca;ax4.XTick = [];ax4.YTick = [];ax4.XColor = 'none';ax4.YColor = 'none';
    box off;ax4.TickLength = [0 0];title('Carry','FontSize',16);yLimits(4,:) = ylim';
    
     sgtitle(chanRefIdx(i),'FontSize',24);

    subplot(1,4,4);
    ymax = 10;ymin = -10;

    axis([0 50 ymin ymax]);ax1 = gca;ax1.XTick = [];ax1.YTick = [];
    ax1.XColor = 'none';ax1.YColor = 'none';box off;ax1.TickLength = [0 0];
    text(20,ymax-0.3*(ymax-ymin),{'\color[rgb]{.843 .098 .109} 56 uA','\color[rgb]{.992 .682 .38} 44 uA',...
        '\color[rgb]{.671 .867 .643} 32 uA','\color[rgb]{.169 .514 .729} 20 uA'},'FontSize',16);
    
end

% Compare baseline rates for reviewer

baseFRGrasp = squeeze(nanmean(trialFRGraspBase(:,26:50,:),2));
baseFRBoth_Grasp = squeeze(nanmean(trialFRBoth_GraspBase(:,26:50,:),2));
baseFRBoth_Carry = squeeze(nanmean(trialFRBoth_Reach(:,1:25,:),2));

meanFRTotal = nanmean([baseFRGrasp;baseFRBoth_Grasp;baseFRBoth_Carry],1);

tempStimFR(1,:) = nanmean(squeeze(nanmean(trialFRBoth_Carry(orgByTargetBoth{1},1:25,:),2)));tempStimFR(4,:) = nanmean(squeeze(nanmean(trialFRBoth_Carry(orgByTargetBoth{4},1:25,:),2)));
deltaFRBoth_Carry = tempStimFR(4,:) - tempStimFR(1,:);%= max(tempStimFR) - min(tempStimFR);

tempStimFR(1,:) = nanmean(squeeze(nanmean(trialFRBoth_Grasp(orgByTargetBoth{1},1:25,:),2)));tempStimFR(4,:) = nanmean(squeeze(nanmean(trialFRBoth_Grasp(orgByTargetBoth{4},1:25,:),2)));
deltaFRBoth_Grasp = tempStimFR(4,:) - tempStimFR(1,:);%= max(tempStimFR) - min(tempStimFR);

tempStimFR(1,:) = nanmean(squeeze(nanmean(trialFRGrasp(orgByTargetGrasp{1},1:25,:),2)));tempStimFR(4,:) = nanmean(squeeze(nanmean(trialFRGrasp(orgByTargetGrasp{4},1:25,:),2)));
deltaFRGrasp = tempStimFR(4,:) - tempStimFR(1,:);%= max(tempStimFR) - min(tempStimFR);


[rho_Comb, p_Comb] = corr(([deltaFRGrasp deltaFRBoth_Grasp deltaFRBoth_Carry]./[meanFRTotal meanFRTotal meanFRTotal])',([nanmean(baseFRGrasp,1) nanmean(baseFRBoth_Grasp,1) nanmean(baseFRBoth_Carry,1)]./[meanFRTotal meanFRTotal meanFRTotal])')

% Plot with connections
figure();
for i = 1:size(baseFRGrasp,2)
plot(([nanmean(baseFRGrasp(:,i)) nanmean(baseFRBoth_Grasp(:,i)) nanmean(baseFRBoth_Carry(:,i))]./[meanFRTotal(i) meanFRTotal(i) meanFRTotal(i)]),([deltaFRGrasp(i) deltaFRBoth_Grasp(i) deltaFRBoth_Carry(i)]./[meanFRTotal(i) meanFRTotal(i) meanFRTotal(i)]),'ko-','LineWidth',3,'MarkerSize',6,'MarkerFaceColor','k');
hold on;
end
axis square; axis([0.3 2 -.5 1.75]);ax = gca; ax.XTick = [.5 1 1.5 2];ax.YTick = [-.5 .5 1.5];
box off;ax.TickLength = [0 0]; ax.LineWidth = 2;ax.FontSize = 22;axis square;
xlabel('Baseline Firing Rate (A.U.)','FontSize',30);ylabel('ICMS-evoked Modulation (A.U.)','FontSize',30);

end



