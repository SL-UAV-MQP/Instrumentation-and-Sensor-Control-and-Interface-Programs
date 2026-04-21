clear; clc; close all;
load("Device_Sweep/Beampattern_Sweep_Full_Run_0.mat")

warning('off','MATLAB:audiovideo:VideoWriter:mp4FramePadded');
v = VideoWriter('Beam_Pattern_Video','MPEG-4');
v.Quality = 100;
open(v);

Beam_Sweep = Beampattern_Sweep_Storage(2:end,:);

    %array to store broken up beam sweeps
Direction = cell(1,size(Beam_Sweep,2));
    %array to store data post first cleaning
Direction_Clean1 = cell(2,(size(Beam_Sweep,2)-1));
    %array to hold fully cleaned data
Direction_Clean2 = cell(2,(size(Beam_Sweep,2)-1));

    %map each column of the Beampattern sweep onto its own columated cell
    %aray
for directions = 1:size(Beam_Sweep,2)
    Direction{1,directions} = Beampattern_Sweep_Storage(2:end,directions);
end

    %make plot of raw Beam Pattern pulled from Direction array

% figure(1)
% plot(Direction{1,1}, Direction{1,2})
% xlim([750,1400])
% xlabel("Frequency (MHz)")
% ylabel("Received Power (dBm)")
% legend("Raw Spectral Samples", 'FontSize', 20)

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

%     %Plot the points after their first cleaning operation
% figure(2)
% hold on
% plot(Direction{1,1}, Direction{1,2})
% scatter(Direction_Clean1{1,1}, Direction_Clean1{2,1},'o','red')
% xlim([750,1400])
% xlabel("Frequency (MHz)")
% ylabel("Received Power (dBm)")
% legend("Raw Spectral Samples", "Local Maxima", 'FontSize', 20)
% hold off

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

    %plot the fully cleaned data
% figure(3)
% hold on
% plot(Direction{1,1}, Direction{1,2})
% scatter(Direction_Clean1{1,1}, Direction_Clean1{2,1},'o','red')
% scatter(Direction_Clean2{1,1}, Direction_Clean2{2,1},'.','k')
% xlim([750,1400])
% xlabel("Frequency (MHz)")
% ylabel("Received Power (dBm)")
% legend("Raw Spectral Samples", "Local Maxima", "Test Frequencies", 'FontSize', 20)
% hold off
% 
% figure(4)
% plot(Direction_Clean2{1,1}, Direction_Clean2{2,1})
% xlim([750,1400])
% xlabel("Frequency (MHz)")
% ylabel("Received Power (dBm)")
% legend("Denoised Spectrogram Data", 'FontSize', 20)


% figure(2)
% hold on
% for i = 1:73
%     plot(Direction_Clean2{1,i}, Direction_Clean2{2,i})
% end

    %figure out which sample set had the least complete frequency regristry
    %(most are pretty close in length but not perfectly)
Minimum_Points = (Full_Test_Range(2,31)-Full_Test_Range(1,1))+500;

for min_size = 1:(size(Direction_Clean2,2)-3)
    if(size(Direction_Clean2{1,min_size},1) < Minimum_Points)
        Minimum_Points = size(Direction_Clean2{1,min_size},1);
    end
end

    %make a new cell array for storing horizontal beam patterns instead of
    %spectrograms
Beam_Patterns = cell(2,Minimum_Points);
    %Construct an array of directions the antenna was pointed to to map to
    %the cell arrays
Maped_Directions = Start_Tick:5:(size(Direction_Clean2,2)-1)*5;
for beam_patterm = 1:Minimum_Points
    for rotation = 1:(size(Direction_Clean2,2)-0)
            %populate the beam pattern cell arays by reading across the
            %spectrogram arrays
        Beam_Patterns{2,beam_patterm}(1,rotation) = Direction_Clean2{2,rotation}(beam_patterm);
    end
    Beam_Patterns{1,beam_patterm} = Maped_Directions;
    %Beam_Patterns{1,beam_patterm} = circshift(Maped_Directions, ceil((size(Maped_Directions,2)/2)));
end

% polarplot(deg2rad(Beam_Patterns{1,1}-180),Beam_Patterns{2,1});
% rlim([-60 -10])

% Prepare the figure for polar plotting%plot each of the beam patterns by
% frequency incrementing ev ery 0.1s
figure(10)
pax = polaraxes; 
for frequencies = 1:Minimum_Points
    polarplot(pax, deg2rad(Beam_Patterns{1,frequencies}-180),Beam_Patterns{2,frequencies});
    rlim([-60 -10])
    legend(sprintf("Frequency: %.0f MHz\n", Direction_Clean2{1,1}(frequencies)))
    pause(0.1)
    % writeVideo(v,getframe(gcf));
end
close(v);