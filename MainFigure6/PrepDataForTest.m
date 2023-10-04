function [Measurement, Kinematics, idx]=PrepDataForTest(Measurement,Kinematics,TaskStateMasks,varargin)
%To be called after prepData  in order to apply the filters, remove nans et cetra to get signals ready for testing
%Meant to approximate the data processing in Extraction during prediction

%define scale factors for the different dimensions.
trans_factor = 1;
ori_factor = 1;
grasp_factor = .5;

len = length(Kinematics(1,:));

Kinematics(:,TransIdxs([],len)) = Kinematics(:,TransIdxs([],len))*trans_factor;
Kinematics(:,OriIdxs([],len)) = Kinematics(:,OriIdxs([],len))*ori_factor;
Kinematics(:,GraspIdxs([],len)) = Kinematics(:,GraspIdxs([],len))*grasp_factor;

parse_varargin(varargin,'FilterSigs',true,'SqrtTransform',true,'OnlyCalib',true);

fs = 1/0.020;%Hz

nan_idx = any(isnan(Measurement),2)' | any(isnan(Kinematics),2)';

%square-root transform:
if SqrtTransform
    Measurement = sqrt(Measurement);
end

if FilterSigs
    %%% Filters:
    %*interpolate then apply* or apply separately at each NAN?
    %Spike_filter = [0.0932 0.0885 0.0841 0.0799 0.0759 0.0721 0.0685 0.0651 0.0618 0.0587 0.0558 0.0530 0.0503 0.0478 0.0454]'; %from NHP lab - LPF with -3dB cutoff ~1Hz, weighted to more recent values
    %Spike_filter = [.0636 .0615 .0594 .0574 .0555 .0536 .0518 .0501 .0484 .0467 .0452 .0436 .0422 .0408 .0394 .0381 .0368 .0355 .0343 .0331 .0321 .0310]'; %JW: new values for 50 Hz sampling
    Spike_filter = filterCoefs;
    t = 1:size(Measurement,1);
    M =  interp1(t(~nan_idx),Measurement(~nan_idx,:),t,'linear',0);
    % window_len = 0.5*fs;
    % window = hanning(round(window_len));
    % window = window/sum(window);
    M = conv2(M,Spike_filter,'valid');
    M = [nan(size(Spike_filter,1)-1,size(M,2)); M];
    Measurement(~nan_idx,:) = M(~nan_idx,:);
    nan_idx = any(isnan(Measurement),2)' | any(isnan(Kinematics),2)';
end

%pare down to trainable data:
if exist('TaskStateMasks','var')
    if OnlyCalib
        calib_idx = TaskStateMasks.use_for_calib==1;
    else
        calib_idx = ones(1,length(TaskStateMasks.use_for_calib));
    end
reject_idx = [0 double(any(diff(TaskStateMasks.target'),2))']; %times when the target changed
arm_not_moving_idx = all(TaskStateMasks.active_assist_weight==0) & all(TaskStateMasks.brain_control_weight==0); %if arm was not allowed to move (ie Presentation state) don't use data
result_code = InterpResultCode(TaskStateMasks.result_code);
success_idx = result_code.SuccessfulTrial==1;

%reject for reaction time:
reject_time = 0; %seconds

reject_samples=round(reject_time*fs); 
idxs = find(reject_idx>=1);
reject_idx = zeros(size(reject_idx));
if reject_time>0
    for a = 1:length(idxs)
        reject_idx(idxs(a):idxs(a)+reject_samples)=1;
    end
end
% fprintf('Rejecting %d samples at the begining of each state\n',reject_samples)
idx = nan_idx | ~calib_idx | reject_idx | arm_not_moving_idx | ~success_idx;
Measurement(idx,:)=[];
Kinematics(idx,:)=[];
end
