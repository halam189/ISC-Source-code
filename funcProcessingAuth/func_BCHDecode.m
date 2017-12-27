%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function name	: func_BCHDecode
% Process		: Decode encoded key by BCH code
% Input			:
%	- mGaitData		: Gait data, is real value when calculating 'Euclidean' distance, and binary incase of 'Hamming'
%	- vnUserID		: vector contains list of user ID
%	- nGaitTempNo	: number of gait templates for each user in 'mGaitData'
%	- strType		: distance type 'Hamming' or 'Euclidean'
% Output		:
%	- mbDecodedKey	: decoded key by BCH code
%	- 
%		
% Notes			:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mbDecodedKey] = func_BCHDecode(mbEncodedKey, nCodeWordSize, nKeySize, nErrorCapa)	%decode_bch
	
	%mbEncodedKey has 'nCodeWordSize' bits
	
	%transform to Galois field
	mgEncodedKey = gf(mbEncodedKey(:,:),1);
	
	%decode with bch (result is in Galois field)
	mgDecodedKey = bchdec(mgEncodedKey(:,:),nCodeWordSize,nKeySize);
	
	%change to binary bit, 'mbDecodedKey' will have 'nKeySize' bits
	mbDecodedKey = double(mgDecodedKey.x);
end