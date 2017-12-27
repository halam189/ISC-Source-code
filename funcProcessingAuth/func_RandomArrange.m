%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_RandomArrange
% Process		: For a given gait template of one user, randomly re-arrange its order to divide into two sub-set: training and testing
% Input			:
%	- mrGaitData			: original gait data for all users, each 16 rows is data for one user 
%
% Output		:
%	- mrArrangedGaitData	: based value for binary gait template extraction, each dimension (X, Y, Z) has its own range
%
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mrArrangedGaitData=func_RandomArrange(mrGaitData)
	mrArrangedGaitData = [];
	
	nTemplatesNo = size(mrGaitData,1);
    %generate random number to get random template
	vnRandArr = randperm(nTemplatesNo,nTemplatesNo);
	
	for iRow = 1 : nTemplatesNo
		mrArrangedGaitData = [mrArrangedGaitData; mrGaitData(vnRandArr(iRow),:)];
	end
end		%end of function define