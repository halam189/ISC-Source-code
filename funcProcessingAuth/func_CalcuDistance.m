%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_CalcuDistance
% Process		: Extract binary template gait data for both training and testing
% Input			:
%	- mGaitData		: Gait data, is real value when calculating 'Euclidean' distance, and binary incase of 'Hamming'
%	- vnUserID		: vector contains list of user ID
%	- nGaitTempNo	: number of gait templates for each user in 'mGaitData'
%	- strType		: distance type 'Hamming' or 'Euclidean'
% Output		:
%	- mrINTRADistance	: maxtrix contains HAMMING/EUCLIDEAN distance of intra-classes 
%	- mrINTERDistance	: maxtrix contains HAMMING/EUCLIDEAN distance of inter-classes
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mrINTRADistance mrINTERDistance] = func_CalcuDistance(mGaitData,vnUserID,strType)

	%for each class, calculate intra-class distance & interclass distance
	mrINTRADistance=[];
	mrINTERDistance=[];
	vnUserID = unique(vnUserID);
	
	nRowNo = size(mGaitData,1);
	nColumnNo = size(mGaitData,2);
	for iLabel=1:length(vnUserID)
		%for each user
		mrINTRAClass =[];
        mrINTERClass = [];
        for(iRow = 1 : nRowNo)
            if(mGaitData(iRow,nColumnNo) == iLabel)
                mrINTRAClass = [mrINTRAClass; mGaitData(iRow,:)];
            else
                mrINTERClass = [mrINTERClass; mGaitData(iRow,:)];
            end
        end
        mrINTRAClass(:,nColumnNo)=[];
        mrINTERClass(:,nColumnNo)=[];

		%calculate euclidean distance of intra-class & interclass
		%intraclass
		vrINTRADist = pdist(mrINTRAClass,strType); 
        mrINTRADistance = [mrINTRADistance vrINTRADist];
        
		%interclass
        vrINTERDist = pdist2(mrINTRAClass,mrINTERClass,strType);
        vrINTERDist = reshape(vrINTERDist.',1,[]);
        mrINTERDistance = [mrINTERDistance vrINTERDist];
	end 	
end