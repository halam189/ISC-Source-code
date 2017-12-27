%******************************************************************************************
%
%	History:
%		Calculate the eucledian distance before LDA projection
%
%******************************************************************************************
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
%separate the label and data
vnLabel = mrGaitDataAll(:,size(mrGaitDataAll,2));


%normalization to same scale
vrMinAll = min (mrGaitDataAll);
vrMaxAll = max (mrGaitDataAll);
mrTrainNorm = [];
mrTestNorm = [];
for iFeature = 1 : (size (mrGaitDataAll,2)-1)
	%cur feature of training data
	vrCurTrainFea= mrGaitDataAll(:,iFeature)';
	vrCurTrainFeaNorm = (vrCurTrainFea - vrMinAll(iFeature))./(vrMaxAll(iFeature) - vrMinAll(iFeature));
    mrTrainNorm = [mrTrainNorm vrCurTrainFeaNorm'];
end
mrTrainNorm = [mrTrainNorm vnLabel];

%calculate the Euclidean distance
[mrINTRADisTemp mrINTERDisTemp] = func_CalcuDistance(mrTrainNorm,vnLabel,'Euclidean');
rMaxValue = max(max(mrINTRADisTemp),max(mrINTERDisTemp));
mrINTRADisTemp = mrINTRADisTemp/rMaxValue;
mrINTERDisTemp = mrINTERDisTemp/rMaxValue;

%flot Euclidean distance
method = 'moving';
span = 10;
vrXStamp = linspace(0,1,30);
hFig = figure(50);

%create histogram bar chart
[intra_ham_hist] = hist(mrINTRADisTemp,vrXStamp);
[inter_ham_hist] = hist(mrINTERDisTemp,vrXStamp);
p1 = bar(vrXStamp,[intra_ham_hist/sum(intra_ham_hist);inter_ham_hist/sum(inter_ham_hist)]',2,'hist');

set(p1(1),'FaceColor',[0 0 1],'EdgeColor',[ 0 0 1]);
set(p1(2),'FaceColor',[1 0 0],'EdgeColor',[ 1 0 0]);
set(gca,'xlim',[0 1]);
set(gca,'xTick',0:0.25:1);
%strTitle = strcat('Normalized Euclidean Distance Before LDA Projecting');
%WWSStitle('Normalized Euclidean Distance Before LDA Projecting');
xlabel('Normalized Euclidean Distance','FontSize',18);
ylabel('Population (%)','FontSize',18);
legend('Intra-class','Inter-class','FontSize',18);
set(gca,'FontSize',18);