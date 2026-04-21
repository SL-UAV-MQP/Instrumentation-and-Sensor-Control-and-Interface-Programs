%% Load Componant Data
clc; clear; close all;

    %Setup figure -> Video recorder
warning('off','MATLAB:audiovideo:VideoWriter:mp4FramePadded');
v = VideoWriter('Main_Ant_Char/Beam_Pattern_Video','MPEG-4');
v.Quality = 100;
open(v);

    %Targets Main Antenna Beampattern Sweep Test set
Ant_Run_Number = input("Which Beampattern Sweep run file is being used?\n");
Ant_Target = sprintf("Device_Sweep/Beampattern_Sweep_Full_Run_%d.mat", Ant_Run_Number);
    %Ingests Target Reffrence Antenna
load(Ant_Target, 'Direction_MHz_Intpolated_Gain', 'Start_Tick');
Direction_Nulled = cell(2,size(Direction_MHz_Intpolated_Gain, 2));


    %Targets Test System File
Reff_Ant_Run_Number = input("Which Reff Antenna run file is being used?\n");
Cable_A_Run_Number = input("Which Cable A run file is being used?\n");
Cable_B_Run_Number = input("Which Cable B run file is being used?\n");
SYS_Path_Length_Run_Number = input("What was the Reff Antenna Path Length in metres?\n");
Target_Test_System = sprintf("Reff_Ant_Char/VERT900_CHAR_RF_%d_CA_%d_CB_%d_Dist_%d.mat", Reff_Ant_Run_Number, Cable_A_Run_Number, Cable_B_Run_Number, SYS_Path_Length_Run_Number);
    %Ingest Target Test System Parameters
load(Target_Test_System);
clearvars("Path_Length");

    %Plot of the raw interpolated antenna gain at 0 degree boresight
figure(1)
hold on
plot(Direction_MHz_Intpolated_Gain{1,1}, Direction_MHz_Intpolated_Gain{2,1}, 'blue', 'Linewidth', 2)
xlim([750,1400])
ylim([min(Direction_MHz_Intpolated_Gain{2,1})-0.5,max(Direction_MHz_Intpolated_Gain{2,1})+0.5]);
xlabel("Frequency (MHz)")
ylabel("Boresight Gain (dB)")
title("Main Antenna Characterization System at 0 Degrees")
hold off
saveas(gcf,'Main_Ant_Char/Main Antenna Characterization System at 0 Degrees')

%% System Gain

    %Compute frequency dependent free space path loss
Path_Length = 2.0828;
c = physconst('LightSpeed');
Path_Loss_Gain = zeros(size(Pathless_Reff_Ant_Normalized_Returns,1),2);
Path_Loss_Gain(:,1) = Pathless_Reff_Ant_Normalized_Returns(:,1);

for frequencies = 1:size(Pathless_Reff_Ant_Normalized_Returns,1)
    lambda = c/(Pathless_Reff_Ant_Normalized_Returns(frequencies,1)*1e6);
    Path_Loss_Gain(frequencies,2) = -1*fspl(Path_Length,lambda);
end

    %Find System Gain: Coax 1 + Coax 2 + Reff Antenna + Pathloss
System_Gain = (Cable_A_Normalized_Returns(:,2) + Cable_B_Normalized_Returns(:,2) + Path_Loss_Gain(:,2) + Single_Reff_Ant_Normalized_Returns(:,2));

    %Removed System Gain from all 73 directions
for directions = 1:size(Direction_MHz_Intpolated_Gain, 2)
    Direction_Nulled{1,directions} =  Direction_MHz_Intpolated_Gain{1,directions};
    Direction_Nulled{2,directions} =  Direction_MHz_Intpolated_Gain{2,directions} - System_Gain(:);
end

    %Plot of System Gian as a funciton of frequency
figure(2)
hold on
plot(Direction_MHz_Intpolated_Gain{1,1}, System_Gain, 'blue', 'Linewidth', 2)
xlim([750,1400])
ylim([min(System_Gain)-0.5,max(System_Gain)+0.5]);
xlabel("Frequency (MHz)")
ylabel("Gain (dB)")
title("Characterization System Gain")
hold off
saveas(gcf,'Main_Ant_Char/Characterization System Gain')

    %Plot of the antenna gain at 0 degree boresight after removing system
    %gain
figure(3)
hold on
plot(Direction_Nulled{1,1}, Direction_Nulled{2,1}, 'blue', 'Linewidth', 2)
xlim([750,1400])
ylim([min(Direction_Nulled{2,1})-0.5,max(Direction_Nulled{2,1})+0.5]);
xlabel("Frequency (MHz)")
ylabel("Boresight Gain (dB)")
title("Main Antenna Gain at 0 Degrees")
hold off
saveas(gcf,'Main_Ant_Char/Main Antenna Gain at 0 Degrees')

    %figure out which sample set had the least complete frequency regristry
    %(most are pretty close in length but not perfectly)
Sweep_Lengths = zeros(1,size(Direction_Nulled,2));
for minimum_Points = 1:size(Direction_Nulled,2)
    Sweep_Lengths(minimum_Points) = size(Direction_Nulled{2,minimum_Points},1);
end
Minimum_Points = min(Sweep_Lengths);

for min_size = 1:(size(Direction_Nulled,2)-3)
    if(size(Direction_Nulled{1,min_size},1) < Minimum_Points)
        Minimum_Points = size(Direction_Nulled{1,min_size},1);
    end
end

    %make a new cell array for storing horizontal beam patterns instead of
    %spectrograms
Beam_Patterns = cell(2,Minimum_Points);
    %Construct an array of directions the antenna was pointed to to map to
    %the cell arrays
Maped_Directions = Start_Tick:5:(size(Direction_Nulled,2)-1)*5;
for beam_patterm = 1:Minimum_Points
    for rotation = 1:(size(Direction_Nulled,2)-0)
            %populate the beam pattern cell arays by reading across the
            %spectrogram arrays
        Beam_Patterns{2,beam_patterm}(1,rotation) = Direction_Nulled{2,rotation}(beam_patterm);
    end
    Beam_Patterns{1,beam_patterm} = Maped_Directions;
    %Beam_Patterns{1,beam_patterm} = circshift(Maped_Directions, ceil((size(Maped_Directions,2)/2)));
end

load('C:\Users\Carth\Desktop\WPI\ECE\MQP\MATLAB\Elements/Reflector-Bowtie_Rev_2.mat', "ANT_Reflector_Bowtie_Rev_2")

% Prepare the figure for polar plotting plot each of the beam patterns by
% frequency incrementing every 0.1s

close all;

figure(10)
pax = polaraxes; 
for frequencies = 1:Minimum_Points
    hold on
    M = patternAzimuth(ANT_Reflector_Bowtie_Rev_2, Direction_Nulled{1,1}(frequencies)*1e6);
    cla(pax)
    polarplot(pax,circshift(M,180));
    polarplot(pax, deg2rad(Beam_Patterns{1,frequencies}),Beam_Patterns{2,frequencies});
    rlim([-25, 15])
    legend("Simulated Antenna", "Real Antenna")
    Title = sprintf("Beampatterns @ %.0f MHz\n", Direction_Nulled{1,1}(frequencies));
    title(Title)
    hold off
    %pause(0.1)
    writeVideo(v,getframe(gcf));
end

close(v);