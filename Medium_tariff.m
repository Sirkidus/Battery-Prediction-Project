%Script for medium Tariff
    if PV_d(I,B) == 0
        %From midnight to when PV starts generating
        %From when PV stops generating to Midnight
        if SOC(I,B) > Mid_tariff_SOC %If the battery Charge is above min SOC 
            if Load_d(I,B) < Converter_Size
            %Demand is entierly met by Battery
               Grid_d(I,B) = 0; %set grid to zero
               Batt_d(I,B) = -(Load_d(I,B)+Grid_d(I,B)); %set Battery comsumption equal to load
               Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60); %Power inside the battery
            elseif Load_d(I,B)>=Converter_Size
            %Demand is met by Battery and Grid
               Batt_d(I,B) = -1*Converter_Size;
               Grid_d(I,B) = -1*(Load_d(I,B)+ Batt_d(I,B));  
               Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
            end          
        elseif SOC(I,B) <  Mid_tariff_SOC 
            %Battery consumption will be zero
            Batt_d(I,B) = 0;
            %Grid will meet the requirements of the load
            Grid_d(I,B) = -(Load_d(I,B)+Batt_d(I,B));
            Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
        end
    %% =======================================================================
    %% When PV is being generated    
    elseif PV_d(I,B) < 0
        if -PV_d(I,B)>Load_d(I,B)
            if SOC(I,B) < Upper_SOC
                Grid_d(I,B) = 0;
                Batt_d(I,B) = -(Load_d(I,B) + Grid_d(I,B) + PV_d(I,B));
                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);                
            elseif SOC(I,B) > Upper_SOC
                Batt_d(I,B) = 0;
                Grid_d(I,B) = -(Load_d(I,B) + Batt_d(I,B) + PV_d(I,B));
                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
            end
        elseif -PV_d(I,B) < Load_d(I,B)
            if Load_d(I,B)+PV_d(I,B) > Converter_Size
                if SOC(I,B) >  Mid_tariff_SOC
                    Batt_d(I,B) = -Converter_Size;
                    Grid_d(I,B) = -(Load_d(I,B) + (Batt_d(I,B) + PV_d(I,B)));
                    Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                elseif SOC(I,B) <  Mid_tariff_SOC
                    Batt_d(I,B) = 0;
                    Grid_d(I,B) = -(Load_d(I,B) + PV_d(I,B));
                    Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
                end 
            elseif Load_d(I,B)+PV_d(I,B) < Converter_Size
               if SOC(I,B) >  Mid_tariff_SOC
                   Grid_d(I,B) = 0; 
                   Batt_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Grid_d(I,B));
                   Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);    
                elseif SOC(I,B) <  Mid_tariff_SOC
                    Batt_d(I,B) = 0;
                    Grid_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Batt_d(I,B));
                    Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60); 
                end 
            end
        end           
    end
    Net_E(I,B) = Load_d(I,B) + (Grid_d(I,B)+PV_d(I,B)+Batt_d(I,B));