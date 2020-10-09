% Cost-med
% Grid_cost during mid tariff band
if Grid_d(I) < 0
    Grid_cost_import(I) = (((Grid_d(I)/1000)/60)*0.119);
elseif Grid_d(I) > 0
    Grid_cost_export(I) = (((Grid_d(I)/1000)/60)*0.05);
end

Load_cost(I) = ((Load_d(I)/1000)/60) * 0.119;