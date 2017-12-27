%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_GetReliableFeature
% Process		: Extract binary template gait data for both training and testing
% Input			:
%	- vbBinTemplate	: binary gait template
%	- vnReliIndex	: index of bits string which follow the descending order of reliability 
%	- nCodeWordSize	: size of code word used for BCH
%	- nQuanBitNo	: No. of bits for quantization scheme

% Output		:
%	- mbReliBinStr	: reliable binary template
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mrReliComp = func_GetReliableRealComp(mrCurUserTrain,vnReliIndex,nCodeWordSize,nQuanBitNo)

	nFeatureNo = fix(nCodeWordSize/nQuanBitNo)+1;

	%vbBinTemp = [];
	%for iFeat = 1 : nFeatureNo
	%	%get index of current feature
	%	nFeatIndex = vnReliIndex(iFeat);
	%	
	%	%get bit string at indicated index
	%	nIdxStart=(nFeatIndex-1)*nQuanBitNo+1;
	%	nIdxEnd= nIdxStart+nQuanBitNo - 1 ;
	%	vbBinTemp = [vbBinTemp vbBinTemplate(nIdxStart:nIdxEnd)];
	%end
	%vbRelBinTemplate = vbBinTemp(1:nCodeWordSize);
	mrReliComp = mrCurUserTrain(:,vnReliIndex(1:nFeatureNo));
	
	%mbReliBinStr = NaN(size(mbGaitData,1),nCodeWordSize);
	%
	%for i = 1 : size(mnReliIndex,1)
	%	mbReliBinStr((nTimes*(i-1)+1:nTimes*i),:)= ...
	%		mbGaitData((nTimes*(i-1)+1:nTimes*i),[mnSelectedIndex(i,:)]);
	%end
	
	
end