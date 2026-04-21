clc; clear; close all;

Element = input("Which element is being filtered?\n", "s");
Run_Number = input("Which run file is being used?\n");

Target_Element = sprintf("Device_Sweep/Componant_Sweep_%s_Full_Run_%d.mat", Element, Run_Number);
load(Target_Element);

disp("Executing Processing...")

PreClean_Componant_Sweep_Storage = Componant_Sweep_Storage(2:end,:);
    %preform first clean up routine
    %find local maxima in the beampatern data, these roughly ,match the
    %points we care about, but also some low power noise in the vallys
    %between the spectrum points
Local_Max_Matrix_Logical = islocalmax(PreClean_Componant_Sweep_Storage(:,2));
    %Logical AND the logical local maxima matrix with the frequency
    %points and write them to their own row matrix in the
Componant_Sweep_Storage_Clean1(1,:) = PreClean_Componant_Sweep_Storage(Local_Max_Matrix_Logical, 1);
    %Logical AND the logical local maxima matrix with the magnitude
    %points and write them to their own row matrix in the
Componant_Sweep_Storage_Clean1(2,:) = PreClean_Componant_Sweep_Storage(Local_Max_Matrix_Logical, 2);

Componant_Sweep_Storage_Clean1a = Componant_Sweep_Storage_Clean1;
Trip_Point = 0.27;
Overton_Window = 0.3;
Mean_Diff_Point = 0.07;
compensation_bands = 2;


while(compensation_bands < (size(Componant_Sweep_Storage_Clean1a,2)-1))
    Trip_IN = (Componant_Sweep_Storage_Clean1a(2,compensation_bands) - Componant_Sweep_Storage_Clean1a(2,compensation_bands-1));
    if(((Trip_IN > Trip_Point ) && (Trip_IN < Trip_Point+Overton_Window)))
        
        fprintf("Trip At %f\n", Componant_Sweep_Storage_Clean1a(1,compensation_bands));
        Offset = Componant_Sweep_Storage_Clean1a(2,compensation_bands) - Componant_Sweep_Storage_Clean1a(2,compensation_bands-1);
        
        
        Mean_Rev_Level_Storage = zeros(1,10);
        for mean_lvl = 1:size(Mean_Rev_Level_Storage,2)
            Mean_Rev_Level_Storage(1,mean_lvl) = Componant_Sweep_Storage_Clean1a(2,compensation_bands-mean_lvl);
        end

        Mean_Rev_Level = median(Mean_Rev_Level_Storage);

        if((size(Componant_Sweep_Storage_Clean1a,2) - compensation_bands) < 10)
            Mean_Fwrd_Level_Storage = zeros(1,(size(Componant_Sweep_Storage_Clean1a,2) - compensation_bands));
        else
            Mean_Fwrd_Level_Storage = zeros(1,10);
        end
        for mean_lvl = 1:size(Mean_Fwrd_Level_Storage,2)
            Mean_Fwrd_Level_Storage(1,mean_lvl) = Componant_Sweep_Storage_Clean1a(2,compensation_bands+mean_lvl);
        end

        Mean_Fwrd_Level = mean(Mean_Fwrd_Level_Storage);

        Mean_Diff = Mean_Fwrd_Level- Mean_Rev_Level;

        Offset_Width = 1;

        fprintf("Freq: %f, Mean Diff Lvl: %f, Rising Edge Dection Validation value: %f\n",(Componant_Sweep_Storage_Clean1a(1,compensation_bands+Offset_Width)),  Mean_Diff, (Componant_Sweep_Storage_Clean1a(2,compensation_bands) - Componant_Sweep_Storage_Clean1a(2,compensation_bands-1)));

        if(Mean_Diff > Mean_Diff_Point)
            Trip_OUT = (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width-1) - (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width)));
            while((Trip_OUT < (Trip_Point - 0.02)) && (Offset_Width < 25))
                fprintf("%d: Freq: %f, Falling Edge Dection Validation value: %f\n",Offset_Width, (Componant_Sweep_Storage_Clean1a(1,compensation_bands+Offset_Width)),  (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width-1) - (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width))));
                
                if(compensation_bands+Offset_Width+1 < size(Componant_Sweep_Storage_Clean1a,2))
                    Offset_Width = Offset_Width+1;
                else
                    break;
                end
                Trip_OUT = (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width-1) - (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width)));
            end
        else
            disp("Bad Trip, Mean Too Low")
            Offset = 0;
        end
        
        fprintf("%d: Freq: %f, Falling Edge Dection Validation value: %f\n",Offset_Width, (Componant_Sweep_Storage_Clean1a(1,compensation_bands+Offset_Width)),  (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width-1) - (Componant_Sweep_Storage_Clean1a(2,compensation_bands+Offset_Width))));
        fprintf("Release At %f\n", Componant_Sweep_Storage_Clean1a(1,compensation_bands+Offset_Width));
        
        for offset_width = 1:Offset_Width
            Storage = Componant_Sweep_Storage_Clean1a(2,compensation_bands+offset_width-1);
            Componant_Sweep_Storage_Clean1a(2,compensation_bands+offset_width-1) = Storage - Offset;
        end

        compensation_bands = compensation_bands+Offset_Width;
        Offset = 0;
    
    else
        % disp("No Trip")
        
        compensation_bands = compensation_bands+1;
    end
end

Componant_Sweep_Storage_Clean2(1,:) = Componant_Sweep_Storage_Clean1a(1,:);
Componant_Sweep_Storage_Clean2(2,:) = movmean(Componant_Sweep_Storage_Clean1a(2,:),(SPECAN_Sweep_Points/RFGEN_Sweep_Points));

Componant_Sweep_Storage_Power_Shift(1,:) = Componant_Sweep_Storage_Clean2(1, :);
Componant_Sweep_Storage_Power_Shift(2,:) = Componant_Sweep_Storage_Clean2(2, :) - Operational_Power;

figure(1)
hold on
plot(PreClean_Componant_Sweep_Storage(:,1), PreClean_Componant_Sweep_Storage(:,2))
scatter(Componant_Sweep_Storage_Clean1(1,:), Componant_Sweep_Storage_Clean1(2,:),'o','black')
scatter(Componant_Sweep_Storage_Clean1a(1,:), Componant_Sweep_Storage_Clean1a(2,:),'.','red')

xlim([750,1400])
xlabel("Frequency (MHz)")
ylim([min(PreClean_Componant_Sweep_Storage(:,2)),Operational_Power]);
ylabel("Received Power (dBm)")
legend("Raw Spectral Samples", "Local Maxima", "Test Frequencies", 'FontSize', 20)
hold off

Averaged_Single_MHz_Interpolated_Values = zeros(Band_End_Last-Band_Start_First+1,2);
        %Populate the first columen with on the megahertz frequency data
    Averaged_Single_MHz_Interpolated_Values(:,1) = Band_Start_First:Band_End_Last;
        %loop for all frequency points
    for bsa = 1:size((Band_Start_First:Band_End_Last), 2)
            %find absolute distance in x from all points to the target
            %frequency
        Adjacent_Spacing = abs(Componant_Sweep_Storage_Power_Shift(1,:)-(bsa+Band_Start_First-1));
            %sort points acording to how close they are to the target
            %location in x
        [Sorted_Adjacent_Spacing, idx] = sort(Adjacent_Spacing);
    
            %set up holders for the datum of the two closest points to the
            %target point and the target point itself
        p_t = [0,0];
        p_1 = [0,0];
        p_2 = [0,0];

            %undo the absolute value to figure out on which side of the
            %target point the points are as to extablish the order of the
            %slope
        [x_intrim, Order] = sort([Componant_Sweep_Storage_Power_Shift(1,idx(1)), Componant_Sweep_Storage_Power_Shift(1,idx(2))]);
       
        x_cord = [Componant_Sweep_Storage_Power_Shift(1,idx(Order(1))), Componant_Sweep_Storage_Power_Shift(1,idx(Order(2)))];
            %apply the y values of the two closest points to their
            %respective storage arrays
        y_cord = [Componant_Sweep_Storage_Power_Shift(2,idx(Order(1))), Componant_Sweep_Storage_Power_Shift(2,idx(Order(2)))];
    
            %set the x value of the test point
        p_t(1,1) = (bsa+Band_Start_First-1);
    
            %assign the x values to each of the points
        p_1(1,1) = x_cord(1,1);
        p_1(1,2) = y_cord(1,1);
    
            %assign the y values to each fo the test points
        p_2(1,1) = x_cord(1,2);
        p_2(1,2) = y_cord(1,2);
    
            %execute the slope formula with the test points and use it to
            %calculate the y value at the target point.
        Averaged_Single_MHz_Interpolated_Values(bsa, 2) = p_1(1,2)+(((p_t(1,1)-p_1(1,1))*(p_2(1,2)-p_1(1,2)))/(p_2(1,1)-p_1(1,1)));
    
            %NONE OF THIS WOULD HAVE NEEDED TO HAPPEN IF THE MATLAB INTERP1
            %FUNCTION WAS IN THE MOOD TO JUST BEHAVE AS EXPECTED. I GOT
            %TIRED OF FIGHTING IT FOR 2 DAYS!
    end

figure(2)
hold on
plot(Componant_Sweep_Storage_Clean1a(1,:), Componant_Sweep_Storage_Clean1a(2,:)-Operational_Power, 'LineWidth', 2);
sz = 3;
scatter(Componant_Sweep_Storage_Power_Shift(1,:), Componant_Sweep_Storage_Power_Shift(2,:),'.', 'black', 'linewidth',sz);

ylim([min(Componant_Sweep_Storage_Clean1a(2,:))-Operational_Power-1,max(Componant_Sweep_Storage_Clean1a(2,:))-Operational_Power+1]);
xlim([750,1400])
xlabel("Frequency (MHz)")
ylabel("Gain (dB)")
legend("Raw Spectrogram Data", "Moving Mean Spectrogram Data", 'FontSize', 20)
hold off

figure(3)
hold on
plot(Componant_Sweep_Storage_Clean1a(1,:), Componant_Sweep_Storage_Clean1a(2,:)-Operational_Power, 'linewidth', 2)
sz = 8;
scatter(Componant_Sweep_Storage_Power_Shift(1,:), Componant_Sweep_Storage_Power_Shift(2,:),'.', 'black', 'linewidth', sz)
plot(Averaged_Single_MHz_Interpolated_Values(:,1), Averaged_Single_MHz_Interpolated_Values(:, 2), 'blue', 'linewidth', 2)

xlim([750,1400])
ylim([min(Componant_Sweep_Storage_Clean1a(2,:))-Operational_Power-1,max(Componant_Sweep_Storage_Clean1a(2,:))-Operational_Power+1]);
xlabel("Frequency (MHz)")
ylabel("Gain (dB)")
legend("Raw Spectrogram Data", "Denoised Spectrogram Data", "Avg Interpolated Data", 'FontSize', 20)
hold off


save(Target_Element, 'Componant_Sweep_Storage_Power_Shift', 'Averaged_Single_MHz_Interpolated_Values', '-append');