%% Overlapping subspaces in motor and stimulation tasks (Supplementary Figure 17)
% Methods from Jiang et al (2022, Cell reports) 
% https://www.sciencedirect.com/science/article/pii/S2211124720309918 

% To quantify overlap between motor and stimulation subspaces, we ran two tasks. In one, we instructed
% the participant to attempt to grasp a virtual object at one of 4 force levels, hold it for 1 second, then release it. No stimulation was
% delivered during the task. In the second task, we delivered stimulation trains that were identical in duration and shape to the grasp
% profiles in the first task. The participant was blinded to the level of stimulation and was instructed to report the magnitude of
% stimulation to maintain engagement in the task. By comparing the M1 activity in the two conditions, we can extract subspaces in
% M1 population activity that is exclusive to the motor task (related to volitionally moving the hand) or to stimulation, as well as the
% subspace shared by the two tasks.
%% Load preprocessed data
close all; clear all; clc 

load('motor_vs_stimulation_subspace.mat', 'PData')

%% Compute PSTHs and covariance matrices for motor and stim datasets

PSTH = {}; CovMat = {};
for c = 1:length(PData)
    unique_force_cond = unique(PData(c).ForceTarget); 
    num_conds = length(unique_force_cond);

    PSTH{c} = nan(num_conds, length(PData(c).T), length(PData(c).ActiveChans));
    for cond = 1:num_conds
        cond_idx = find(PData(c).ForceTarget == unique_force_cond(cond));
        PSTH{c}(cond,:,:) = squeeze(nanmean(PData(c).SpikeCounts(cond_idx,:,:), 1));
    end 

    PSTH_long =reshape(permute(PSTH{c}, [2 1 3]), [length(unique_force_cond)*length(PData(c).T) length(PData(c).ActiveChans)]);

    CovMat{c} = cov(PSTH_long);  
end

%% Compute exclusive and overlapping subspaces for motor and stim tasks 
% Three subspaces are extracted: 1) One that contains variance of the motor task, 
% 2) one that contains variance of the stimulation task, 
% 3) one that contains the variance that is common to the two tasks (sharred)
% Then motor and stimulation data are each projected on the sharred subspace
% Code from from Jiang et al (2022, Cell reports) - make sure to add matlab package to directory

dim_all = 5;
d_Q1 = dim_all;
d_Q2 = dim_all;
d_shared = dim_all;
d_PC = dim_all;
alphaNullSpace = 0.01;

ProjMat = struct; ProjVarExpl = struct;

Xcov1 = CovMat{1};
Xcov2 = CovMat{2};

[Q1excl,flag1] = exclusive_subspace(Xcov1,Xcov2,d_Q1,alphaNullSpace); 
ProjMat.Q1excl = Q1excl;
flag1
 % if flag1 = 1 then it means no subspace meets the constraint
eigvals1 = eigs(Xcov1, d_Q1, 'la');
ProjVarExpl.X1onQ1excl = var_proj(Q1excl,Xcov1,sum(eigvals1(1:d_Q1)));

[Q2excl,flag2] = exclusive_subspace(Xcov2,Xcov1,d_Q2,alphaNullSpace);
flag2
ProjMat.Q2excl = Q2excl;
eigvals2 = eigs(Xcov2, d_Q2, 'la');
ProjVarExpl.X2onQ2excl = var_proj(Q2excl,Xcov2,sum(eigvals2(1:d_Q2)));

[Q1,Qshared, Qcost, info, options] = shared_subspace(Q1excl,d_Q1,Q2excl,d_Q2,Xcov1,Xcov2,d_shared);
ProjMat.Qshared = Qshared;

% variance explained for each condition in the shared subspace
ProjVarExpl.X1onShared = var_proj(Qshared,Xcov1,sum(eigvals1(1:d_shared)));
ProjVarExpl.X2onShared = var_proj(Qshared,Xcov2,sum(eigvals2(1:d_shared)));

%% Plot variance explained by the sharred subspace in the motor and stim tasks
% The shared subspace captures significant variance of both motor and stimulation tasks.

col = [0.2*ones(1,3);
    [29 43 141]/256];

figure
cp = 1;
b = bar([ProjVarExpl.X1onShared,ProjVarExpl.X2onShared],'FaceColor','flat', 'FaceAlpha', 0.7);
b.CData = col;
% grid on;
box off
ax= gca();
ax.XTickLabel = {'Motor', 'Stim'};
xlabel('Subspace projections');
ylabel('Variance exlained');
ylim([0 .5])
set(gca, 'FontSize', 15)
