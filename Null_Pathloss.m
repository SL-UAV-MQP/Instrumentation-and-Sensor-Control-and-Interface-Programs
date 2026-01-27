function [Nulled_Beampattern_Sweep_Array] = Null_Pathloss(Tx_Power, Rx_Power, Beampattern_Sweep_Array, Cable_1_Sweep, Cable_2_Sweep, Reffrence_Sweep, Path_Length, Temp, Preasure, Humidity_Density)

    Rx_Power_Adj = zeros(size(Beampattern_Sweep_Array,1),2);
    Rx_Power_Adj(:,1) = Beampattern_Sweep_Array(:,1);
    
    for bsa = 1:size(Beampattern_Sweep_Array,1)
        Rx_Power_Adj(bsa, 2) = interp1(Rx_Power(:,1), Rx_Power(:,2), Beampattern_Sweep_Array(bsa,1)); 
    end
    
    Total_Loss = zeros(size(Beampattern_Sweep_Array,1),2);
    Total_Loss = Beampattern_Sweep_Array(:,1);
    Total_Loss(:,2) = Tx_Power - Rx_Power_Adj(:,2);

   Air_Loss_Test = gaspl(Path_Length, Beampattern_Sweep_Array(:,1), Temp, Preasure, Humidity_Density);
    Total_Loss(:,2) = Total_Loss(:,2) - Air_Loss_Test(:,1);
end