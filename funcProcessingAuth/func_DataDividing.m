%******************************************************************************************
%
%	History:
%		2016:08:31	<MO0018>	Ha Lam	: 	Divide the dimensions of data to n sub data that has smaller dimensions and apply LDA before binarization
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_DataDividing
% Process		: Receive the input as data of all user, divide the data into two set for training and testing 
% Input			:
%	- mrGaitDataAll			: 
%	- nUserID				: 
%	- nTrainTempNo			: 
%	- nTestTempNo			: 
% Output		:
%	- mrTrainData			: 
%	- mrTestData			: 
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [mrTrainData mrTestData] = func_DataDividing(mrGaitDataAll, nUserID, nTrainTempNo,nTrainOther, nTestTempNo)
	%temporary variables 
	nCurUserID = 1;
	nStartIndex = 1;
	nEndIndex = 1;	
	
	mrTrainData = [];
	mrTestData = [];
    nAllUserDataLength = size(mrGaitDataAll,1);
	%divide data into training and testing part
	for iRow = 1 : nAllUserDataLength
		vrCurData = mrGaitDataAll(iRow,:);	
		nCurDataUserID = vrCurData(length(vrCurData));
		
		if ((nCurDataUserID ~= nCurUserID)||(iRow == nAllUserDataLength))
		
			%update end index
			if(iRow == nAllUserDataLength)
				nEndIndex = iRow;
			else
				nEndIndex = iRow-1;
			end
			%new user data, perform extracting
			mrCurUserDataAll = mrGaitDataAll(nStartIndex:nEndIndex,:);
			%update start index for next user
			nStartIndex = iRow;
			
			%divide data into two parts: training and testing
			%mrCurUserDataAll = func_RandomArrange(mrCurUserDataAll);
			mrCurUserDataTest = [];
			if(nCurUserID == nUserID)
				%get training 
				mrCurUserDataTrain = mrCurUserDataAll(1:nTrainTempNo, :);
				mrTrainData = [mrTrainData; mrCurUserDataTrain];
                
                %mrMaskTemp = ones(size(mrCurUserDataTrain,1),size(mrCurUserDataTrain,2));
                %mrMaskTemp(:,size(mrCurUserDataTrain,2))= nUserID+ 1;
                %mrTrainData = [mrTrainData; mrMaskTemp];
				%get testing data
				mrCurUserDataTest = mrCurUserDataAll((nTrainTempNo + 1):size(mrCurUserDataAll,1), :);
			else
				%get training 
				mrCurUserDataTrain = mrCurUserDataAll(1:nTrainOther, :);
				mrTrainData = [mrTrainData; mrCurUserDataTrain];
				%get testing data
				mrCurUserDataTest = mrCurUserDataAll((nTrainOther + 1):size(mrCurUserDataAll,1), :);
            end
            
			%number of test template for current user
			nCurUserTempNo =  size(mrCurUserDataTest,1);
			%calculate the possible testing time
			nTestTimes = fix (nCurUserTempNo/nTestTempNo);
			%remove the test template that is not used
			if(nTestTimes*nTestTempNo < nCurUserTempNo)
				mrCurUserDataTest((nTestTimes*nTestTempNo+1):nCurUserTempNo, :) = [];
			end
			mrTestData = [mrTestData; mrCurUserDataTest];
			%update next user id 
			nCurUserID = nCurDataUserID;
		end
	end
end