%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_BasedRangeCal
% Process		: Calculate based value for binary gait template extraction
% Input			:
%	- mrHELPNorRangeAllU	: help data used for normalize gait data for each user
%	- nDimensionsNo			: number of dimension, in this source code use: 3 dimensions  --> 3
%	- nTrainTempNo 			: No. of gait template for trainning of each user
%	- nQuanBitNo			: No. of bits for quantization scheme
%	
% Output		:	
%	- mrBasedValue			: based value for binary gait template extraction, each dimension (X, Y, Z) has its own range
%
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vrBasedValue vrMeanValue]=func_BasedRangeCalGetMean(rMin, rMax, nQuanBitNo)
	
	vrBasedValue=[];
	vrMeanValue = [];
	rCurLevel=rMin;
    nRangeNo=(2^nQuanBitNo);
	%calculate the range value
	rRange = (rMax-rMin)/nRangeNo;
	vrMeanValue = [vrMeanValue (rMin+rRange/2)];
	for iStep = 1:(nRangeNo-1)
		vrBasedValue(iStep) = rCurLevel + rRange;
		rCurLevel = rCurLevel + rRange;
		vrMeanValue = [vrMeanValue (rCurLevel+rRange/2)];
	end
end		%end of function define