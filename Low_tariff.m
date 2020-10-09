%Script for low tariff
    %Check if PV is available
    if PV_d(I,B) == 0
        if SOC(I,B) < Overnight_SOC
            Batt_d(I,B) = Converter_Size; %Decide rate at which battery charges (Exponential rate)
            Grid_d(I,B) = -(Load_d(I,B) + Batt_d(I,B) + PV_d(I,B)); %Load demand will be met entirely by Grid
            Power_Batt(I+1,B) =  Power_Batt(I,B)+(Batt_d(I,B)/60);
        elseif SOC(I,B) >= Overnight_SOC
             
                Batt_d(I,B) = 0;
                Grid_d(I,B) = -(Load_d(I,B) +Batt_d(I,B)+ PV_d(I,B));
                Power_Batt(I+1,B) =  Power_Batt(I,B)+(Batt_d(I,B)/60);   %Add charging efficiency
        end        
    elseif PV_d(I,B)<0
        if -PV_d(I,B)>Load_d(I,B)
            if SOC(I,B) < Upper_SOC
                Grid_d(I,B) = 0;
                Batt_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Grid_d(I,B));
                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
            elseif SOC(I,B) > Upper_SOC
                Batt_d(I,B) = 0;
                Grid_d(I,B) = -(Load_d(I,B) + PV_d(I,B) + Batt_d(I,B));
                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
            end
        elseif -PV_d(I,B) < Load_d(I,B)
                Batt_d(I,B) = 0;
                Grid_d(I,B) = -(Load_d(I,B) + (Batt_d(I,B) + PV_d(I,B)));
                Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60); 
        end 
    end
    Net_E(I,B) = Load_d(I,B) + (Grid_d(I,B)+PV_d(I,B)+Batt_d(I,B));