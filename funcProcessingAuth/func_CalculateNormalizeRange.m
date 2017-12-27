%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_CalculateNormalizeRange
% Process		: using training data, find the user-based min-max range to normalize data of this user
% Input			:
%	- mrGaitData	: TRAINING gait data  
%	- nDimensionsNo	: number of dimensions, in this source code use: 3 dimensions --> 4
%	- nMeanMethod	: 1 OR 2 (1: calculate means of all template, 2: calculate means of all gaits cycles of all templates)
%	- nCyclesNo		: number of gait cycles in each gait template
%
% Output		:
%   - mrHELPNormalizeRange      : range for each user that used to normalize
%
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mrHELPNormalizeRange] = func_CalculateNormalizeRange(mrGaitDataTrain, nDimensionsNo, nOneDimLength, nMeanMethod, nCyclesNo)
	
	mrHELPNormalizeRange = [];
	%for each dimension, calculate means and find min max of calculated means template
%	nOneDimLength = (size(mrGaitDataTrain,2))/(nDimensionsNo+1);
	for iDim = 1 : nDimensionsNo
		%calculate start and end index of current dimension
		iStartPos = (iDim-1)*nOneDimLength + 1;
		iEndPos = iStartPos + nOneDimLength - 1;
		%get gait data of current dimension
		mrCurComponent = mrGaitDataTrain(:,iStartPos:iEndPos);
		%calculate means data of current component
		vrMeansCurComponent = [];
		if(nMeanMethod == 1)
			vrMeansCurComponent = mean(mrCurComponent);
		else
			vrMeansCurComponent = mean(mrCurComponent);
			nCycleLength = size(vrMeansCurComponent,2)/nCyclesNo;
			mrAllCyclesMean = [];
			for iCycle = 1 : nCyclesNo
				iStart = (iCycle-1)*nCycleLength+1;
				iEnd = iStart + nCycleLength - 1;
				mrAllCyclesMean = [mrAllCyclesMean; vrMeansCurComponent(iStart: iEnd)];
			end
			vrMeansCurComponent = mrAllCyclesMean;
		end
		%calculate means of current dimensions		
			
		%find min, max of the current component of means template
		rMeansMin = min(vrMeansCurComponent);
		rMeansMax = max(vrMeansCurComponent);
		%get data of current dimension
		vrCurDimRange = [rMeansMin rMeansMax];
		%update to help normalize matrix
		mrHELPNormalizeRange = [mrHELPNormalizeRange; vrCurDimRange];
	end
end	
