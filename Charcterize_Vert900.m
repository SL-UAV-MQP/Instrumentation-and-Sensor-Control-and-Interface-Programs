 %%
    Rx_Power_Adj = zeros(size(Beampattern_Sweep_Array,1),2);
    Rx_Power_Adj(:,1) = Beampattern_Sweep_Array(:,1);
    
    for bsa = 1:size(Beampattern_Sweep_Array,1)
        Rx_Power_Adj(bsa, 2) = interp1(Rx_Power(:,1), Rx_Power(:,2), Beampattern_Sweep_Array(bsa,1)); 
    end

    Total_Loss = zeros(size(Beampattern_Sweep_Array,1),2);
    Total_Loss = Beampattern_Sweep_Array(:,1);
    Total_Loss(:,2) = Tx_Power - Rx_Power_Adj(:,2);

    %%

    
   %%
    Cable_1_Loss = zeros(size(Beampattern_Sweep_Array,1),2);
    Cable_1_Loss(:,1) = Beampattern_Sweep_Array(:,1);
    
    for bsa = 1:size(Beampattern_Sweep_Array,1)
        Cable_1_Loss(bsa, 2) = interp1(Cable_1_Sweep(:,1), Cable_1_Sweep(:,2), Beampattern_Sweep_Array(bsa,1)); 
    end

    Total_Loss(:,2) = Total_Loss(:,2) - Cable_1_Loss(:,2);
    %%
    Cable_2_Loss = zeros(size(Beampattern_Sweep_Array,1),2);
    Cable_2_Loss(:,1) = Beampattern_Sweep_Array(:,1);
    
    for bsa = 1:size(Beampattern_Sweep_Array,1)
        Cable_2_Loss(bsa, 2) = interp1(Cable_2_Sweep(:,1), Cable_2_Sweep(:,2), Beampattern_Sweep_Array(bsa,1)); 
    end

    Total_Loss(:,2) = Total_Loss(:,2) - Cable_2_Loss(:,2);
    %%
    Air_Loss_Reffrence = gaspl(1, Reffrence_Sweep(:,1), Temp, Preasure, Humidity_Density);

    Total_Loss(:,2) = Total_Loss(:,2) - Air_Loss_Reffrence(:,1);

    Reffrence_Loss = zeros(size(Beampattern_Sweep_Array,1),2);
    Reffrence_Loss(:,1) = Beampattern_Sweep_Array(:,1);
    
    for bsa = 1:size(Beampattern_Sweep_Array,1)
        Reffrence_Loss(bsa, 2) = interp1(Reffrence_Sweep(:,1), Reffrence_Sweep(:,2), Beampattern_Sweep_Array(bsa,1)); 
    end

    
    Total_Loss(:,2) = Total_Loss(:,2)/2;