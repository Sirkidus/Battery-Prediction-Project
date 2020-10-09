%Grid_Zero_Opt
clear all;
clc;
tic
%Year that the data was recorded (Change Accordingly)
Year = 2008;
%Create reference time and date values to be filled later
t1 = datetime(Year,1,1,0,0,0);
t2 = datetime(Year,12,31,23,59,0);
t = t1:t2;
t = t1:caldays(1):t2; %(Per day step size)
t = t1:hours(1/60):t2; % Per Minute Step
[numRows,numCols] = size(t);

number_mins = numCols;
number_days = ((number_mins/60)/24);

date_time = timetable(reshape(t,numCols,1));
%Read in data and reshape the Matrices to 1440x366
  for Batt = 1:1:13
    Batt_select
    for f = 1:1:20
         if f<10
            name = "meter_0"+f+"_year_2008.csv";
          elseif f >= 10
            name = "meter_"+f+"_year_2008.csv";
         end
        extract_data = timetable2table(synchronize(retime(table2timetable(readtable(name)),'minutely','fillwithconstant'),date_time,'minutely','fillwithconstant'));
        extract_PV = readtable('PV_Data.csv');
        PV_d = (extract_PV{2:1441,2:number_days+1})*-0.08;
        Load_d = reshape((extract_data{:,2})*1000,1440,number_days);
        %Variables
        %% Step 1 (Variable Initialisation)
        % Choose Size of Battery and Converter Size
    %     Batt_Capacity = 13500;
    %     Converter_Size = 5000; %Increased Converter Sizing
    %     Batt = 4;
    %     Batt_select
        % Initialise Capacity to 30% of Full Charge
        Power_Batt = zeros(1440,number_days);
        Batt_d = zeros(1440,number_days);
        SOC = zeros(1440,number_days);
        End_SOC = zeros(number_days,1);
        Upper_SOC = 90;
        Lower_SOC = 20;
        % Intialise varaible for Grid Energy
        Grid_d = zeros(1440,number_days);
        Grid_cost_import = zeros(1440,number_days);
        Grid_cost_export = zeros(1440,number_days);
        Grid_Import =  zeros(1440,number_days);
        Grid_Export  = zeros(1440,number_days);
        Load_cost = zeros(1440,number_days);
        %More Variables
        %Daily Energy Consumption
        Load_day = zeros(number_days,1);
        PV_day = zeros(number_days,1);
        Batt_day = zeros(number_days,1);
        Grid_Export_day = zeros(number_days,1);
        Grid_Import_day = zeros(number_days,1);
        Load_Costing = zeros(number_days,1);
        for B = 1:1:number_days
        %Section for next day SOC
            if B == 1
             Power_Batt(1,B) = Batt_Capacity * 0.30; 
            elseif B > 1
             Power_Batt(1,B) = (End_SOC(B-1)/100) * Batt_Capacity;
            end 
            %Overnight Charging Selection 
%           Overnight_SOC = 20;
            if B <= 79
                Overnight_SOC = 70;
                Season_name = "Winter";
            elseif B>79 && B <=172
                Overnight_SOC = 30;
                Season_name = "Spring";
            elseif B>172 && B <=265
                 Overnight_SOC = 20;
                Season_name = "Summer";
            elseif B>265 && B <=355
                 Overnight_SOC = 55;
                Season_name = "Autmn";
            elseif B>355 && B <=number_days
                 Overnight_SOC = 70;
                Season_name = "Winter";
            end    
            for I = 1:1:1440
                 %Should always be zero 
                  %Calculate Battery SOC 
                    SOC(I,B) = (Power_Batt(I,B)/Batt_Capacity)*100;
                    %disp("=======================================");
                    if I < 360 %(To 05:59)
                        %disp("Low Tariff Band");
                        Low_tariff
                        if Grid_d(I,B) < 0
                            Grid_cost_import(I,B) = (((Grid_d(I,B)/1000)/60)*0.049);
                        elseif Grid_d(I,B) > 0
                            Grid_cost_export(I,B) = (((Grid_d(I,B)/1000)/60)*0.05);
                        end
                        Load_cost(I,B) = ((Load_d(I,B)/1000)/60) * 0.049;
                        
                    end 
                    %==========================================================
                    if I > 359 && I<960 %(From 06:00 to 15:59)
                %         disp("Mid Tariff Band");
                        Mid_tariff_SOC = 40;
                        Medium_tariff
                        
                        %Medium tariff Costing Analysis
                        %==================================================
                        if Grid_d(I,B) < 0
                            Grid_cost_import(I,B) = (((Grid_d(I,B)/1000)/60)*0.119);
                        elseif Grid_d(I,B) > 0
                            Grid_cost_export(I,B) = (((Grid_d(I,B)/1000)/60)*0.05);
                        end
                        Load_cost(I,B) = ((Load_d(I,B)/1000)/60) *0.119;
                        %==================================================
                    end 
                    %=========================================================
                    if I > 959 && I<1140 %(From 16:00 to 18:59)
                %         disp("High Tariff Band"); 
                        High_tariff
                        %High tariff Costing Analysis
                        %==================================================
                        if Grid_d(I,B) < 0
                            Grid_cost_import(I,B) = (((Grid_d(I,B)/1000)/60)*0.199);
                        elseif Grid_d(I,B) > 0
                            Grid_cost_export(I,B) = (((Grid_d(I,B)/1000)/60)*0.05);
                        end
                        Load_cost(I,B) = ((Load_d(I,B)/1000)/60) * 0.199;
                        %==================================================
                    end 
                    %=========================================================
                    if I > 1139 && I<1380 %(From 19:00 to 22:59)
                %         disp("Mid Tariff Band"); 
                        Mid_tariff_SOC = 20;
                        Medium_tariff
                        %Medium tariff Costing Analysis
                        %==================================================
                        if Grid_d(I,B) < 0
                            Grid_cost_import(I,B) = (((Grid_d(I,B)/1000)/60)*0.119);
                        elseif Grid_d(I,B) > 0
                            Grid_cost_export(I,B) = (((Grid_d(I,B)/1000)/60)*0.05);
                        end
                        Load_cost(I,B) = ((Load_d(I,B)/1000)/60) *0.119;
                        %==================================================
                    end 
                    %=========================================================
                    if I > 1379 %(From 23:00 to 23:59)
                %         disp("low Tariff");
                        Low_tariff
                        %Low tariff Costing Analysis
                        %==================================================
                        if Grid_d(I,B) < 0
                            Grid_cost_import(I,B) = (((Grid_d(I,B)/1000)/60)*0.049);
                        elseif Grid_d(I,B) > 0
                            Grid_cost_export(I,B) = (((Grid_d(I,B)/1000)/60)*0.05);
                        end
                        Load_cost(I,B) = ((Load_d(I,B)/1000)/60) * 0.049;
                        %==================================================
                    end
                    %==========================================================    
                    
            end 
          Net(B) = sum(Net_E(1:1440,B));
          End_SOC(B) = SOC(1440,B); % End of the Day SOC
          PV_day (B) = ((sum(PV_d(1:1440,B))/1000)/60); %Total PV production for one day in kWh
          Load_day (B) = ((sum(Load_d(1:1440,B))/1000)/60); %Total Load Demand for one day in kWh
          Batt_day (B) = ((sum(Batt_d(1:1440,B))/1000)/60); %Total Battery Usage for one day

       Load_Costing (B) = sum(Load_cost(1:1440,B));        
       Grid_Export_day (B) = sum(Grid_cost_export(1:1440,B));
       Grid_Import_day (B) = sum(Grid_cost_import(1:1440,B));
          
        end 
        
%     figure(f)
%     plot(1:1:number_days,Load_Costing );
%     xlim([0 number_days])
%     hold on
%     plot(1:1:number_days,-Grid_Import_day);
%     title("House "+f+" Daily Costing");
%     xlabel("Time (Day)");
%     ylabel("Price per kWh (£)");
%     legend('With Out PV & Battery', 'With PV & Battery');

    %Write Battery Size and Converter Size, House name, both import costs, export cost , Cost Saving , ROI to
    %File
    Total_Net = sum(Net);
    Total_cost = (sum(Load_Costing) );
    Total_cost_with = sum(-Grid_Import_day);
    Total_export = sum(Grid_Export_day);
    fid = fopen([Batt_name+' Results.dat'],'a');
    fprintf(fid,'%f %f %f %f %f %f %f %f\n',f,Batt_Capacity,Converter_Size,Overnight_SOC,Total_cost,Total_cost_with,Total_export,Total_Net);
    fclose(fid);

    cost_saving = Total_cost - Total_cost_with;
    total_annual_costing = cost_saving + Total_export;
    ROI = Batt_cost/total_annual_costing;
    
    fidsaving = fopen([Batt_name+' Savings.dat'],'a');
    %fprintf(fid,'%f %f %f %f %f \n',f,Batt_Capacity,Converter_Size,cost_saving,total_annual_costing);
   fprintf(fid,'%f %f %f %f %f %f\n',f,Batt_Capacity,Converter_Size,cost_saving,total_annual_costing,ROI);
    fclose(fidsaving);
    end
 end
toc