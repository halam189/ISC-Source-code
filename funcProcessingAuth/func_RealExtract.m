%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_RealExtract
% Process		: Spline interpolation and real value extraction
% Input			:
%	- mrGaitData		: original gait data for all users, each 16 rows is data for one user 
%	- nDimensionsNo	: number of dimension, in this source code use 3 dimensions -->3
%	- strIntPolType		: Interpolation type (spline, linear, cubic...)
%	- nRealGaitDataSize	: Dimension size of output
%
% Output		:
%	- mrRealDataExtracted: real value gait data template after spline
%		interpolatioon and extraction. 
%
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mrRealDataExtracted] = func_RealExtract(mrGaitData, nDimensionsNo,strIntPolType,nRealGaitDataSize )
	mrRealDataExtracted = NaN(size(mrGaitData,1),nDimensionsNo*nRealGaitDataSize);  
	mrRealDataExtracted = [];
	for iRow = 1 : size(mrGaitData,1)
		% in each row (each gait template for one user )
		vrCurRow = mrGaitData(iRow,:);
		nOneDimLength = (length(vrCurRow)-1)/(nDimensionsNo+1);
		mrAllDimData = [];		% buffer contains gait data of all axises for one user 
		% extract components in each row, the last component is the time
		for iDim = 1 : (nDimensionsNo+1)
			nStartPos = (iDim-1)*nOneDimLength + 1;
			nEndPos = nStartPos+nOneDimLength - 1;
			vrOneDimData = vrCurRow(:,nStartPos:nEndPos);
			mrAllDimData=[mrAllDimData ; vrOneDimData];
		end
		%until this step, the 'mrAllDimData' is matrix contains gait data for each user, 'mrAllDimData' contains 4 rows, with first 3 rows: each row is gait data for one dimension, the last row of mrAllDimData is time gap
		
		% get time gap vector
		vrCurTime = mrAllDimData(end,:);
			
		
		%generate the equal linearly spaced vector for time -> time gap is equal
		vrEqualTimeArr = linspace(min(vrCurTime),max(vrCurTime),nRealGaitDataSize);
		mrIntpolAllDimData =[];			% matrix contains gait data of all axis after interpolation
		for iDim = 1:nDimensionsNo
			% for each dimensions
			%interpolation data of one axis
			mrIntpolOneDimData = interp1(vrCurTime,mrAllDimData(iDim,:),vrEqualTimeArr,strIntPolType);
			%copy to buffer contains data of all axises
			mrIntpolAllDimData = [mrIntpolAllDimData ;mrIntpolOneDimData];   
		end
		%transform from matrix to vector
		vrIntpolAllAxisData = reshape(mrIntpolAllDimData.',1,[]);

		%add user ID
%		vrIntpolAllAxisData = [vrIntpolAllAxisData vrCurRow(length(vrCurRow))];
		%update gait data after interpolation of user 'i' to result buffer
		mrRealDataExtracted = [mrRealDataExtracted ; vrIntpolAllAxisData];
	end		%end of processing data
end		%end of function define