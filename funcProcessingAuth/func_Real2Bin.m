%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_Real2Bin
% Process		: Extract binary template gait data for both training and testing
% Input			:
%	- mrRealValueTemplate	: real value gait data template after spline interpolatioon
%	- nDimensionsNo			: number of dimensions using (X, Y, Z,...)
%	- mrBasedValue			: based value for binary gait template extraction, each dimension (X, Y, Z) has its own range
%	- nQuanBitNo			: No. of bits for quantization scheme
%	- vbBasedBinValue		: the corresponding binary string for each range
% Output		:
%	- mbBinTemplate			: extracted binary gait template
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [mbBinTemplate]= func_Real2Bin(mrRealValueTemplate, mrBasedValue, nQuanBitNo, vbBasedBinValue)

	mbBinTemplate = [];
	%calculate means of all input template
	vrMeansIntraOne = mean(mrRealValueTemplate);
	
	vnLevelNo = (0:((2^nQuanBitNo)-1));
	%quantizating
	for	iData = 1 : size(vrMeansIntraOne,2)
		nLevel = size(vnLevelNo,2);
		for iLevel = 1 : (size(vnLevelNo,2)-1)
			if(vrMeansIntraOne(iData) < mrBasedValue(iLevel))
				nLevel = iLevel;
                break;
			end
		end
		mbBinTemplate = [mbBinTemplate vbBasedBinValue(nLevel,:)];
	end
end