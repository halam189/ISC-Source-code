warning('off', 'MATLAB:nearlySingularMatrix'); 
warning('off','comm:obsolete:bchdec');
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
		cSystemParam{nTrainTempNoIdx}	= 100;
        cSystemParam{nTrainOtherIdx}    = 100;
		cSystemParam{nTestTempNoIdx}	= 12; 
		cSystemParam{nQuanBitNoIdx}		= 3; 
		cSystemParam{nGrayCodeIdx}		= 1;
		cSystemParam{nNoOfSubFeaIdx}	= 15;
		
vnCodeWordSize= [ 255 511];      %used codeword size

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

    	cSystemParam{nTrainTempNoIdx}	= 100;
        cSystemParam{nTrainOtherIdx}    = 100;
		cSystemParam{nTestTempNoIdx}	= 12; 
		cSystemParam{nQuanBitNoIdx}		= 3; 
		cSystemParam{nGrayCodeIdx}		= 1;
		cSystemParam{nNoOfSubFeaIdx}	= 15;
        
    nSubFeatSize = floor((size(mrGaitDataAll,2)-1)/cSystemParam{nNoOfSubFeaIdx});
	
	vnEucliIntra = [];
	vnEucliInter = [];
		
	for iUser =  1:38 % *1*
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
		%calculate the Euclidean distance for this user
        
        %change the labels
        mrIntraClass = [];
        mrNotIntraClass = [];
        for iItem = 1:length(vnTestLabels)
            if (vnTestLabels(iItem)==iUser)
                mrIntraClass = [mrIntraClass; mrNormalizeAllUser(iItem,:)];
            else
                mrNotIntraClass = [mrNotIntraClass; mrNormalizeAllUser(iItem,:)];
            end
        end
        %intra
        nTestTimes = size(mrIntraClass,1)/cSystemParam{nTestTempNoIdx};
        mrIntraClassMean = [];
        mrNotIntraClassMean = [];
        for iTimes = 1 : nTestTimes
            %get training data of current user
            iStartPos = (iTimes - 1)* cSystemParam{nTestTempNoIdx} + 1;
            iEndPos = iStartPos + cSystemParam{nTestTempNoIdx} - 1;
            
            mrCurTimeTestData = mrIntraClass(iStartPos:iEndPos,:);
            mrIntraClassMean = [mrIntraClassMean; mean(mrCurTimeTestData)];
%            vnLabelsBin=[vnLabelsBin; vnLabels(iStartPos,:)];
            %extract binary template
        end
        
        nTestTimes = size(mrNotIntraClass,1)/cSystemParam{nTestTempNoIdx};
        for iTimes = 1 : nTestTimes
            %get training data of current user
            iStartPos = (iTimes - 1)* cSystemParam{nTestTempNoIdx} + 1;
            iEndPos = iStartPos + cSystemParam{nTestTempNoIdx} - 1;
            
            mrCurTimeTestData = mrNotIntraClass(iStartPos:iEndPos,:);
            mrNotIntraClassMean = [mrNotIntraClassMean; mean(mrCurTimeTestData)];
%            vnLabelsBin=[vnLabelsBin; vnLabels(iStartPos,:)];
            %extract binary template
        end
        
        %intra dist
        vrINTRADist = pdist(mrIntraClassMean,'Euclidean');
        vnEucliIntra = [vnEucliIntra vrINTRADist];
        %interdist
        vrINTERDist = pdist2(mrIntraClassMean,mrNotIntraClassMean,'Euclidean');
        vrINTERDist = reshape(vrINTERDist.',1,[]);
        vnEucliInter = [vnEucliInter vrINTERDist];
        
    end
    rMaxValue = max(max(vnEucliIntra),max(vnEucliInter));
    mrINTRADisTemp = vnEucliIntra/rMaxValue;
    mrINTERDisTemp = vnEucliInter/rMaxValue;


	%	%plot Hamming distance of selected relibale bin feature
	method = 'moving';
    span = 10;
    vrXStamp = linspace(0,1,30);
	hFig = figure(1);
	
	%create histogram bar chart
	[intra_ham_hist] = hist(mrINTRADisTemp,vrXStamp);
	[inter_ham_hist] = hist(mrINTERDisTemp,vrXStamp);
	
	%smooth data
%	intra_ham_hist = smooth(intra_ham_hist,span,method)';
%	 inter_ham_hist = smooth (inter_ham_hist,span-3,method)';
	
	
	p1 = bar(vrXStamp,[intra_ham_hist/sum(intra_ham_hist);inter_ham_hist/sum(inter_ham_hist)]',2,'hist');
	
	set(p1(1),'FaceColor',[0 0 1],'EdgeColor',[ 0 0 1]);
	set(p1(2),'FaceColor',[1 0 0],'EdgeColor',[ 1 0 0]);
	set(gca,'xlim',[0 1]);
	set(gca,'xTick',0:0.25:1);
%	strTitle = strcat('Hamming Distance - Codeword = ');
%	title('Normalized Euclidean Distance After LDA Projecting');
	xlabel('Normalized Euclidean Distance','FontSize',18);
	ylabel('Population (%)','FontSize',18);
	legend('Intra-class','Inter-class','FontSize',18);
    set(gca,'FontSize',18);
%calculate the max value of distribution of intra-hist
  nIntraMax = 1;
  nInterMin = length(inter_ham_hist);
  total = 0;
  for i = 1 : length(intra_ham_hist)
      if(intra_ham_hist(i)~= 0)
          nIntraMax = i;
      end
      total = total + intra_ham_hist(i);
  end
  for i = 1 : length(inter_ham_hist)
      if(inter_ham_hist(i)~= 0)
          nInterMin = i;
          break;
      end
  end
  for i= 1 : length(inter_ham_hist)
      total = total + inter_ham_hist(i);
  end
  
  %calculate the overlap area
  sum = 0;
  for i = nInterMin: nIntraMax
     sum = sum +  inter_ham_hist(i)+ intra_ham_hist(i);
  end
  percent = sum *1.0 /total;
fprintf('Overlapped area: %3.6f \n',percent);