%******************************************************************************************
%
%	History:
%		2016:08:24	<MO0014>	Ha Lam	: 	Apply PCA before binarization
%		2016:08:24	<MO0016>	Ha Lam	: 	Apply PCA for each user data set
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_ReliableTestExtract
% Process		: Authenticate user with input gait template and stored helping data (used in test phase)
% Input			:
%	- mrAllUserTest			: real value gait data template that used for testing
%	- vnLabels				: user ID array of corresponding gait template mrAllUserTest
%	- iUser					: user id that is being tried to authenticate
%	- cSystemParam			: structure that contains all neccessary parameters to authenticate user
%	- mrHELPNormalizeRange	: help data: range from min-max for normalization
%	- mrHELPReliIndex		: index of most reliable bits 
%	- vrHELPBindedData		: the binded binary gait template 
% Output		:
%	- mbDebindTestingTempOU	: binary template in testing phase after extracting and debinding
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [mbDebindTestingTempOU mbRelBinTestCurU] = func_ReliableTestExtract(mrAllUserTest,vnLabels, iUser, cSystemParam, mrHELPReliIndex, vrHELPBindedData)
	%index of data in the cell 'cSystemParam'
		nTrainTempNoIdx =  1;		%No. of gait template for trainning	
		nTestTempNoIdx  =  2;	    %No. of gait template combined for each testing times 
		nCodeWordIdx	=  3;		%code word size
		nBasedBinValIdx =  5;       %index of 'vbBasedBinValue'
		nReal2BinValIdx	=  6;		%real value used for binarization
		nQuanBitNoIdx	=  7;		%index of 'nQuanBitNo'
		nGrayCodeIdx	=  8;		%1: use gray code, 0 donot use gray code
		nNoOfSubFeaIdx	=  9;		%number of sub-features that the original set of feature will be divided
        nProjMatrixIdx  =  10;      %Cell that contain the projection matrix for each 

	%test time
	nTestTimes = size(mrAllUserTest,1)/cSystemParam{nTestTempNoIdx};
	vnLabelsBin = [];			
	%EXTRACT BINARY TEMPLATE
	vnLabelBinary = [];
	mbBinTestCurU = [];
	for iTimes = 1 : nTestTimes
		%get training data of current user
		iStartPos = (iTimes - 1)* cSystemParam{nTestTempNoIdx} + 1;
		iEndPos = iStartPos + cSystemParam{nTestTempNoIdx} - 1;
		mrCurTimeTestData = mrAllUserTest(iStartPos:iEndPos,:);
        vnLabelsBin=[vnLabelsBin; vnLabels(iStartPos,:)];
		%extract binary template
		mbBinTemplate = func_Real2Bin(mrCurTimeTestData,cSystemParam{nReal2BinValIdx}, cSystemParam{nQuanBitNoIdx}, cSystemParam{nBasedBinValIdx});
        mbBinTestCurU = [mbBinTestCurU; mbBinTemplate];
	end
		
	%GET RELIABLE BINARY GAIT TEMPLATE FOR TESTING
	%reliable bit of testing
	mbRelBinTestCurU=[];
	for iTimes = 1 : nTestTimes
		%extract reliable bit 
		vbReliBinTest = func_GetReliableFeature(mbBinTestCurU(iTimes,:),mrHELPReliIndex, cSystemParam{nCodeWordIdx},cSystemParam{nQuanBitNoIdx});
		%update to data of all template 
		mbRelBinTestCurU = [mbRelBinTestCurU; vbReliBinTest];
	end
	%XOR WITH THE STORE DATA
    if(~isempty(vrHELPBindedData))
        mbDeBindTestCurU = [];
        for iTimes = 1 : nTestTimes
            %for each user, XOR the extracted binary template to stored reliable bit of current user to get codeword ()
            mbCalculatedCodeWord = xor(mbRelBinTestCurU(iTimes,:),vrHELPBindedData );
            mbDeBindTestCurU = [mbDeBindTestCurU; mbCalculatedCodeWord];
        end
    end
    
    vnCurUserLabel = ones(size(mbRelBinTestCurU,1),1)*iUser;
    
    %change label for LDA training
    vnAllUserLabelsTrain = vnLabelsBin;
    for iLabel = 1 : length(vnAllUserLabelsTrain)
    	if (vnAllUserLabelsTrain(iLabel) ~= iUser)
        	vnAllUserLabelsTrain(iLabel) = iUser+1;
        end
	end
	if(~isempty(vrHELPBindedData))
        mbDebindTestingTempOU = [mbDeBindTestCurU vnCurUserLabel vnAllUserLabelsTrain];
    else
        mbDebindTestingTempOU = [];
    end
    mbRelBinTestCurU = [mbRelBinTestCurU vnCurUserLabel vnAllUserLabelsTrain];
end