clc; clear; close all;

Unit = "MHz";

Dwell_Time = 50;

Frequency_Resolution = 1;

Step_Over = 25;

SPECAN_Average_Count = 100;

Trace_Number = 1;

Set_One_Start = 750;
Set_One_End = 775;
Set_One = [(Set_One_Start+0):Step_Over:(Set_One_End-1); ((Set_One_Start+Step_Over):Step_Over:(Set_One_End-1+Step_Over))-1];

if(Set_One(end) ~= Set_One_End)
   Set_One(end) = Set_One_End;
end


Set_Two_Start = 789;
Set_Two_End = 809;
Set_Two = [(Set_Two_Start+0):Step_Over:(Set_Two_End-1); ((Set_Two_Start+Step_Over):Step_Over:(Set_Two_End-1+Step_Over))-1];

if(Set_Two(end) ~= Set_Two_End)
   Set_Two(end) = Set_Two_End;
end

Set_Three_Start = 820;
Set_Three_End = 894;
Set_Three = [(Set_Three_Start+0):Step_Over:(Set_Three_End-1); ((Set_Three_Start+Step_Over):Step_Over:(Set_Three_End-1+Step_Over))-1];

if(Set_Three(end) ~= Set_Three_End)
   Set_Three(end) = Set_Three_End;
end


Set_Four_Start = 900;
Set_Four_End = 1400;
Set_Four = [(Set_Four_Start+0):Step_Over:(Set_Four_End-1); ((Set_Four_Start+Step_Over):Step_Over:(Set_Four_End-1+Step_Over))-1];
if(Set_Four(end) ~= Set_Four_End)
   Set_Four(end) = Set_Four_End;
end

Full_Test_Set = [Set_One, Set_Two, Set_Three, Set_Four];

%% Initalization Step
disp("Initalizing Connection to Keysight N9310A RF Signal Generator");

if(exist("N9310A_ADDR") == 0)
    N9310A_ADDR = visadev("N9310A_USB");
end
N9310A_ADDR.Timeout = 0.1;
configureTerminator(N9310A_ADDR,"LF")

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

pause(0.5)

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
N9310A_ADDR.Timeout = 0.1;
configureTerminator(N9310A_ADDR,"LF")     
    
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

pause(0.5)

fprintf("\n\n")
for i = 1:184
    fprintf("-")
end
fprintf("\n\n")

%% Main Testing Loop

Range_Check = 0;

writeline(N9310A_ADDR, ":SWEEP:TYPE STEP");
writeline(N1996A_ADDR, ":INSTRUMENT:SELECT SA");

disp("Please Ensure all connections are proper as detailed in 1.E - 4.1 to 4.3 of The Official Regime of Hardware and Software Characteristic and Integration Tests.")
pause(1)
disp("Press any key to continue.")
pause

disp("Disabling Display of Agilent N1996A CSA Spectrum Analyzer to increase processing speed.")
writeline(N1996A_ADDR, ":DISPLAY:ENABLE OFF");

Ticks = input("Please indicate how many rotation ticks this test will be preformed across (1 - 73).\n");
Start_Tick = input("Please indicate starting tick (0 mark is 0 tick, anti clockwise is positive, clockwise is negitive) (-36 -> +36).\n");

for ticks = 1:Ticks

    if(Range_Check == 0)
        fprintf("This sweep contains %d test sets, indexed below.\nProvide the desired starting set and then ending set, by index value, to the following prompts.\n" + ...
            "01: %d MHz - %d MHz\n" + ...
            "02: %d MHz - %d MHz\n" + ...
            "03: %d MHz - %d MHz\n" + ...
            "04: %d MHz - %d MHz\n" + ...
            "05: %d MHz - %d MHz\n" + ...
            "06: %d MHz - %d MHz\n" + ...
            "07: %d MHz - %d MHz\n" + ...
            "08: %d MHz - %d MHz\n" + ...
            "09: %d MHz - %d MHz\n" + ...
            "10: %d MHz - %d MHz\n" + ...
            "11: %d MHz - %d MHz\n" + ...
            "12: %d MHz - %d MHz\n" + ...
            "13: %d MHz - %d MHz\n" + ...
            "14: %d MHz - %d MHz\n" + ...
            "15: %d MHz - %d MHz\n" + ...
            "16: %d MHz - %d MHz\n" + ...
            "17: %d MHz - %d MHz\n" + ...
            "18: %d MHz - %d MHz\n" + ...
            "19: %d MHz - %d MHz\n" + ...
            "20: %d MHz - %d MHz\n" + ...
            "21: %d MHz - %d MHz\n" + ...
            "22: %d MHz - %d MHz\n" + ...
            "23: %d MHz - %d MHz\n" + ...
            "24: %d MHz - %d MHz\n" + ...
            "25: %d MHz - %d MHz\n\r", size(Full_Test_Set, 2), ...
            Full_Test_Set(1,1), Full_Test_Set(2,1), ...
            Full_Test_Set(1,2), Full_Test_Set(2,2), ...
            Full_Test_Set(1,3), Full_Test_Set(2,3), ...
            Full_Test_Set(1,4), Full_Test_Set(2,4), ...
            Full_Test_Set(1,5), Full_Test_Set(2,5), ...
            Full_Test_Set(1,6), Full_Test_Set(2,6), ...
            Full_Test_Set(1,7), Full_Test_Set(2,7), ...
            Full_Test_Set(1,8), Full_Test_Set(2,8), ...
            Full_Test_Set(1,9), Full_Test_Set(2,9), ...
            Full_Test_Set(1,10), Full_Test_Set(2,10), ...
            Full_Test_Set(1,11), Full_Test_Set(2,11), ...
            Full_Test_Set(1,12), Full_Test_Set(2,12), ...
            Full_Test_Set(1,13), Full_Test_Set(2,13), ...
            Full_Test_Set(1,14), Full_Test_Set(2,14), ...
            Full_Test_Set(1,15), Full_Test_Set(2,15), ...
            Full_Test_Set(1,16), Full_Test_Set(2,16), ...
            Full_Test_Set(1,17), Full_Test_Set(2,17), ...
            Full_Test_Set(1,18), Full_Test_Set(2,18), ...
            Full_Test_Set(1,19), Full_Test_Set(2,19), ...
            Full_Test_Set(1,20), Full_Test_Set(2,20), ...
            Full_Test_Set(1,21), Full_Test_Set(2,21), ...
            Full_Test_Set(1,22), Full_Test_Set(2,22), ...
            Full_Test_Set(1,23), Full_Test_Set(2,23), ...
            Full_Test_Set(1,24), Full_Test_Set(2,24), ...
            Full_Test_Set(1,25), Full_Test_Set(2,25));
        
        Start_Set = input("Provide Starting Set Index:\n");
        End_Set = input("Provide ending Set Index:\n");
    
        Range_Check = 1;
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
    
        Sweep_Start = Full_Test_Set(1,sets);
        Sweep_Stop = Full_Test_Set(2,sets);
        RFGEN_Sweep_Points = ceil((Full_Test_Set(2,sets)-Full_Test_Set(1,sets))/Frequency_Resolution);
        SPECAN_Sweep_Points = (Sweep_Stop - Sweep_Start)*2;
    
        if(SPECAN_Sweep_Points > 1000)
            SPECAN_Sweep_Points = 1000;
        end
    
        fprintf("Configuring Keysight N9310A RF Signal Generator for %d MHz to %d MHz: %d Point Sweep.\n", Sweep_Start, Sweep_Stop, RFGEN_Sweep_Points)
    
        RF_Sweep_Start_CMD = sprintf(":SWEEP:RF:START %d MHz", Sweep_Start);
        writeline(N9310A_ADDR, RF_Sweep_Start_CMD)
    
        RF_Sweep_Stop_CMD = sprintf(":SWEEP:RF:STOP %d MHz", Sweep_Stop);
        writeline(N9310A_ADDR, RF_Sweep_Stop_CMD)
    
        RF_Sweep_Points_CMD = sprintf(":SWEEP:STEP:POINTS %d", RFGEN_Sweep_Points);
        writeline(N9310A_ADDR, RF_Sweep_Points_CMD)
    
        RF_Sweep_Dwell_CMD = sprintf(":SWEEP:STEP:DWELL %d ms", Dwell_Time);
        writeline(N9310A_ADDR, RF_Sweep_Dwell_CMD)
        writeline(N9310A_ADDR,":SWEEP:STRG KEY")
        writeline(N9310A_ADDR,":SWEEP:PTRG KEY")
    
        fprintf("Keysight N9310A RF Signal Generator configuration complete.\n\n")

        fprintf("Configuring Agilent N1996A CSA Spectrum Analyzer for %d MHz to %d MHz: %d Point Sweep.\n", Sweep_Start, Sweep_Stop, RFGEN_Sweep_Points)
    
        SPECAN_Sense_Frequency_Start_CMD = sprintf(":SENSE:FREQUENCY:START %d MHz", Sweep_Start);
        writeline(N1996A_ADDR, SPECAN_Sense_Frequency_Start_CMD)
    
        SPECAN_Sense_Frequency_Stop_CMD = sprintf(":SENSE:FREQUENCY:STOP %d MHz", Sweep_Stop);
        writeline(N1996A_ADDR, SPECAN_Sense_Frequency_Stop_CMD)
    
        SPECAN_Sense_Sweep_Points_CMD = sprintf(":SENSE:SWEEP:POINTS %d", SPECAN_Sweep_Points);
        writeline(N1996A_ADDR, SPECAN_Sense_Sweep_Points_CMD)
    
        SPECAN_Sweep_Avg_Count = sprintf(":SENSE:AVERAGE:COUNT %d", SPECAN_Average_Count);
        writeline(N1996A_ADDR, SPECAN_Sweep_Avg_Count)
    
        writeline(N1996A_ADDR,":INITIATE:CONTINUOUS ON")
    
        writeline(N1996A_ADDR, ":SENSE:AVERAGE:TCONTROL REPEAT")
    
        writeline(N1996A_ADDR, ":AVERAGE:TYPE LOG")
    
        fprintf("Agilent N1996A CSA Spectrum Analyzer configuration complete.\n\n")
    
        writeline(N9310A_ADDR, ":SWEEP:REPEAT CONTINUOUS")
        %writeline(N9310A_ADDR, ":RFOUTPUT:STATE ON")
        fprintf("\nRF Output Enabled - Do Not Touch Conductive Elements!!!!\n\n")
    
        disp("Triggering Sweep Now..")
        %writeline(N9310A_ADDR, ":TRIGGER:IMMEDIATE")

        pause(5)

        Trace_Data_Query = sprintf(":TRACE:DATA? TRACE%d", Trace_Number);
        Active_Spectrum_Data = split(writeread(N1996A_ADDR, Trace_Data_Query), ",");
        fprintf("Writing %d data points from Spectrum Analyzer.\n", size(Active_Spectrum_Data,1));
        ASDT = zeros(size(Active_Spectrum_Data_Transposed,1),1);
        for asdt = 1:size(Active_Spectrum_Data_Transposed,1)
            ASDT(asdt,1) = str2double(Active_Spectrum_Data_Transposed(asdt,1));
        end
        
        disp("Data Writen to USB Drive and Transmited to this PC as .XML")

        writeline(N9310A_ADDR, ":RFOUTPUT:STATE OFF")
        disp("RF Output Disabled")
    end
    fprintf("\n\n\n\n")
        for i = 1:184
            fprintf("-")
        end
        fprintf("\n")
        for i = 1:184
            fprintf("-")
        end
        fprintf("\n\n\n\n")

    disp("Enabling Display of Agilent N1996A CSA Spectrum Analyzer to increase clarity.")
    writelines(N1996A_ADDR, ":DISPLAY:ENABLE ON");

    Tick_Durration = ceil(toc);
    disp("Please rotate the Locating Rig 1 tick anti clockwise");
    fprintf("\nCurrent Tick: %d\nNext Tick: %d\nTicks Remaining: %d\n", (Start_Tick+ticks), (Start_Tick+ticks)+1, Ticks-ticks);
    fprintf("This dataset took %i seconds to collect.\n\n", Tick_Durration)
    disp("Press any key to resume testing after the Locating Rig has been rotated.");
end

disp("Good work! That prolly sucked ass!")
pause(5);
disp("Shutting down Testing Rig. Good Morning...")

writelines(N1996A_ADDR, ":DISPLAY:ENABLE: ON");
delete(N9310A_ADDR);
delete(N1996A_ADDR);
clear("N9310A_ADDR");
clear("N1996A_ADDR");
