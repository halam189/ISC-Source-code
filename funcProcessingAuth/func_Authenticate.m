%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_Authenticate
% Process		: Authenticate user with input gait template and stored helping data (used in test phase)
% Input			:
%	- cSystemParam			: structure that contains all neccessary parameters to authenticate user
%	- mrTestGaitTemplate	: real value gait data template that used for testing
%	- mrHELPNormalizeRange	: help data: range from min-max for normalization
%	- mrHELPReliIndex		: index of most reliable bits 
%	- vrHELPBindedData		: the binded binary gait template 
%	- vbBCHKey				: the BCH key 
% Output		:
%	- nAccepResult			: number of successfully authenticated templates
%	- nRejectResult			: number of failed authentication templates
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [nAccepResult nRejectResult]= func_Authenticate(cSystemParam,mrTestGaitTemplate, mrHELPNormalizeRange, mrHELPReliIndex, vrHELPBindedData,vbBCHKey)
	nAccepResult = 0;
	nRejectResult = 0;
	%index of data in the cell 'cSystemParam'
		nTrainTempNoIdx =  1;		%No. of gait template for trainning	
		nTestTempNoIdx  =  2;	    %No. of gait template combined for each testing times 
		nCodeWordIdx	=  3;		%code word size
		nDimNoIdx       =  4;    	%No. of bits use for quantizing one real gait data
		nSplineRatioIdx =  5;  		%Spline interpolation ratio
		nCyclesNoIdx    =  6;       %No. of gait cycles in one gait template
		nTemplSizeIdx	=  7; 		%size of real value gait template
		nMeanMethodIdx  =  8;       %1 OR 2 (1: calculate means of all template, 2: calculate means of all gaits cycles of all templates)
		nBasedBinValIdx =  9;       %index of 'vbBasedBinValue'
		nReal2BinValIdx	= 10;		%real value used for binarization
		nQuanBitNoIdx	= 11;		%index of 'nQuanBitNo'
		nGrayCodeIdx	= 12;		%1: use gray code, 0 donot use gray code
   		nEigenVectorIdx = 13;		%index of eigen vector extract from trainning set
		nMeanVectorIdx	= 14;		%index of mean vector extract from training set
		
	%test time
	nTestTimes = size(mrTestGaitTemplate,1)/cSystemParam{nTestTempNoIdx};
				
	%NORMALIZE EACH USER TO A USER-SPECIFIC RANGE
		mrDataTestNormCurU = func_UserSpecificNormalize(mrTestGaitTemplate, mrHELPNormalizeRange, cSystemParam{nDimNoIdx}, cSystemParam{nMeanMethodIdx},cSystemParam{nCyclesNoIdx});
		mrTestGaitTemplate = mrDataTestNormCurU;
		
	%SPLINE INTERPOLATION AND EXTRACT GAIT DATA TEMPLATE
		mrRealDataExtrCurU = func_RealExtract(mrTestGaitTemplate,cSystemParam{nDimNoIdx},'spline',cSystemParam{nTemplSizeIdx});
	
%++++<MO0015>
        %APPLY PCA TO MAKE DATA MORE DISCRIMINATE
        meanMat = repmat(cSystemParam{nMeanVectorIdx},size(mrRealDataExtrCurU,1),1);
        featureMatTest = (mrRealDataExtrCurU - meanMat)*cSystemParam{nEigenVectorIdx};
        mrRealDataExtrCurU = featureMatTest;
%        nFeatureNo = size(mrRealDataExtrCurU,2);
%        [mrPCADataTrain,mrEigenVec,mrMeanVec] = eigenGait(mrRealDataExtrCurU,nFeatureNo);
 %       cSystemParam{nEigenVectorIdx} = mrEigenVec;
  %      cSystemParam{nMeanVectorIdx} = mrMeanVec;		
%----<MO0015>

	%EXTRACT BINARY TEMPLATE
		mbBinTestCurU = [];
		for iTimes = 1 : nTestTimes
			%get training data of current user
			iStartPos = (iTimes - 1)* cSystemParam{nTestTempNoIdx} + 1;
			iEndPos = iStartPos + cSystemParam{nTestTempNoIdx} - 1;
			mrCurTimeTestData = mrRealDataExtrCurU(iStartPos:iEndPos,:);
			%extract binary template
			mbBinTemplate = func_Real2Bin(mrCurTimeTestData,cSystemParam{nDimNoIdx},cSystemParam{nReal2BinValIdx}, cSystemParam{nQuanBitNoIdx}, cSystemParam{nBasedBinValIdx});
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
		mbDeBindTestCurU = [];
		for iTimes = 1 : nTestTimes
			%for each user, XOR the extracted binary template to stored reliable bit of current user to get codeword ()
			mbCalculatedCodeWord = xor(mbRelBinTestCurU(iTimes,:),vrHELPBindedData );
			
			%decode with BCH code
			vbDecodedKey = [];
			if      cSystemParam{nCodeWordIdx} == 127
				vbDecodedKey = func_BCHDecode(mbCalculatedCodeWord,127,64,10);
			elseif  cSystemParam{nCodeWordIdx} == 255
				vbDecodedKey = func_BCHDecode(mbCalculatedCodeWord,255,107,22);
			elseif  cSystemParam{nCodeWordIdx} == 511
				vbDecodedKey = func_BCHDecode(mbCalculatedCodeWord,511,250,31);
            end

			%compare to actual key
			nHammingDist = sum(abs(vbDecodedKey - vbBCHKey));
			if(nHammingDist == 0)
				nAccepResult = nAccepResult+1;
			else
				nRejectResult = nRejectResult+1;
			end
		end
end