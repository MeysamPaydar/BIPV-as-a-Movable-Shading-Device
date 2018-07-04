CityName = 'Tehran'; 

WindowLength = [2];
ShadefirstAngle = [40,45,50,55,60,65,70,75,80,85,90]; % initial angle of the panel 

HeatingEfficiency = 3.2;  %Air conditioner-Heating mode (COP)
CoolingEfficiency = 2.8;  %Air conditioner-Cooling mode (EER)

infile = ['C:\....\' 'EnergyPlusFile.idf'];  %  EnergyPlus simulation file
outfile = ['C:\....\' 'EnergyPlusFile' num2str(2) '.idf']; % Edited EnergyPlus file


AnalyseResult = {'AnalyseNumber';'WindowLength';'ShadeFirstTiltAngle';'ShadeTiltAngle';'ShadePosition'; 'Heating';'January';'February';'March';'April';'May';'June';'July';'August';'September';'October';'November';'December';'Cooling';'January';'February';'March';'April';'May';'June';'July';'August';'September';'October';'November';'December';'PV';'January';'February';'March';'April';'May';'June';'July';'August';'September';'October';'November';'December'};
AnalyseNumber = 0; % Count analyse number


% Edit File
for C=1:length(WindowLength) % Window Length
    WinLength = WindowLength(C);

    for N=1:length(ShadefirstAngle) % Shade first Angle
        ShadefirstAng = ShadefirstAngle(N);
       
        
        for M=ShadefirstAng:-5:0 %Shade angle
            ShadeAngle = M;
            ShadeJontHeightfromWindow = sqrt(((sin(deg2rad(ShadefirstAng))).^2) - ((sin(deg2rad(M))).^2)) + cos(deg2rad(M)) - cos(deg2rad(ShadefirstAng));
            ShadeHangingHeightfromWindow = sqrt(((sin(deg2rad(ShadefirstAng))).^2) - ((sin(deg2rad(M))).^2)) - cos(deg2rad(ShadefirstAng));
            ShadeHangingYfromWindow = sin(deg2rad(M));
            
            ShadeJontZ = 2.5 + ShadeJontHeightfromWindow;
            ShadeHangingZ = 2.5 + ShadeHangingHeightfromWindow;
            ShadeHangingY = -1 * ShadeHangingYfromWindow;
            
            Window1X = 2.45 - (WinLength/2);
            Window2X = 6.55 - (WinLength/2);

              
            % Data changing detail in main file line 
            ChangeData(1) = struct('type','Window','name','South:Window:1','DataLine',9,'Number',WinLength);
            ChangeData(2) = struct('type','Window','name','South:Window:1','DataLine',7,'Number',Window1X);
            ChangeData(3) = struct('type','Window','name','South:Window:2','DataLine',9,'Number',WinLength);
            ChangeData(4) = struct('type','Window','name','South:Window:2','DataLine',7,'Number',Window2X);


            ChangeData(5) = struct('type','Shading:Site:Detailed','name','Overhang 1','DataLine',6,'Number',ShadeJontZ);
            ChangeData(6) = struct('type','Shading:Site:Detailed','name','Overhang 1','DataLine',8,'Number',ShadeHangingY);
            ChangeData(7) = struct('type','Shading:Site:Detailed','name','Overhang 1','DataLine',9,'Number',ShadeHangingZ);
            ChangeData(8) = struct('type','Shading:Site:Detailed','name','Overhang 1','DataLine',11,'Number',ShadeHangingY);
            ChangeData(9) = struct('type','Shading:Site:Detailed','name','Overhang 1','DataLine',12,'Number',ShadeHangingZ);
            ChangeData(10) = struct('type','Shading:Site:Detailed','name','Overhang 1','DataLine',15,'Number',ShadeJontZ);
            
            ChangeData(11) = struct('type','Shading:Site:Detailed','name','Overhang 2','DataLine',6,'Number',ShadeJontZ);
            ChangeData(12) = struct('type','Shading:Site:Detailed','name','Overhang 2','DataLine',8,'Number',ShadeHangingY);
            ChangeData(13) = struct('type','Shading:Site:Detailed','name','Overhang 2','DataLine',9,'Number',ShadeHangingZ);
            ChangeData(14) = struct('type','Shading:Site:Detailed','name','Overhang 2','DataLine',11,'Number',ShadeHangingY);
            ChangeData(15) = struct('type','Shading:Site:Detailed','name','Overhang 2','DataLine',12,'Number',ShadeHangingZ);
            ChangeData(16) = struct('type','Shading:Site:Detailed','name','Overhang 2','DataLine',15,'Number',ShadeJontZ);
            
 
            % Read idf file
            file = fopen(infile,'r');
            FileLines=[];
            while feof(file)==0
                FileLines{end+1}=fgetl(file); %Read line from file
            end
            fclose(file);

            NewFileLines = FileLines;

            % Edit lines
            for k=1:size(ChangeData,2)
                EditLine=[];
                wrongEditLine=[];
                n=length(FileLines);

                for i=1:n %Find edit lines
                    if strcmp(strtrim(FileLines{i}(1:end-1)),ChangeData(k).type)
                        EditLine(end+1)=i;
                    end
                end

                for j=1:length(EditLine) % Find wrong lines that selected
                    name = strsplit(FileLines{EditLine(j)+1},',');
                    if ~strcmp(strtrim(name(1)),ChangeData(k).name) 
                       wrongEditLine(end+1)=j;   
                   end                    
                end

                EditLine(wrongEditLine)=[]; %Delete wrong lines


                for i=1:length(EditLine) % Replace lines
                    ReplaceLine = EditLine(i) + ChangeData(k).DataLine; % line number in main file
                    if strfind(FileLines{ReplaceLine},';') % Find endstr
                       endstr = ';'; 
                    else
                       endstr = ',';
                    end
                    NewFileLines{ReplaceLine} = [num2str(ChangeData(k).Number) endstr]; % replace value    
                end
            
            end

            if exist(outfile,'file')
                delete(outfile)
            end

            % Write data in new file
            EditFile = fopen(outfile, 'w');
            for i=1:length(FileLines)
                fprintf(EditFile, '%s \r\n',NewFileLines{i});
            end
            fclose(EditFile);

            %Run EnergyPlus
            [out.status,out.output] = system(['C:\EnergyPlusV8-5-0\RunEPlus.bat ' 'EnergyPlusFile2' ',IRN_Tehran-Mehrabad.407540_ITMY']);

            % Import Results
            Result = importdata('C:\......\Results.csv');
            HeatingJanuary = Result.data(1,1)/HeatingEfficiency;
            HeatingFebruary = Result.data(2,1)/HeatingEfficiency;
            HeatingMarch = Result.data(3,1)/HeatingEfficiency;
            HeatingApril = Result.data(4,1)/HeatingEfficiency;
            HeatingMay = Result.data(5,1)/HeatingEfficiency;
            HeatingJune = Result.data(6,1)/HeatingEfficiency;
            HeatingJuly = Result.data(7,1)/HeatingEfficiency;
            HeatingAugust = Result.data(8,1)/HeatingEfficiency;
            HeatingSeptember = Result.data(9,1)/HeatingEfficiency;
            HeatingOctober = Result.data(10,1)/HeatingEfficiency;
            HeatingNovember = Result.data(11,1)/HeatingEfficiency;
            HeatingDecember = Result.data(12,1)/HeatingEfficiency;

            CoolingJanuary = Result.data(1,2)/CoolingEfficiency;
            CoolingFebruary = Result.data(2,2)/CoolingEfficiency;
            CoolingMarch = Result.data(3,2)/CoolingEfficiency;
            CoolingApril = Result.data(4,2)/CoolingEfficiency;
            CoolingMay = Result.data(5,2)/CoolingEfficiency;
            CoolingJune = Result.data(6,2)/CoolingEfficiency;
            CoolingJuly = Result.data(7,2)/CoolingEfficiency;
            CoolingAugust = Result.data(8,2)/CoolingEfficiency;
            CoolingSeptember = Result.data(9,2)/CoolingEfficiency;
            CoolingOctober = Result.data(10,2)/CoolingEfficiency;
            CoolingNovember = Result.data(11,2)/CoolingEfficiency;
            CoolingDecember = Result.data(12,2)/CoolingEfficiency;

            PVJanuary = Result.data(1,3);
            PVFebruary = Result.data(2,3);
            PVMarch = Result.data(3,3);
            PVApril = Result.data(4,3);
            PVMay = Result.data(5,3);
            PVJune = Result.data(6,3);
            PVJuly = Result.data(7,3);
            PVAugust = Result.data(8,3);
            PVSeptember = Result.data(9,3);
            PVOctober = Result.data(10,3);
            PVNovember = Result.data(11,3);
            PVDecember = Result.data(12,3);

            AnalyseNumber = AnalyseNumber+1; % Count analyse number 

            % Add data to matrix
            AnalyseResult{1,(AnalyseNumber+1)}= AnalyseNumber;
            AnalyseResult{2,(AnalyseNumber+1)}= WinLength;
            AnalyseResult{3,(AnalyseNumber+1)}= ShadefirstAng;
            AnalyseResult{4,(AnalyseNumber+1)}= ShadeAngle;
            AnalyseResult{5,(AnalyseNumber+1)}= ShadeHangingHeightfromWindow;
            AnalyseResult{6,(AnalyseNumber+1)}= '';

            AnalyseResult{7,(AnalyseNumber+1)}= HeatingJanuary;
            AnalyseResult{8,(AnalyseNumber+1)}= HeatingFebruary;
            AnalyseResult{9,(AnalyseNumber+1)}= HeatingMarch;
            AnalyseResult{10,(AnalyseNumber+1)}= HeatingApril;
            AnalyseResult{11,(AnalyseNumber+1)}= HeatingMay;
            AnalyseResult{12,(AnalyseNumber+1)}= HeatingJune;
            AnalyseResult{13,(AnalyseNumber+1)}= HeatingJuly;
            AnalyseResult{14,(AnalyseNumber+1)}= HeatingAugust;
            AnalyseResult{15,(AnalyseNumber+1)}= HeatingSeptember;
            AnalyseResult{16,(AnalyseNumber+1)}= HeatingOctober;
            AnalyseResult{17,(AnalyseNumber+1)}= HeatingNovember;
            AnalyseResult{18,(AnalyseNumber+1)}= HeatingDecember;

            AnalyseResult{19,(AnalyseNumber+1)}= '';
            AnalyseResult{20,(AnalyseNumber+1)}= CoolingJanuary;
            AnalyseResult{21,(AnalyseNumber+1)}= CoolingFebruary;
            AnalyseResult{22,(AnalyseNumber+1)}= CoolingMarch;
            AnalyseResult{23,(AnalyseNumber+1)}= CoolingApril;
            AnalyseResult{24,(AnalyseNumber+1)}= CoolingMay;
            AnalyseResult{25,(AnalyseNumber+1)}= CoolingJune;
            AnalyseResult{26,(AnalyseNumber+1)}= CoolingJuly;
            AnalyseResult{27,(AnalyseNumber+1)}= CoolingAugust;
            AnalyseResult{28,(AnalyseNumber+1)}= CoolingSeptember;
            AnalyseResult{29,(AnalyseNumber+1)}= CoolingOctober;
            AnalyseResult{30,(AnalyseNumber+1)}= CoolingNovember;
            AnalyseResult{31,(AnalyseNumber+1)}= CoolingDecember;

            AnalyseResult{32,(AnalyseNumber+1)}= '';
            AnalyseResult{33,(AnalyseNumber+1)}= PVJanuary;
            AnalyseResult{34,(AnalyseNumber+1)}= PVFebruary;
            AnalyseResult{35,(AnalyseNumber+1)}= PVMarch;
            AnalyseResult{36,(AnalyseNumber+1)}= PVApril;
            AnalyseResult{37,(AnalyseNumber+1)}= PVMay;
            AnalyseResult{38,(AnalyseNumber+1)}= PVJune;
            AnalyseResult{39,(AnalyseNumber+1)}= PVJuly;
            AnalyseResult{40,(AnalyseNumber+1)}= PVAugust;
            AnalyseResult{41,(AnalyseNumber+1)}= PVSeptember;
            AnalyseResult{42,(AnalyseNumber+1)}= PVOctober;
            AnalyseResult{43,(AnalyseNumber+1)}= PVNovember;
            AnalyseResult{44,(AnalyseNumber+1)}= PVDecember;

            AnalyseCount = length(WindowLength)*length(ShadefirstAngle)*13;
            disp(AnalyseCount);
            disp(AnalyseNumber);
        end
    end
end

 
 xlswrite(CityName, AnalyseResult); % Export Excel File


            


