%Grid_Zero_Opt
clear all;
clc;
tic
%% Implementation For Algorithm 1 %%

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

        %More Variables
        %Daily Energy Consumption
        Load_day = zeros(number_days,1);
        PV_day = zeros(number_days,1);
        Batt_day = zeros(number_days,1);
        Grid_Export_day = zeros(number_days,1);
        Grid_Import_day = zeros(number_days,1);

        for B = 1:1:number_days
        %Section for next day SOC
            if B == 1
             Power_Batt(1,B) = Batt_Capacity * 0.30; 
            elseif B > 1
             Power_Batt(1,B) = (End_SOC(B-1)/100) * Batt_Capacity;
            end 
            
            for I = 1:1:1440
                 %Should always be zero 
                  %Calculate Battery SOC 
                    SOC(I,B) = (Power_Batt(I,B)/Batt_Capacity)*100;
                    %% When PV is Not Present 
                    %% =======================================================================
                    if PV_d(I,B) == 0
                        %From midnight to when PV starts generating
                        %From when PV stops generating to Midnight
                        if SOC(I,B) > Lower_SOC %If the battery Charge is above min SOC 
                            if Load_d(I,B) <= Converter_Size
                            %Demand is entierly met by Battery
                               Grid_d(I,B) = 0; %set grid to zero
                               Batt_d(I,B) = -Load_d(I,B); %set Battery comsumption equal to load
                               Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60); %Power inside the battery
                            elseif Load_d(I,B)> Converter_Size
                            %Demand is met by Battery and Grid
                               Batt_d(I,B) = -1*Converter_Size;
                               Grid_d(I,B) = -1*(Load_d(I,B)+ Batt_d(I,B));  
                               Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                            end          
                        elseif SOC(I,B) <= Lower_SOC   
                            %Battery consumption will be zero
                            Batt_d(I,B) = 0;
                            %Grid will meet the requirements of the load
                            Grid_d(I,B) = -Load_d(I,B);
                            Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                            %Netter(I) = Load_d(I) + (Grid_d(I)+PV_d(I)+Batt_d(I));
                        end
                    %% =======================================================================
                    %% When PV is being generated    
                    elseif PV_d(I,B) < 0
                        if -PV_d(I,B)>Load_d(I,B)
                            if SOC(I,B) < Upper_SOC
                                Grid_d(I,B) = 0;
                                Batt_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Grid_d(I,B));
                                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                            elseif SOC(I,B) >Upper_SOC
                                Batt_d(I,B) = 0;
                                Grid_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Batt_d(I,B));
                                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                            end
                        elseif -PV_d(I,B) < Load_d(I,B)
                                if (Load_d(I,B)+PV_d(I,B)) > Converter_Size
                                    if SOC(I,B) > Lower_SOC
                                        Batt_d(I,B) = -Converter_Size;
                                        Grid_d(I,B) = -(Load_d(I,B) + (Batt_d(I,B) + PV_d(I,B)));
                                        Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                                    elseif SOC(I,B) < Lower_SOC
                                        Batt_d(I,B) = 0;
                                        Grid_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Batt_d(I,B));
                                        Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                                    end 
                                elseif (Load_d(I,B)+PV_d(I,B)) < Converter_Size
                                   if SOC(I,B) > Lower_SOC
                                       Grid_d(I,B) = 0; 
                                       Batt_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Grid_d(I,B));
                                       Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                                    elseif SOC(I,B) < Lower_SOC
                                        Batt_d(I,B) = 0;
                                        Grid_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Batt_d(I,B));
                                        Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                                    end 
                                end
                         end              
                    end
                Net_E(I,B) = Load_d(I,B) + (Grid_d(I,B)+PV_d(I,B)+Batt_d(I,B));
                if Grid_d(I,B) < 0 
                    Grid_Import(I,B) = Grid_d(I,B);
                    Grid_Export (I,B) = 0;
                elseif Grid_d(I,B) > 0 
                    Grid_Import(I,B) = 0;
                    Grid_Export(I,B) = Grid_d(I,B);
                end
            end 
          Net(B) = sum(Net_E(1:1440,B));
          End_SOC(B) = SOC(1440,B);
          PV_day (B) = ((sum(PV_d(1:1440,B))/1000)/60);
          Load_day (B) = ((sum(Load_d(1:1440,B))/1000)/60);
          Batt_day (B) = ((sum(Batt_d(1:1440,B))/1000)/60);
          Grid_Export_day (B) = ((sum(Grid_Export(1:1440,B))/1000)/60);
          Grid_Import_day (B) = ((sum(Grid_Import(1:1440,B))/1000)/60);

        end 
    % figure(f)
    % plot(1:1:number_days,Load_day * 0.18);
    % xlim([0 number_days])
    % hold on
    % plot(1:1:number_days,-Grid_Import_day*0.18);
    % title("House "+f+" Daily Costing");
    % xlabel("Time (Day)");
    % ylabel("Price per kWh (£)");
    % legend('With Out PV & Battery', 'With PV & Battery');
    %Write Battery Size and Converter Size, House name, both import costs, export cost , Cost Saving , ROI to
    %File
    Total_Net = sum(Net);
    Total_cost = (sum(Load_day) *0.18);
    Total_cost_with = sum(-Grid_Import_day)*0.18;
    Total_export = sum(Grid_Export_day)*0.05;
    fid = fopen([Batt_name+' Results.dat'],'a');
    fprintf(fid,'%f %f %f %f %f %f %f\n',f,Batt_Capacity,Converter_Size,Total_cost,Total_cost_with,Total_export,Total_Net);
    fclose(fid);

    cost_saving = Total_cost - Total_cost_with;
    total_annual_costing = cost_saving + Total_export;
    ROI = Batt_cost/total_annual_costing;

    fidsaving = fopen([Batt_name+' Savings.dat'],'a');
    fprintf(fid,'%f %f %f %f %f %f %f\n',f,Batt_Capacity,Converter_Size,Total_cost,cost_saving,total_annual_costing,ROI);
    fclose(fidsaving);

    end
end
toc