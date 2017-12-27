%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_CalReliability
% Process		: Calculate reliability for each position in gait template
% Input			:
%	- mrRealDataTrain		: real value gait data template used for training after spline interpolatioon
%	- nGaitTempNo			: number of gait templates for each user
% Output		:
%	- mnReliIndex			: index of bit 
%	- mnReliVal				: reliability value of bit specified in the index
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [vnReliVal vnReliIndex] = func_UserCalReliability(mrOtherUserTrain, mrCurUserTrain)

	%CALCULATE MEANS AND VARIANCES FOR CURRENT USER
	
	%calculate the mean of current user 
	vrMeansCurUser = mean(mrCurUserTrain);
	
	%calculate variance
	mrVariances = [];
	for iTemplate = 1 : size(mrCurUserTrain,1)
		% calculate the variance of template iTemplate
		mrVariances = [mrVariances; (mrCurUserTrain(iTemplate,:) - vrMeansCurUser).^2];
	end
	vrVariance = sum(mrVariances)./(size(mrVariances,1)-1);
	
	%for each feature, calculate the average distance of current user to other user
	mrInterVariance = zeros(1,size(mrOtherUserTrain,2));
	for iTemplate = 1 : size(mrOtherUserTrain,1)
		%get current template
		vrCurTemplate = mrOtherUserTrain(iTemplate,:);
		vrCurDistance = abs(vrCurTemplate - vrMeansCurUser);
		mrInterVariance = mrInterVariance + vrCurDistance;
	end
	%calculate the average distance
	mrInterVariance = mrInterVariance./ size(mrOtherUserTrain,1);
	
	x = abs(mrInterVariance)./(sqrt(vrVariance.*2));

	[erf_x] = erf(x);
	erf_x = (erf_x+1)/2;
	vrReliValue = erf_x;

	[vnReliIndex vnReliVal] = sort(vrReliValue,2,'descend');
end