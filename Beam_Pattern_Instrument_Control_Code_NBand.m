clc; clear; close all;

Unit = "MHz";

Dwell_Time = 10;

Frequency_Resolution_GEN = 1;

Frequency_Resolution_SPEC = 20;

Step_Over = 25;

SPECAN_Average_Count = 100;

Trace_Number = 1;

DEV_DEFAULTS = 1;

Band_Start_First = 725;
Band_End_Last = 1400;
Band_End_First = Band_Start_First+Step_Over;
Band_Start_Last = Band_End_Last-Step_Over;
Sets = (Band_End_Last-Band_End_First)/Step_Over;
Full_Test_Range = [linspace(Band_Start_First,Band_Start_Last,Sets); linspace(Band_End_First,Band_End_Last,Sets)];


%% Initalization Step
disp("Initalizing Connection to Keysight N9310A RF Signal Generator");

if(exist("N9310A_ADDR") == 0)
    N9310A_ADDR = visadev("N9310A_USB");
end
N9310A_ADDR.Timeout = 0.1;
configureTerminator(N9310A_ADDR,"LF")
if(DEV_DEFAULTS ~= 1)
        %Spec Ann Ident Check
    writeline(N9310A_ADDR, "*IDN?")
    fprintf("Connected Devince: %s\n\r", string(char(read(N9310A_ADDR, 1024, "uint8"))))
    
    
    disp("Testing Command Interface Connection...")
    pause(0.5)
    
    writeline(N9310A_ADDR, ":SYSTEM:DISPLAY WHITE");
    pause(2)
    writeline(N9310A_ADDR, ":SYSTEM:DISPLAY BLUE");
    pause(2)
    writeline(N9310A_ADDR, ":SYSTEM:DISPLAY GREEN");
    pause(2)
    writeline(N9310A_ADDR, ":SYSTEM:DISPLAY WHITE");
    pause(1)
end

Confirm_Commands_N9310A = input("Did the Keysight N9310A RF Signal Generator display cycle White -> Blue -> Green -> White? [Y/N] ", "s");
if(strcmp(Confirm_Commands_N9310A,"Y"))
    writeline(N9310A_ADDR, "*RST")
    disp("Keysight N9310A RF Signal Generator System Reset to Factory Defaults")
else
    writeline(N9310A_ADDR, "SYSTEM:ERROR?");
    Error_Code = string2double(string(char(read(N9310A_ADDR, 1024, "uint8"))));
    fprintf("System expirenced error code: %d\nPlease correct This error befor continueing.\n\r", Error_Code);
    pause;
    writeline(N9310A_ADDR, "*CLS");
    disp("Error Cleared - Continue")
end

fprintf("\n\n")
for i = 1:184
    fprintf("-")
end
fprintf("\n\n")

%%
disp("Initalizing Connection to Agilent N1996A CSA Spectrum Analyzer");

if(exist("N1996A_ADDR") == 0)
    N1996A_ADDR = visadev("TCPIP0::192.168.1.2::inst0::INSTR");
end
N1996A_ADDR.Timeout = 5;
configureTerminator(N1996A_ADDR,"LF")     
if(DEV_DEFAULTS ~= 1)

        %Sig Gen Ident Check
    N1996A_Details = writeread(N1996A_ADDR, "*IDN?");
    fprintf("Connected Devince: %s\n\r", N1996A_Details)
    
    
    disp("Testing Command Interface Connection...");
    pause(0.5)
    
    writeline(N1996A_ADDR, ":DISPLAY:ENABLE OFF");
    pause(2)
    writeline(N1996A_ADDR, ":DISPLAY:ENABLE ON");
    pause(2)
    writeline(N1996A_ADDR, ":DISPLAY:ENABLE OFF");
    pause(2)
    writeline(N1996A_ADDR, ":DISPLAY:ENABLE ON");
end

Confirm_Commands_N1996A = input("Did the Agilent N1996A CSA Spectrum Analyzer display cycle OFF -> ON -> OFF -> ON? [Y/N] ", "s");
if(strcmp(Confirm_Commands_N1996A,"Y"))
    writeline(N1996A_ADDR, "*RST")
    disp("Agilent N1996A CSA Spectrum Analyzer Reset to Factory Defaults")
else
    writeline(N1996A_ADDR, "SYSTEM:ERROR?");
    Error_Code = string2double(string(char(read(N1996A_ADDR, 1024, "uint8"))));
    fprintf("System expirenced error code: %d\nPlease correct This error befor continueing.\n\r", Error_Code);
    pause;
    writeline(N1996A_ADDR, "*CLS");
    disp("Error Cleared - Continue")
end

clc;

fprintf("\n\n")
for i = 1:184
    fprintf("-")
end
fprintf("\n\n")

%% Main Testing Loop
if(DEV_DEFAULTS == 1)
    pause(10)
end

Range_Check = 0;
RFGEN_Sweep_Points = Step_Over*Frequency_Resolution_GEN;
SPECAN_Sweep_Points = RFGEN_Sweep_Points*Frequency_Resolution_SPEC;

writeline(N9310A_ADDR, ":SWEEP:TYPE STEP");

writeline(N9310A_ADDR, ":AMPLITUDE:STOP -10");
writeline(N9310A_ADDR, ":AMPLITUDE:START -9.9");
writeline(N9310A_ADDR, ":AMPLitude:CW -10 dBm")
writeline(N9310A_ADDR,":SWEEP:STRG IMMEDIATE")
writeline(N9310A_ADDR,":SWEEP:PTRG IMMEDIATE")
RF_Sweep_Points_CMD = sprintf(":SWEEP:STEP:POINTS %d", RFGEN_Sweep_Points);
writeline(N9310A_ADDR, RF_Sweep_Points_CMD)
RF_Sweep_Dwell_CMD = sprintf(":SWEEP:STEP:DWELL %d ms", Dwell_Time);
writeline(N9310A_ADDR, RF_Sweep_Dwell_CMD)

writeline(N1996A_ADDR, ":INSTRUMENT:SELECT SA");
writeline(N1996A_ADDR, ":SENSE:AVERAGE:TCONTROL EXPONENTIAL")
writeline(N1996A_ADDR, ":AVERAGE:TYPE LOG")
SPECAN_Sweep_Avg_Count = sprintf(":SENSE:AVERAGE:COUNT %d", SPECAN_Average_Count);
writeline(N1996A_ADDR, SPECAN_Sweep_Avg_Count)
SPECAN_Sense_Sweep_Points_CMD = sprintf(":SENSE:SWEEP:POINTS %d", SPECAN_Sweep_Points);
writeline(N1996A_ADDR, SPECAN_Sense_Sweep_Points_CMD)


if(DEV_DEFAULTS == 1)
    Ticks = 73;
    Start_Tick = -36;
    Start_Set = 1;
    End_Set = (Band_End_Last-Band_Start_First)/Step_Over;
    Range_Check = 1;
else

    disp("Please Ensure all connections are proper as detailed in 1.E - 4.1 to 4.3 of The Official Regime of Hardware and Software Characteristic and Integration Tests.")
    pause(1)
    disp("Press any key to continue.")
    pause
    
    disp("Disabling Display of Agilent N1996A CSA Spectrum Analyzer to increase processing speed.")
    %writeline(N1996A_ADDR, ":DISPLAY:ENABLE OFF");
    
    Ticks = input("Please indicate how many rotation ticks this test will be preformed across (1 - 73).\n");
    Start_Tick = input("Please indicate starting tick (0 mark is 0 tick, anti clockwise is positive, clockwise is negitive) (-36 -> +36).\n");
end  

Frequency_Sweep = Band_Start_First:((Band_End_Last-Band_Start_First)/(SPECAN_Sweep_Points*Sets)):Band_End_Last;
Beam_Angle = Start_Tick*5:5:(Start_Tick+Ticks)*5;
Beampattern_Sweep_Storage = zeros((SPECAN_Sweep_Points*Sets)+1,Ticks+1);
for angles = 1:Ticks
    Beampattern_Sweep_Storage(1,angles+1) = Beam_Angle(1,angles);
end
for frequencies = 1:(SPECAN_Sweep_Points*Sets)
    Beampattern_Sweep_Storage(frequencies+1,1) = Frequency_Sweep(1,frequencies);
end

for ticks = 1:Ticks
    if(DEV_DEFAULTS ~= 1)
        if(Range_Check == 0)
            fprintf("This sweep contains %d test sets, indexed below.\nProvide the desired starting set and then ending set, by index value, to the following prompts.\n",Sets);
            
            for(sets = 1:Sets)
                fprintf("%02d: %d MHz - %d MHz\n",sets, Full_Test_Range(1,sets), Full_Test_Range(2,sets))
            end
            
            Start_Set = input("Provide Starting Set Index:\n");
            End_Set = input("Provide ending Set Index:\n");
        
            Range_Check = 1;
            clc;
        end
    end
    if(Range_Check == 1)
        tic
    end
    

    for sets = Start_Set:End_Set
    

        fprintf("\n\n")
        for i = 1:184
            fprintf("-")
        end
        fprintf("\n\n")
    
        Sweep_Start = Full_Test_Range(1,sets);
        Sweep_Stop = Full_Test_Range(2,sets);
    
        fprintf("Configuring Keysight N9310A RF Signal Generator for %d MHz to %d MHz: %d Point Sweep.\n", Sweep_Start, Sweep_Stop, RFGEN_Sweep_Points);
    
        RF_Sweep_Start_CMD = sprintf(":SWEEP:RF:START %d MHz", Sweep_Start);
        writeline(N9310A_ADDR, RF_Sweep_Start_CMD);
    
        RF_Sweep_Stop_CMD = sprintf(":SWEEP:RF:STOP %d MHz", Sweep_Stop);
        writeline(N9310A_ADDR, RF_Sweep_Stop_CMD);
    
        fprintf("Keysight N9310A RF Signal Generator configuration complete.\n\n")

        fprintf("Configuring Agilent N1996A CSA Spectrum Analyzer for %d MHz to %d MHz: %d Point Sweep.\n", Sweep_Start, Sweep_Stop, SPECAN_Sweep_Points);
    
        SPECAN_Sense_Frequency_Start_CMD = sprintf(":SENSE:FREQUENCY:START %d MHz", Sweep_Start);
        writeline(N1996A_ADDR, SPECAN_Sense_Frequency_Start_CMD);
    
        SPECAN_Sense_Frequency_Stop_CMD = sprintf(":SENSE:FREQUENCY:STOP %d MHz", Sweep_Stop);
        writeline(N1996A_ADDR, SPECAN_Sense_Frequency_Stop_CMD);

        writeline(N1996A_ADDR, ":TRACE1:TYPE MAXHOLD") 
    
        writeline(N1996A_ADDR,":INITIATE:CONTINUOUS ON")

        pause(3)

        % while(str2double(writeread(N1996A_ADDR, "*OPC?")) ~= 1)
        %     pause(0.25)
        % end
    
        fprintf("Agilent N1996A CSA Spectrum Analyzer configuration complete.\n\n");
    
        writeline(N9310A_ADDR, ":SWEEP:REPEAT CONTINUOUS");

        writeline(N9310A_ADDR, ":RFOUTPUT:STATE ON");

        pause(2)

        fprintf("\nRF Output Enabled - Do Not Touch Conductive Elements!!!!\n\n");
        
        writeline(N1996A_ADDR,":INITIATE:RESTART");
        disp("Triggering Sweep Now..");
        writeline(N9310A_ADDR, ":SWEEP:RF:STATE ON");

        pause(10)

        Trace_Data_Query = sprintf(":TRACE:DATA? TRACE%d", Trace_Number);
        Active_Spectrum_Data = split(writeread(N1996A_ADDR, Trace_Data_Query), ",");
        fprintf("Writing %d data points from Spectrum Analyzer.\n", size(Active_Spectrum_Data,1));
        ASDT = zeros(size(Active_Spectrum_Data,1),1);
        for asdt = 1:size(Active_Spectrum_Data,1)
            ASDT(asdt,1) = str2double(Active_Spectrum_Data(asdt,1));
        end

        for points = 1:SPECAN_Sweep_Points
        Beampattern_Sweep_Storage(((SPECAN_Sweep_Points*(sets-1))+points+1),ticks+1) = ASDT(points,1);
        end
        
        disp("Data Writen to Beampattern_Sweep_Storage.")

        writeline(N9310A_ADDR, ":RFOUTPUT:STATE OFF");
        writeline(N9310A_ADDR, ":SWEEP:RF:STATE OFF");
        disp("RF Output Disabled")
    end

    clc;

    disp("Enabling Display of Agilent N1996A CSA Spectrum Analyzer to increase clarity.")
    writeline(N1996A_ADDR, ":DISPLAY:ENABLE ON");

    

    figure(1)
    plot(Frequency_Sweep(1,1:(end-1)),Beampattern_Sweep_Storage(2:end,ticks+1))
    plot(Frequency_Sweep(1,1:9:(end-1)),Beampattern_Sweep_Storage(2:9:end,ticks+1))

    Tick_Durration = ceil(toc);
    disp("Please rotate the Locating Rig 1 tick anti clockwise");
    fprintf("\nCurrent Tick: %d\nNext Tick: %d\nTicks Remaining: %d\n", (Start_Tick+ticks), (Start_Tick+ticks)+1, Ticks-ticks);
    fprintf("This dataset took %i seconds to collect.\n\n", Tick_Durration)
    disp("Press any key to resume testing after the Locating Rig has been rotated.");
end

Beampattern_File_Name = input("Please Provide Name for storing beampattern data matrix.");
save(Beampattern_Sweep_Storage, (Beampattern_File_Name+".mat"))

%% Shutdown! as if that will ever happen LOL

disp("Good work! That prolly sucked ass!")
pause(5);
disp("Shutting down Testing Rig. Good Morning...")

writelines(N1996A_ADDR, ":DISPLAY:ENABLE: ON");
delete(N9310A_ADDR);
delete(N1996A_ADDR);
clear("N9310A_ADDR");
clear("N1996A_ADDR");
