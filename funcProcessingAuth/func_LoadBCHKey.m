%******************************************************************************************
%
%	History:
%		2016:08:15	<MO0011>	Ha Lam	: 	Change testing method: donot assume that we know ID of user that current test template belong to
%
%******************************************************************************************

%*********************************************
%LOAD ENCODED KEY USED TO BIND WITH THE BINARY GAIT TEMPLATE
%
%	#FUNCTION	: 	func_LoadBCHKey
%	#Process	:	load raw key and encrypted key stored in file 
%					(this function can be replaced by generate raw key and encoded to encrypted key by BCH)
%	#Input		:	Path to data file that contains raw key and encoded key by BCH as described below:
%		File name: (<CODE_WORD_SIZE-c>,<RAW_KEY_SIZE-k>,<ERR_TOLERANCE-t>ekey) (but we can use any file name that we want)
%		Example: (511,139,54,34)eKey
%			- CODE_WORD_SIZE: size of code word using
%			- RAW_KEY_SIZE	: size of raw key
%			- ERR_TOLERANCE	: number of errors that BCH code can correct
%		File format:
%			- file contain N rows (N is number of users, in this paper is 34)
%			- each row has 3 information seperated by space
%				<User ID> <Raw key> <Encrypt key>
%				. User ID		: ID of user (from 1 to N)
%				. Raw key		: random raw key, has RAW_KEY_SIZE bits
%				. Encrypt key	: encription of Raw key by BCH code, has CODE_WORD_SIZE
%	#Output		:
%			- mbRawKey		: matrix has N rows, each row is raw key for one user writen in RAW_KEY_SIZE binary number
%			- mbEncKey		: matrix has N rows, each row is encrypted of raw key writen in CODE_WORD_SIZE binary number
%            
%	#Notes		:
%*********************************************
%function[raw_key enc_key] = func_LoadBCHKey(filename)
function[mbRawKey mbEncKey] = func_LoadBCHKey(sFileName)
	fFile = fopen(sFileName);
	msData = textscan(fFile,'%s%s%s','Delimiter', ' ');
	
	mbRawKey = cell2mat(msData{2})-'0';
	mbEncKey = cell2mat(msData{3})-'0';
end