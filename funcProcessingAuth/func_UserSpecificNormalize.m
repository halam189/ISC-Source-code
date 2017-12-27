%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_UserSpecificNormalize
% Process		: using training data, find the user-based min-max range, normalize all data to this range, store min-max range as helper data for each user
% Input			:
%	- mrGaitData		: original TRAINING gait data for all users, each 16 rows is data for one user 
%	- nDimensionsNo	: number of dimension, in this source code use: 3 dimensions + 1 time stamp --> 4
%	- nMeanMethod		: 1 OR 2 (1: calculate means of all template, 2: calculate means of all gaits cycles of all templates)
%	- nCyclesNo			: number of gait cycles in each gait template
%
% Output		:
%	- mrGaitDataNormalized     : real value gait data template after normalizing
%
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mrGaitDataNormalized] = func_UserSpecificNormalize(mrGaitData, mrHELPNormalizeRange, nDimensionsNo, nMeanMethod, nCyclesNo)

	mrGaitDataNormalized = [];
	%for each dimension, calculate means and find min max of calculated means template
	nOneDimLength = (size(mrGaitData,2)-1)/(nDimensionsNo+1);
	for iDim = 1 : nDimensionsNo
		%calculate start and end index of current dimension
		iStartPos = (iDim-1)*nOneDimLength + 1;
		iEndPos = iStartPos + nOneDimLength - 1;
		%get gait data of current dimension
		mrCurComponent = mrGaitData(:,iStartPos:iEndPos);
		%current dimension min and max to normalize
		rCurDimMinMeans = mrHELPNormalizeRange(iDim, 1);
		rCurDimMaxMeans = mrHELPNormalizeRange(iDim, 2);
		
		%for each template of this user, normalize it to range rMeansMin-rMeansMax
		mrCurCompNormalized = [];
		for iTemplate = 1 : size(mrGaitData,1)
			%for each gait template
			vrCurDimTemplate = mrCurComponent(iTemplate,:);
			%find min and max of this template
			rMin = 0; rMax = 0;
			if(nMeanMethod == 1)
				rMin = min(vrCurDimTemplate);
				rMax = max(vrCurDimTemplate);
			else
				mrAllCycles = [];
				for iCycle = 1 : nCyclesNo
					iStart = (iCycle-1)*nCycleLength+1;
					iEnd = iStart + nCycleLength - 1;
					mrAllCycles = [mrAllCycles; vrCurDimTemplate(iStart: iEnd)];
				end
				mrAllCyclesMean = mean(mrAllCycles);
				rMin = min(mrAllCyclesMean);
				rMax = max(mrAllCyclesMean);
			end
			%normalize data 
			vrNormalize = (vrCurDimTemplate - rMin)./(rMax-rMin)*(rCurDimMaxMeans-rCurDimMinMeans)+rCurDimMinMeans;
			mrCurCompNormalized = [mrCurCompNormalized; vrNormalize];
		end	%end each template
		mrGaitDataNormalized = [mrGaitDataNormalized mrCurCompNormalized];
	end %end each dimensions
	%add time stamp and user id
	nStartTimePos 	= nDimensionsNo*nOneDimLength + 1;       
	nEndTimePos 	= size(mrGaitData,2);    	
	mrGaitDataNormalized = [mrGaitDataNormalized mrGaitData(:, nStartTimePos:nEndTimePos)];	
end		%end of function define