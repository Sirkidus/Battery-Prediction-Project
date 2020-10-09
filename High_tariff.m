%Script for high tariff
if PV_d(I,B) == 0
% disp("PV is Absent");
    if SOC(I,B) > Lower_SOC %If the battery Charge is above min SOC 
        if Load_d(I,B) <= Converter_Size
           Grid_d(I,B) = 0; %set grid to zero
           Batt_d(I,B) = -(Load_d(I,B) +Grid_d(I,B) + PV_d(I,B)); %set Battery comsumption equal to load
           Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60); %Power inside the battery
        elseif Load_d(I,B) > Converter_Size
           Batt_d(I,B) = -Converter_Size;
           Grid_d(I,B) = -(Load_d(I,B)+ Batt_d(I,B) + PV_d(I,B));  
           Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
        end          
    elseif SOC(I,B) <= Lower_SOC   
        Batt_d(I,B) = 0;
        Grid_d(I,B) = -(Load_d(I,B) + ((Batt_d(I,B) + PV_d(I,B))));
        Power_Batt(I+1,B) = Power_Batt(I,B) + (Batt_d(I,B)/60);
    end
    
    
elseif PV_d(I,B) < 0
%     disp("PV is present");
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