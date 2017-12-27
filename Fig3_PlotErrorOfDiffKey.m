%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Program Descriptions - Plotting Figure 8a, 8b, 8c
%
%		This program is used to plot figure showing the error rate at difference key length
%
%	Original: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;


vnCodeWordSize	= [255 511];		%size of code word used for BCH code 	%127 %255 %511	n_dim

%load error saved in file
for iCodeWord = 1: size(vnCodeWordSize,2)
	%for each codeword size (255 and 511)
	nCodeWordSize = vnCodeWordSize(iCodeWord);
	strErrFile = strcat('_TempGaitData\\Result_all_keys_of_38_USERS_FREE_ORIENTATION_',num2str(nCodeWordSize));
	%load file
	mrErrRate = load(strErrFile);

	%get intra and inter error
	vrINTRAErr = mrErrRate(:,1)';
	vrINTERErr = mrErrRate(:,2)';
	
	%keysize
	vnKeyLen 		= [];
    usedKeyLen = 0;
	if nCodeWordSize == 255
        usedKeyLen1 = 91 ;
		vnKeyLen =  [247 239 231 223 215 207 199 191 187 179 171 163 155 147 139 131 123 115 107 99 91 87 79 71 63 55 47 45 37 29 21 13 9];
        vnErrCapacity = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 18 19 21 22 23 25 26 27 29 30 31 42 43 45 47 55 59 63];
	 elseif nCodeWordSize == 511 %511
        usedKeyLen1 = 166 ;
		vnKeyLen =  [502 493 484 475 466 457 448 439 430 421 412 403 394 385 376 367 358 349 340 331 322 313 304  295 286 277 268 259 250 241 238 229 220 211 202 193 184 175 166 157 148 139 130 121 112 103 94 85 76 67 58 49 40 31 28 19 10 ];
   		vnErrCapacity = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 19 20 21 22 23 25 26 27 28 29 30 31 36 37 38 39 41 42 43 45 46 47 51 53 54 55 58 59 61 62 63 85 87 91 93 95 109 111 119 121 ] ;
    end
	
    %plot figure
	hold on
        max = 202;
        min = 58;
        posmax=1;
        posmin=1;
        if(nCodeWordSize == 511)
            for (temp = 1 : length(vnKeyLen))
                if(vnKeyLen(temp)==max)
                    posmax = temp;
                    
                end
                if(vnKeyLen(temp)==min)
                    posmin = temp;
                    
                end
            end
            
            
            leng=length(vnKeyLen);
            vnKeyLen(posmin:leng)=[];
            vrINTRAErr(posmin:leng)=[];
            vrINTERErr(posmin:leng)=[];
            
            vnKeyLen(1:posmax)=[];
            vrINTRAErr(1:posmax)=[];
            vrINTERErr(1:posmax)=[];
            
        end
        
        max = 115;
        min = 9;
        posmax=1;
        if(nCodeWordSize == 255)
            for (temp = 1 : length(vnKeyLen))
                if(vnKeyLen(temp)==max)
                    posmax = temp;
                    
                end
                 if(vnKeyLen(temp)==min)
                    posmin = temp;
                    
                end
            end
            leng=length(vnKeyLen);
            vnKeyLen(posmin:leng)=[];
            vrINTRAErr(posmin:leng)=[];
            vrINTERErr(posmin:leng)=[];
            
            vnKeyLen(1:posmax)=[];
            vrINTRAErr(1:posmax)=[];
            vrINTERErr(1:posmax)=[];
            
            
        end
        
		vnKeyLen = fliplr(vnKeyLen);
        vrINTRAErr = fliplr(vrINTRAErr);
        vrINTERErr = fliplr(vrINTERErr);
        
		figure(iCodeWord);
		%plot intra error rate
        hold on
		plot(vnKeyLen,vrINTRAErr,'-o', 'color','b','LineWidth',1,'MarkerSize',10);
		%plot inter error rate
		hold on
        plot(vnKeyLen,vrINTERErr,'-*', 'color','r','LineWidth',1,'MarkerSize',10);

        %hold on
        %plot(vnKeyLen,0,'-o', 'color','m','LineWidth',2,'MarkerSize',2);
		%draw key length line
		%line([usedKeyLen usedKeyLen], get(gca, 'ylim'));        
        %x2 = usedKeyLen;
        FRR=0;
        FAR = 0;
        for(i = 1 : length(vnKeyLen))
            if (vnKeyLen(i) == usedKeyLen)
                FRR=vrINTRAErr(i)*100;
                FAR =vrINTERErr(i)*100;
                x2 = vnKeyLen(i-4);
                break;
            end
        end
        y1 = 0.2;
        y2 = 0.15;
        y3 = 0.1;
        strFRR = sprintf('%2.2f',FRR);
        strFAR = sprintf('%2.2f',FAR);
        txt2 = ['FRR: ',strFRR,'%'];
        txt3 = ['FAR: ',strFAR,'%'];
        txt1 = ['Key: ',num2str(usedKeyLen)];

		legend('FRR','FAR','Location','NorthWest');
		set(gca,'ylim',[-0.01 0.36]);
		set(gca,'xlim',[(vnKeyLen(1))-10 (vnKeyLen(size(vnKeyLen,2))+1)]);
		xlabel('Key size (bits)','FontSize',18);
		ylabel('Error Rate (%)','FontSize',18);
		
		strTitle = strcat('Error Rate At Different Key Lengths (Codeword size: ',...
			num2str(nCodeWordSize),')');
		%title(strTitle);
		set(gca,'FontSize',18);
	hold off
end