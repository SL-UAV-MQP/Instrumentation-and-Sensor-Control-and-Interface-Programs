clc; clear; close all;

Sweep_Set = "Device_Sweep/Beampattern_Sweep_Full_Run_0.mat";
load(Sweep_Set);

disp("Executing Processing...")

Beam_Sweep = Beampattern_Sweep_Storage(2:end,:);

    %array to store broken up beam sweeps
Direction = cell(1,size(Beam_Sweep,2));
    %array to store data post first cleaning
Direction_Clean1 = cell(2,(size(Beam_Sweep,2)-1));
    %array to hold fully cleaned data
Direction_Clean2 = cell(2,(size(Beam_Sweep,2)-1));
    %array to holds moving mean smoothed data
Direction_Clean3 = cell(2,(size(Beam_Sweep,2)-1));
    %array to hold system gain data
Direction_Gain = cell(2,(size(Beam_Sweep,2)-1));
    %array to hold MHz interpolated system gain data
Direction_MHz_Intpolated_Gain = cell(2,(size(Beam_Sweep,2)-1));


    %map each column of the Beampattern sweep onto its own columated cell
    %aray
for directions = 1:size(Beam_Sweep,2)
    Direction{1,directions} = Beampattern_Sweep_Storage(2:end,directions);
end

    %preform first clean up routine
for clean1 = 2:size(Beam_Sweep,2)
        %find local maxima in the beampatern data, these roughly ,match the
        %points we care about, but also some low power noise in the vallys
        %between the spectrum points
     Local_Max_Matrix_Logical = islocalmax(Direction{:,clean1});
        %Logical AND the logical local maxima matrix with the frequency
        %points and write them to their own row matrix in the
        %Direction_Clean1 cell matrix
     Direction_Clean1{1,clean1-1} = Direction{1,1}(Local_Max_Matrix_Logical);
        %Logical AND the logical local maxima matrix with the magnitude
        %points and write them to their own row matrix in the
        %Direction_Clean1 cell matrix
     Direction_Clean1{2,clean1-1} = Direction{1,clean1}(Local_Max_Matrix_Logical);
end 

    %preform the second cleaning operation
for clean2 = 1:(size(Beam_Sweep,2)-1)
        %find the local maxima above the mean power level of the local
        %maxima. Median is too low as there are actualy more noise based
        %local maxima then there are data based ones
     Max_Matrix_Logical = Direction_Clean1{2,clean2} > mean(Direction_Clean1{2,clean2});
        %Preform a Logical AND as before and assign the data their own row
        %matixs
     Direction_Clean2{1,clean2} = Direction_Clean1{1,clean2}(Max_Matrix_Logical);
     Direction_Clean2{2,clean2} = Direction_Clean1{2,clean2}(Max_Matrix_Logical);
end 

    %plot the fully cleaned data at boresight (0 degrees rotation / tick = 1)
figure(1)
hold on
    %Raw borewight data
plot(Direction{1,1}, Direction{1,2})
    %maxima only boresight data
scatter(Direction_Clean1{1,1}, Direction_Clean1{2,1},'o','red')
    %above mean boresight points
scatter(Direction_Clean2{1,1}, Direction_Clean2{2,1},'.','k')
xlim([750, 1400])
xlabel("Frequency (MHz)")
    %limit to the maximum powwible system power and 0.5dBm below the minium
    %measure power
ylim([min(Direction{1,2})-0.5,Operational_Power]);
ylabel("Boresight Measured Power (dBm)")
legend("Raw Spectral Samples", "Local Maxima", "Test Frequencies", 'FontSize', 20)
hold off

    %preform the second cleaning operation
for clean3 = 1:(size(Beam_Sweep,2)-1)
        %find the local maxima above the mean power level of the local
        %maxima. Median is too low as there are actualy more noise based
        %local maxima then there are data based ones
     Max_Matrix_Logical = Direction_Clean1{2,clean3} > mean(Direction_Clean1{2,clean3});
        %Preform a Logical AND as before and assign the data their own row
        %matixs
     Direction_Clean3{1,clean3} = Direction_Clean2{1,clean3};
     Direction_Clean3{2,clean3} = movmean(Direction_Clean2{2,clean3},(SPECAN_Sweep_Points/RFGEN_Sweep_Points));
end 

    %converts recived power into system gain
for gain = 1:(size(Beam_Sweep,2)-1)
    Direction_Gain{1,gain} = Direction_Clean3{1,gain};
        %Subtract the operational power used in the test from the recived
        %power to convert from measured power to system gain
    Direction_Gain{2,gain} = Direction_Clean3{2,gain} - Operational_Power;
end

    %run the interpolation sweep through every direction array
for interp = 1:(size(Beam_Sweep,2)-1)
        %array to hold data interpolated to get a best linear fit datapoint
        %on exactly the megahertz line for best array alignment
    Averaged_Single_MHz_Interpolated_Values = zeros(Band_End_Last-Band_Start_First+1,2);
        %Populate the first columen with on the megahertz frequency data
    Averaged_Single_MHz_Interpolated_Values(:,1) = Band_Start_First:Band_End_Last;
        %loop for all frequency points
    for bsa = 1:size((Band_Start_First:Band_End_Last), 2)
            %find absolute distance in x from all points to the target
            %frequency
        Adjacent_Spacing = abs(Direction_Gain{1,interp}-(bsa+Band_Start_First-1));
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
        [x_intrim, Order] = sort([Direction_Gain{1,interp}(idx(1)), Direction_Gain{1,interp}(idx(2))]);
       
        x_cord = [Direction_Gain{1,interp}(idx(Order(1))), Direction_Gain{1,interp}(idx(Order(2)))];
            %apply the y values of the two closest points to their
            %respective storage arrays
        y_cord = [Direction_Gain{2,interp}(idx(Order(1))), Direction_Gain{2,interp}(idx(Order(2)))];
    
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

        %Write the frequency points into the cell array
    Direction_MHz_Intpolated_Gain{1,interp} = Averaged_Single_MHz_Interpolated_Values(:,1);
        %Write the gain points into the cell array
    Direction_MHz_Intpolated_Gain{2,interp} = Averaged_Single_MHz_Interpolated_Values(:,2);
end

figure(2)
hold on
plot(Direction_Clean2{1,1}, Direction_Clean2{2,1}-Operational_Power, 'Linewidth', 2);
scatter(Direction_Gain{1,1}, Direction_Gain{2,1},'x', 'black', 'Linewidth', 1);

ylim([min(Direction_Clean2{2,1})-Operational_Power-1,max(Direction_Clean2{2,1})-Operational_Power+1]);
xlim([750,1400])
xlabel("Frequency (MHz)")
ylabel("Boresight Gain (dB)")
legend("Raw Spectrogram Data", "Moving Mean Spectrogram Data", 'FontSize', 20)
hold off

figure(3)
hold on
plot(Direction_Clean2{1,1}, Direction_Clean2{2,1}-Operational_Power, 'Linewidth', 2);
scatter(Direction_Gain{1,1}, Direction_Gain{2,1},'x', 'black', 'Linewidth', 1);
plot(Direction_MHz_Intpolated_Gain{1,1}, Direction_MHz_Intpolated_Gain{2,1}, 'blue', 'Linewidth', 2)

xlim([750,1400])
ylim([min(Direction_Clean2{2,1})-Operational_Power-1,max(Direction_Clean2{2,1})-Operational_Power+1]);
xlabel("Frequency (MHz)")
ylabel("Boresight Gain (dB)")
legend("Raw Spectrogram Data", "Denoised Spectrogram Data", "Avg Interpolated Data", 'FontSize', 20)
hold off

save(Sweep_Set, 'Direction_Gain', 'Direction_MHz_Intpolated_Gain', '-append');