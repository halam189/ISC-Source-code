%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	History:
%		<Original >
%		2015:12:22	<MO0002>	Ha Lam	:	Use quantization scheme for binarization
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_BinArrGenerating
% Process		: Generating an array of binary string follow the Gray code properties
% Input			:
%	- nBitNumber			: number of bits per an array
% Output		:
%	- vbBasedBinValue		: binary based for quantization
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [vbBasedBinValue] = func_BinArrGenerating(nBitNumber)
	vb1stLevelBinValue = [0;1];
	vbPreLevelBinValue = vb1stLevelBinValue;
	for iBitNo = 2 : nBitNumber
		vbCurLevelBinValue = vbPreLevelBinValue;
		%double previous array
		vbCurLevelBinValue = [vbCurLevelBinValue; flipud(vbCurLevelBinValue)];
		%add new bit
		nStep = 2^(iBitNo-1);
		vbAddOne = ones(nStep,1);
		vbAddZero = zeros(nStep,1);
		
		vbAdd = [vbAddZero;vbAddOne];
		vbCurLevelBinValue = [vbAdd vbCurLevelBinValue ];
		vbPreLevelBinValue = vbCurLevelBinValue;
	end
	vbBasedBinValue = vbPreLevelBinValue;
end

