
 warning('off','comm:obsolete:bchdec');
 warning('off', 'MATLAB:nearlySingularMatrix');

clc;
clear;
%******************************************************************************************
% INCLUDE SUB-FOLDER
%******************************************************************************************
addpath('funcProcessingAuth')	%folder contains main functions for processing gait data
addpath('funcMatlab')
%******************************************************************************************
%LOAD GAIT DATA FOR ALL USERS
%	#Notes		:	
%******************************************************************************************
mrGaitDataAll = load('_PreProcessedData\\38_USERS_FREE_ORIENTATION');

%******************************************************************************************
% DEFINE IMPORTANT PARAMETERS
%******************************************************************************************

%____________SYSTEM PARAMETERS____________
cSystemParam 	= {};		%cell contains system parameter that defined by some settings or calculated through training phase
	%index of data in the cell 'cSystemParam'
		nTrainTempNoIdx =  1;		%No. of gait template for trainning	
		nTestTempNoIdx  =  2;	    %No. of gait template combined for each testing times 
		nCodeWordIdx	=  3;		%code word size
		nBasedBinValIdx =  5;       %index of 'vbBasedBinValue'
		nReal2BinValIdx	=  6;		%real value used for binarization
		nQuanBitNoIdx	=  7;		%index of 'nQuanBitNo'
		nGrayCodeIdx	=  8;		%1: use gray code, 0 donot use gray code
		nNoOfSubFeaIdx	=  9;		%number of sub-features that the original set of feature will be divided
        nTrainOtherIdx  = 10;
	%initialize system parameter
		cSystemParam{nQuanBitNoIdx}		= 4; 
		cSystemParam{nGrayCodeIdx}		= 1;
		
vnCodeWordSize= [255 511];      %used codeword size

%____________USERS DATA____________
cAllUserData 	= {};		%cell contains processed data using in system
		%(<TRAINING-data> - <TESTING-data> - <HELPER NORMALIZE-RANGE> - <HELPER RELIABLE-INDEX> - <BINARY-TEMPLATE>)
	%index of data in the cell 'cAllUserData'
		nTrainDataIdx 	= 1;
		nTestDataIdx 	= 2;
		nReliableBitIdx	= 3;
		nRelBinTempIdx	= 4;
		nBindTempIdx	= 5;
		nBCHKeyIdx		= 6;
		nBCHCodeWordIdx = 7;
		nProjMatrixIdx  = 8;      %Cell that contain the projection matrix for each 
	
%******************************************************************************************
% DIVIDE THE LOADED DATA TO TWO PARTS: TRAINING AND TESTING
%	- read loaded matrix
%	- divide by users
%	- for each user, divide into two parts: TRAINING and TESTING
%	- store Training and Testing data to 1st and 2nd column of cell cAllUserData  
%******************************************************************************************

nAllUserDataLength = size(mrGaitDataAll, 1);



%BASED VALUE CALCULATING (devide the range 0 - 1 to 2^n - 1 sub-range )
mrBasedValue=func_BasedRangeCal(0, 1, cSystemParam{nQuanBitNoIdx});
cSystemParam{nReal2BinValIdx} = mrBasedValue;

%Determine binary strings for each rank
vnLevelNo = (0:((2^cSystemParam{nQuanBitNoIdx})-1));
if (cSystemParam{nGrayCodeIdx} == 1)
	cSystemParam{nBasedBinValIdx} = func_BinArrGenerating(cSystemParam{nQuanBitNoIdx});
else
	cSystemParam{nBasedBinValIdx} = de2bi(vnLevelNo,cSystemParam{nQuanBitNoIdx});
end

nUserNo = 38; 
for iCodeWord = 1 : length (vnCodeWordSize)
	%current codeword size
	cSystemParam{nCodeWordIdx} = vnCodeWordSize(iCodeWord); 
	
    cSystemParam{nTrainTempNoIdx}	= 100;
    cSystemParam{nTrainOtherIdx}    = 100;
	cSystemParam{nTestTempNoIdx}	= 12; 
	cSystemParam{nQuanBitNoIdx}		= 4; 
	cSystemParam{nGrayCodeIdx}		= 1;
	cSystemParam{nNoOfSubFeaIdx}	= 15;
        
    nSubFeatSize = floor((size(mrGaitDataAll,2)-1)/cSystemParam{nNoOfSubFeaIdx});
	
	%LOAD ENCODED KEY USED TO BIND WITH THE BINARY GAIT TEMPLATE
	%load BCH keys (various key length and error capacity)
	vnKeyLen 		= [];
	vnErrCapacity 	= [];
	if cSystemParam{nCodeWordIdx} == 255
		vnKeyLen =      [247    239 231 223 215 207 199 191 187 179 171 163 155 147 139 131 123 115 107 99 91 87 79 71 63 55 47 45 37 29 21 13 9];
		vnErrCapacity = [1      2   3   4   5   6   7   8   9   10  11  12  13  14  15  18  19  21  22  23 25 26 27 29 30 31 42 43 45 47 55 59 63];
    elseif cSystemParam{nCodeWordIdx} == 511 %511
		vnKeyLen =      [502 493 484  475   466 457 448 439 430 421 412 403 394 385 376 367 358 349 340 331 322 313 304 295 286 277 268 259 250 241 238 229 220 211 202 193 184 175 166 157 148 139 130 121 112 103 94 85 76 67 58 49 40 31  28  19  10 ];
		vnErrCapacity = [1   2   3    4     5   6   7   8   9   10  11  12  13  14  15  16  18  19  20  21  22  23  25  26  27  28  29  30  31  36  37  38  39  41  42  43  45  46  47  51  53  54  55  58  59  61  62 63 85 87 91 93 95 109 111 119 121 ] ;
    end
	%buffer contains the result
	mrINTRAError = [];
	mrINTERError = [];
	
	for iKeySize = 1 : length(vnKeyLen)
		%file name contains keys and codewords
		strKeyFile = strcat('_BCHKey\\',num2str(cSystemParam{nCodeWordIdx}),'\\',num2str(nUserNo),'U\\','(',num2str(cSystemParam{nCodeWordIdx}),','...
			,num2str(vnKeyLen(iKeySize)),',',num2str(vnErrCapacity(iKeySize)),',',num2str(nUserNo),')eKey');

		%load raw key and encoded key for current codeword of all users
		[mbRawKey mbEncKey] = func_LoadBCHKey(strKeyFile);
		for iUser = 1 : nUserNo
			cAllUserData{iUser, nBCHKeyIdx} = mbRawKey(iUser,:);
			cAllUserData{iUser, nBCHCodeWordIdx} = mbEncKey(iUser,:);
		end
	
		%Init statistical variables used to evaluate the performance of intra-class and interclass
		nResultTrueINTRA	= 0;
		nResultFalseINTRA	= 0;
		
		nResultTrueINTER	= 0;
		nResultFalseINTER	= 0;
			
		for iUser =  1 : nUserNo % *1*
			%with each user, train and test as authentication scheme
			cAllUserData 	= {};		%cell contains processed data using in system
			
			%divide data into training and testing
			
			[mrTrainData mrTestData] = func_DataDividing(mrGaitDataAll, iUser, cSystemParam{nTrainTempNoIdx}, cSystemParam{nTrainOtherIdx}, cSystemParam{nTestTempNoIdx});
			vnTrainLabels = mrTrainData(:,size(mrTrainData,2));
			for iLabel = 1 : length(vnTrainLabels)
				if vnTrainLabels(iLabel) ~=iUser
					vnTrainLabels(iLabel) = iUser + 1;
				end
			end
			mrTrainData(:,size(mrTrainData,2)) = [];
			
			vnTestLabels = mrTestData(:,size(mrTestData,2));
			mrTestData(:,size(mrTestData,2)) = [];
			
            %normalize training data
            %find min-max
            vrMinAll = min (mrTrainData);
            vrMaxAll = max (mrTrainData);
            mrTrainNorm = [];
            mrTestNorm = [];
            for iFeature = 1 : size (mrTrainData,2)
                %cur feature of training data
                vrCurTrainFea= mrTrainData(:,iFeature)';
                vrCurTrainFeaNorm = (vrCurTrainFea - vrMinAll(iFeature))./(vrMaxAll(iFeature) - vrMinAll(iFeature));
                mrTrainNorm = [mrTrainNorm vrCurTrainFeaNorm'];
            
                %cur feature of testing data
                vrCurTestFea= mrTestData(:,iFeature)';
                vrCurTestFeaNorm = (vrCurTestFea - vrMinAll(iFeature))./(vrMaxAll(iFeature) - vrMinAll(iFeature));
                mrTestNorm = [mrTestNorm vrCurTestFeaNorm'];
            end
            mrTrainData = mrTrainNorm;
            mrTestData = mrTestNorm;
            
			%apply LDA to training data set
			nCurSubFeaSize = nSubFeatSize;
			cProjectMatrix = {};
			mrLDATransFormAll = [];
			for iPart = 1 : cSystemParam{nNoOfSubFeaIdx}
				if(iPart == cSystemParam{nNoOfSubFeaIdx})
					nCurSubFeaSize = size(mrTrainData,2)-1 - nSubFeatSize*(cSystemParam{nNoOfSubFeaIdx} -1);
				end
				%get data of current sub features set
				iStartPos = (iPart-1)*nSubFeatSize + 1;
				iEndPos = iStartPos + nCurSubFeaSize - 1 ;
				mrCurSubFeatData = mrTrainData(:,iStartPos:iEndPos);
				%apply LDA to this sub features set
				nNewDimensionSize = nCurSubFeaSize - 1 ;
				mrCurSubFeatData = mrCurSubFeatData';
				[mrLDATrainTransformed, mrProjectMatrix] = lda(mrCurSubFeatData,vnTrainLabels,nNewDimensionSize);
				mrLDATransFormAll = [mrLDATransFormAll real(mrLDATrainTransformed')];
				cProjectMatrix{iPart} = real(mrProjectMatrix);
			end

			%using data after apply LDA for binarization
			mrLDATrainData = mrLDATransFormAll;
			
			%normalize all feature to range 0 -1 
			mrNormalizeTrainData = [];
			
			%min-max data also used as HELP data use in TESING phase
			vrMinData = min (mrLDATrainData);
			vrMaxData = max (mrLDATrainData);
			for iFeature = 1:size(mrLDATrainData ,2)
				vrCurFeatureData = mrLDATrainData (:,iFeature)';
				vrNormalizeCurFeat = (vrCurFeatureData - vrMinData(iFeature))./(vrMaxData(iFeature)-vrMinData(iFeature));
				mrNormalizeTrainData = [mrNormalizeTrainData vrNormalizeCurFeat']; 
			end
			
			%EXTRACT BINARY TEMPLATE
			mrCurUserTrain = [];
            mrOtherUserTrain = [];
			for iTemplate = 1 : size(mrNormalizeTrainData,1)
				if(vnTrainLabels(iTemplate) == iUser)
					mrCurUserTrain = [mrCurUserTrain; mrNormalizeTrainData(iTemplate,:)];
                else
                    mrOtherUserTrain =[mrOtherUserTrain; mrNormalizeTrainData(iTemplate,:)];
                end
			end
			mbBinTemplate = func_Real2Bin(mrCurUserTrain,cSystemParam{nReal2BinValIdx}, cSystemParam{nQuanBitNoIdx}, cSystemParam{nBasedBinValIdx});
			
			%CALCULATE RELIABILITY FOR CURRENT USER
            [vnReliIndex vrReliVal] = func_UserCalReliability(mrOtherUserTrain, mrCurUserTrain);
            
			
			%GET RELIABLE BINARY GAIT TEMPLATE FOR TRAINING
			vbReliBinTrain = func_GetReliableFeature(mbBinTemplate,vnReliIndex,cSystemParam{nCodeWordIdx},cSystemParam{nQuanBitNoIdx});
			
			%BIND (XOR) THE CODEWORD WITH TRAINING PART
			mbBindedBinTemp = xor(vbReliBinTrain,mbEncKey(iUser,:));
			
		%TESTING DATA PROCESSING
			%use testing data of all user
	
			mrLDAAllTest = [];
			nCurSubFeaSize = nSubFeatSize;
			for iPart = 1 : cSystemParam{nNoOfSubFeaIdx}
				if(iPart == cSystemParam{nNoOfSubFeaIdx})
					nCurSubFeaSize = size(mrTestData,2)-1 - nSubFeatSize*(cSystemParam{nNoOfSubFeaIdx} -1);
				end
				%get data of current sub features set
				iStartPos = (iPart-1)*nSubFeatSize + 1;
				iEndPos = iStartPos + nCurSubFeaSize - 1 ;
				mrCurSubFeatData = mrTestData(:,iStartPos:iEndPos);
				
				%get LDA projection matrix of current sub set
				mrProjectMatrix = cProjectMatrix{iPart};
				mrPCATestTemplate = mrProjectMatrix' * mrCurSubFeatData';
				mrLDAAllTest = [mrLDAAllTest real(mrPCATestTemplate')];
			end
			mrLDATestData = mrLDAAllTest;	
			
			%normalize all test data
			mrNormalizeAllUser = [];
			for iFeature = 1 : size(mrLDATestData,2)
				%calculate range to normalize
				mrCurFeature = mrLDATestData(:,iFeature)';
				%NORMALIZE training data set
				vrNormalizeOneFeaTest = (mrCurFeature - vrMinData(iFeature))./(vrMaxData(iFeature)-vrMinData(iFeature));
				%update column i
				mrNormalizeAllUser = [mrNormalizeAllUser vrNormalizeOneFeaTest'];
			end	
				
			%extract reliable bit template for all tested templates
			[mbDebindTestingTempAUs mbRelBinTestAll]= func_ReliableTestExtract(mrNormalizeAllUser,vnTestLabels, iUser, cSystemParam, vnReliIndex, mbBindedBinTemp);
			
			vnEnrollUser =  mbDebindTestingTempAUs(:, size(mbDebindTestingTempAUs, 2) - 1);
			vnAttempUser = mbDebindTestingTempAUs(:, size(mbDebindTestingTempAUs, 2));
			
			%decoding with BCH to get key
			%decode with BCH code
			mbDebindTestingTempAUs = mbDebindTestingTempAUs(:, 1:size(mbDebindTestingTempAUs, 2)-2);
			
			%decoding with BCH to get key
			mbDecodedKey = [];
			mbDecodedKey = func_BCHDecode(mbDebindTestingTempAUs,cSystemParam{nCodeWordIdx},vnKeyLen(iKeySize),vnErrCapacity(iKeySize));
			
			vnEnrolledKey = mbRawKey(iUser,:);
			for iCase = 1 : size (mbDecodedKey,1)
				nHammingDist = sum(abs(mbDecodedKey(iCase,:) - vnEnrolledKey));
				
				if(vnEnrollUser(iCase) == vnAttempUser(iCase))
					%intra class --> calculate false rejection error
					%compare to actual key
					if(nHammingDist == 0)
						nResultTrueINTRA = nResultTrueINTRA+1;
					else
						nResultFalseINTRA = nResultFalseINTRA+1;
					end 
				else
					%inter class --> calculate false acception errof
					if(nHammingDist == 0)
						nResultFalseINTER = nResultFalseINTER+1;
					else
						nResultTrueINTER = nResultTrueINTER+1;
					end 
				end
			end 
		end 	%end for iUser *1*
		nTotalINTRA = nResultTrueINTRA + nResultFalseINTRA;
		nTotalINTER = nResultFalseINTER + nResultTrueINTER;
		
		mrINTRAError = [mrINTRAError; nResultFalseINTRA/nTotalINTRA];
		mrINTERError = [mrINTERError; nResultFalseINTER/nTotalINTER];

		fprintf('+ CodeWord - Key : %d - %d\n',cSystemParam{nCodeWordIdx},vnKeyLen(iKeySize));
		fprintf('False Intra: %3.6f \nFalse Inter: %3.6f \n\n',nResultFalseINTRA/nTotalINTRA,nResultFalseINTER/nTotalINTER);

	end %end iKey
	
	%write to files	
	mrErrRate = [mrINTRAError mrINTERError]; 
	strErrFile = strcat('_TempGaitData\\Result_all_keys_of_38_USERS_FREE_ORIENTATION_',num2str(cSystemParam{nCodeWordIdx}));
	dlmwrite(strErrFile,mrErrRate);
end