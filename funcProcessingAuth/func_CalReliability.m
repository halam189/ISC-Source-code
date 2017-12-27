%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_CalReliability
% Process		: Calculate reliability for each position in gait template
% Input			:
%	- mrRealDataTrain		: real value gait data template used for training after spline interpolatioon
%	- nGaitTempNo			: number of gait templates for each user
% Output		:
%	- mnReliIndex			: index of bit 
%	- mnReliVal				: reliability value of bit specified in the index
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
function [mnReliIndex mnReliVal] = func_CalReliability(mrRealDataTrain,nGaitTempNo)

	%CALCULATE MEANS AND VARIANCES FOR EACH CLASS
	% matrix contains means of intra-class for all users, each rows is for one user
	mrMeansIntraAll = [];
	% matrix contains variance of for all users, each rows is for one user
	mrVariancesAll = [];
	
	nUserNo = size(mrRealDataTrain,1)/nGaitTempNo;
	for iUser = 1 : nUserNo
		% for each user
		
		% index of 1st row for training data of user i
		nStartRow = nGaitTempNo*(iUser-1)+1;
		nEndRow = nStartRow + nGaitTempNo - 1;
		mvDataTrainOneU = mrRealDataTrain((nStartRow:nEndRow),:);
	
		%calculate the mean feature vector of this class
		vrMeansIntraOne = mean(mvDataTrainOneU);
		mrMeansIntraAll = [mrMeansIntraAll; vrMeansIntraOne];
		
		vrVariancesOne = [];
		for iTemplate = 1 : size(mvDataTrainOneU,1)
			% calculate the variance of template iTemplate
			vrVariancesOne(iTemplate,:) = (mvDataTrainOneU(iTemplate,:) - vrMeansIntraOne).^2;
		end
		% calculate the variance for user iUser
		mrVariancesAll = [mrVariancesAll; sum(vrVariancesOne)./(size(vrVariancesOne,1)-1)];
	end
	
	%calculate means for all users
	vrMeansInter = mean(mrMeansIntraAll);
	
	%CALCULATE THE RELIABILITY FOR EACH CLASS
	mnReliValue = NaN(nUserNo,size(mrRealDataTrain,2));
	for i=1:nUserNo
	
		x = abs((mrMeansIntraAll(i,:) - vrMeansInter))./(sqrt(mrVariancesAll(i,:).*2));
		
        %x = abs(1)./(sqrt(mrVariancesAll(i,:).*2));
		%calculate the variance between other user to this user
		%vrMeanIntraCurUser = mrMeansIntraAll(i,:);
		%vrVarianceInterOne = [];
		%for j = 1: nUserNo
		%	if(i ~= j)
		%	vrMeanIntraOther = mrMeansIntraAll(j,:);
		%		vrVariance = (vrMeanIntraCurUser - vrMeanIntraOther).^2;
		%		vrVarianceInterOne = [vrVarianceInterOne; vrVariance];
		%	end
		%end
		%vrVarianceCurU = sum(vrVarianceInterOne)./size(vrVarianceInterOne,1);
		%x = sqrt(vrVarianceCurU)./(sqrt(mrVariancesAll(i,:).*2));

		[erf_x] = erf(x);
		erf_x = (erf_x+1)/2;
		mnReliValue(i,:) = erf_x;
	end
	[mnReliVal mnReliIndex] = sort(mnReliValue,2,'descend');
end