 %% Load Componant Data
   clc; clear; close all;
 
        %Targets Reffrence Antenna Test set
    Reff_Ant_Name = input("Select a Reffrence Antenna.\n", "s");
    Reff_Ant_Run_Number = input("Which run file is being used?\n");
    Reff_Ant_Target = sprintf("Device_Sweep/Componant_Sweep_%s_Full_Run_%d.mat", Reff_Ant_Name, Reff_Ant_Run_Number);
        %Ingests Target Reffrence Antenna and maps to local variable for
        %collision avoidance
    load(Reff_Ant_Target, 'Averaged_Single_MHz_Interpolated_Values');
    Reff_Ant_Normalized_Returns = Averaged_Single_MHz_Interpolated_Values;
    clearvars("Averaged_Single_MHz_Interpolated_Values");


        %Targets Feed Coax Test set
    Cable_A_Name = input("Select a Coaxial Cable.\n", "s");
    Cable_A_Run_Number = input("Which run file is being used?\n");
    Cable_A_Target = sprintf("Device_Sweep/Componant_Sweep_%s_Full_Run_%d.mat", Cable_A_Name, Cable_A_Run_Number);
        %Ingest Target Feed Coax Test set and maps to local variable for
        %collision avoidance
    load(Cable_A_Target, "Averaged_Single_MHz_Interpolated_Values");
    Cable_A_Normalized_Returns = Averaged_Single_MHz_Interpolated_Values;
    clearvars("Averaged_Single_MHz_Interpolated_Values");


        %Targets Return Coax Test set
    Cable_B_Name = input("Select a Coaxial Cable.\n", "s");
    Cable_B_Run_Number = input("Which run file is being used?\n");
    Cable_B_Target = sprintf("Device_Sweep/Componant_Sweep_%s_Full_Run_%d.mat", Cable_B_Name, Cable_B_Run_Number);
        %Ingest Target Return Coax Test set and maps to local variable for
        %collision avoidance
    load(Cable_B_Target, "Averaged_Single_MHz_Interpolated_Values");
    Cable_B_Normalized_Returns = Averaged_Single_MHz_Interpolated_Values;
    clearvars("Averaged_Single_MHz_Interpolated_Values");

figure(1)
hold on
plot(Reff_Ant_Normalized_Returns(:,1), Reff_Ant_Normalized_Returns(:, 2), 'blue', 'linewidth', 2)

xlim([750,1400])
ylim([min(Reff_Ant_Normalized_Returns(:,2))-0.5,max(Reff_Ant_Normalized_Returns(:,2))+0.5])
xlabel("Frequency (MHz)")
ylabel("Azimuthal LOS Gain(dB)")
title("Reffrence Antenna Characterization System")
hold off
saveas(gcf,'Reff_Ant_Char/Reffrence Antenna Characterization System')

%% Null Componant Losses

    %Holding Array for frequency and amplitude values after nullifying
    %losses from coax
Coaxless_Reff_Ant_Normalized_Returns = zeros(size(Reff_Ant_Normalized_Returns,1),2);
    %populate frequemcy values
Coaxless_Reff_Ant_Normalized_Returns(:,1) = Reff_Ant_Normalized_Returns(:,1);

    %Subtract the attentuation of both runs of coax from the reffrence
    %antenna normalized attenuation
for samples = 1:size(Reff_Ant_Normalized_Returns,1)
    Coaxless_Reff_Ant_Normalized_Returns(samples,2) = Reff_Ant_Normalized_Returns(samples, 2) - (Cable_A_Normalized_Returns(samples, 2) + Cable_B_Normalized_Returns(samples, 2));
end

figure(2)
hold on
plot(Coaxless_Reff_Ant_Normalized_Returns(:,1), Coaxless_Reff_Ant_Normalized_Returns(:, 2), 'blue', 'linewidth', 2)

xlim([750,1400])
ylim([min(Coaxless_Reff_Ant_Normalized_Returns(:,2))-0.5,max(Coaxless_Reff_Ant_Normalized_Returns(:,2))+0.5])
xlabel("Frequency (MHz)")
ylabel("Azimuthal LOS Gain (dB)")
title("Reffrence Antenna And Pathloss")
hold off
saveas(gcf,'Reff_Ant_Char/Reffrence Antenna And Pathloss')

%% Null FREE SPACE Path Loss

    
Path_Length = 1;
c = physconst('LightSpeed');

    %Holding Array for frequency and amplitude values after nullifying
    %losses from seperation
Pathless_Reff_Ant_Normalized_Returns = zeros(size(Coaxless_Reff_Ant_Normalized_Returns,1),2);
    %populate frequemcy values
Pathless_Reff_Ant_Normalized_Returns(:,1) = Coaxless_Reff_Ant_Normalized_Returns(:,1);

for samples = 1:size(Coaxless_Reff_Ant_Normalized_Returns,1)
    lambda = c/(Coaxless_Reff_Ant_Normalized_Returns(samples, 1)*1e6);
    Pathless_Reff_Ant_Normalized_Returns(samples,2) = Coaxless_Reff_Ant_Normalized_Returns(samples, 2) + fspl(Path_Length, lambda);
end

figure(3)
hold on
plot(Pathless_Reff_Ant_Normalized_Returns(:,1), Pathless_Reff_Ant_Normalized_Returns(:, 2), 'blue', 'linewidth', 2)

xlim([750,1400])
ylim([min(Pathless_Reff_Ant_Normalized_Returns(:,2))-0.5,max(Pathless_Reff_Ant_Normalized_Returns(:,2))+0.5])
xlabel("Frequency (MHz)")
ylabel("Azimuthal LOS Gain (dB)")
title("Two Reffrence Antenna")
hold off
saveas(gcf,'Reff_Ant_Char/Two Reffrence Antenna')


%% Null Double Antenna Gain

    %Holding Array for frequency and amplitude values after nullifying
    %losses from seperation
Single_Reff_Ant_Normalized_Returns = zeros(size(Pathless_Reff_Ant_Normalized_Returns,1),2);
    %populate frequemcy values
Single_Reff_Ant_Normalized_Returns(:,1) = Pathless_Reff_Ant_Normalized_Returns(:,1);
Single_Reff_Ant_Normalized_Returns(:,2) = Pathless_Reff_Ant_Normalized_Returns(:,2)./2;

figure(4)
hold on
plot(Single_Reff_Ant_Normalized_Returns(:,1), Single_Reff_Ant_Normalized_Returns(:, 2), 'blue', 'linewidth', 2)

xlim([750,1400])
ylim([min(Single_Reff_Ant_Normalized_Returns(:,2))-0.5,max(Single_Reff_Ant_Normalized_Returns(:,2))+0.5])
xlabel("Frequency (MHz)")
ylabel("Azimuthal LOS Gain (dB)")
title("Reffrence Antenna Only")
hold off
saveas(gcf,'Reff_Ant_Char/Reffrence Antenna Only')


Test_Syste_Rig = sprintf("Reff_Ant_Char/VERT900_CHAR_RF_%d_CA_%d_CB_%d_Dist_%d.mat", Reff_Ant_Run_Number, Cable_A_Run_Number, Cable_B_Run_Number, Path_Length);
if(isfile(Test_Syste_Rig) == 1)
    disp("This arrangment has already been computed. If this is in error, You know how to force a save! :)")
else
    save(Test_Syste_Rig,...
        "Cable_A_Name",...
        "Cable_A_Run_Number", ...
        "Cable_B_Name", ...
        "Cable_B_Run_Number", ...
        "Reff_Ant_Name", ...
        "Reff_Ant_Run_Number", ...
        "Cable_A_Normalized_Returns", ...
        "Cable_B_Normalized_Returns", ...
        "Reff_Ant_Normalized_Returns", ...
        "Coaxless_Reff_Ant_Normalized_Returns", ...
        "Path_Length",...
        "Pathless_Reff_Ant_Normalized_Returns", ...
        "Single_Reff_Ant_Normalized_Returns")
end



