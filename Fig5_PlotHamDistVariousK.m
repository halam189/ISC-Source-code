
clear all;
% Add folder contains matlab functions
addpath('funcMatlab');
  
    %filename = strcat('_TempGaitData\\FEATURE_',num2str(1),'_USERS_ORIENTATION_2_NOFILT_full_random_09300930_EUCLI_ANALYLDA');
    mrHamDistanceIntra = load('_TempGaitData\\HAMMING_DISTANCE_OF_DIFFERENT_BIT_NUM_Intra')';
    mrHamDistanceInter = load('_TempGaitData\\HAMMING_DISTANCE_OF_DIFFERENT_BIT_NUM_Inter')';
    
    vmEuclideanDataAll = {mrHamDistanceIntra;mrHamDistanceInter};
    vrXStamp = linspace(2,5,size(mrHamDistanceIntra,2));  %% for euclidean case
%vrXStamp =[2 3 4 5];

        figure(300);
	
        %plot data in box-format
        aboxplot(vmEuclideanDataAll,'labels',[2 3 4 5],'OutlierMarker',...
            '+','OutlierMarkerEdgeColor','r','OutlierMarkerFaceColor',...
            'g','WidthL',1, 'Colormap',[0 0 1; 1 0 0],'colorboxedge',...'widths',2,...
            'r','outliermarkersize',4);

        %Set label
        set(gca,'XTick',[1 2 3 4] );
        set(gca,'XTickLabel',[2 3 4 5] );
        set(gca,'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6] );
        set(gca,'YTickLabel',[0 0.1 0.2 0.3 0.4 0.5 0.6] );
        
        xlabel('Number of bits for quantization');
        grid on
        ylabel('Normalized Hamming distance');
        legend('Intra-class','Inter-class','Location','NorthWest');