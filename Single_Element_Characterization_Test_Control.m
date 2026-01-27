clc; clear; close all;

DEV_DEFAULTS = 0;

Unit = "MHz";

Componant = input("Provide The Name of the DUT.\n", "s");

Dwell_Time = 200;

Frequency_Resolution_GEN = 10;

Frequency_Resolution_SPEC = 100;

SPECAN_Average_Count = 20;

Trace_Number = 1;

Step_Over = 5;

Operational_Power = 10;

Band_Start_First = 750;
Band_End_Last = 1400;
Band_End_First = Band_Start_First+Step_Over;
Band_Start_Last = Band_End_Last-Step_Over;
Sets = floor((Band_End_Last-Band_End_First)/Step_Over);
Full_Test_Range = [linspace(Band_Start_First,Band_Start_Last,Sets); linspace(Band_End_First,Band_End_Last,Sets)];

File = sprintf('Device_Sweep/%s_Sweep_Storage.mat', Componant);
save(File, 'Full_Test_Range',...
            'DEV_DEFAULTS',...
            'Componant',...
            'Dwell_Time',...
            'Frequency_Resolution_GEN',...
            'Frequency_Resolution_SPEC',...
            'SPECAN_Average_Count',...
            'Step_Over',...
            'Operational_Power',...
            "Full_Test_Range");


%% Initalization Step
disp("Initalizing Connection to Keysight N9310A RF Signal Generator");

if(exist("N9310A_ADDR") == 0)
    N9310A_ADDR = visadev("N9310A_USB");
end
N9310A_ADDR.Timeout = 0.1;
configureTerminator(N9310A_ADDR,"LF")
if(DEV_DEFAULTS == 1)
        %Spec Ann Ident Check
    writeline(N9310A_ADDR, "*IDN?")
    fprintf("Connected Device: %s\n\r", string(char(read(N9310A_ADDR, 1024, "uint8"))))
    
    
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
    if(strcmpi(Confirm_Commands_N9310A,"Y"))
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
else
    writeline(N9310A_ADDR, "*RST")
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
if(DEV_DEFAULTS == 1)

        %Sig Gen Ident Check
    N1996A_Details = writeread(N1996A_ADDR, "*IDN?");
    fprintf("Connected Device: %s\n\r", N1996A_Details)
    
    
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
    if(strcmpi(Confirm_Commands_N1996A,"Y"))
        writeline(N1996A_ADDR, "*RST")
        disp("Agilent N1996A CSA Spectrum Analyzer Reset to Factory Defaults")
    else
        writeline(N1996A_ADDR, "SYSTEM:ERROR?");
        Error_Code = string2double(string(char(read(N1996A_ADDR, 1024, "uint8"))));
        fprintf("System expirenced error code: %d\nPlease correct This error befor continueing.\n\r", Error_Code);
        pause;
        disp("Error Cleared - Continue")
    end
else
    writeline(N1996A_ADDR, "*CLS");
end

pause;
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

RFGEN_Sweep_Points = (Full_Test_Range(2,1)-Full_Test_Range(1,1))*Frequency_Resolution_GEN;
SPECAN_Sweep_Points = RFGEN_Sweep_Points*Frequency_Resolution_SPEC;

if(SPECAN_Sweep_Points > 1000)
    fprintf("%d Points Requested Exceeds Max Sweep Points for Agilent N1996A CSA Spectrum Analyzer\n Force Set to 1000 points.\n", SPECAN_Sweep_Points);
    SPECAN_Sweep_Points = 1000;
end

writeline(N9310A_ADDR, ":SWEEP:TYPE STEP");
writeline(N9310A_ADDR, ":SYSTEM:REFERENCE:FREQUENCY INT10MHZ");
Operational_Power_Range_Stop = sprintf(":AMPLITUDE:STOP %d dBm", Operational_Power);
writeline(N9310A_ADDR, Operational_Power_Range_Stop);
Operational_Power_Range_Start = sprintf(":AMPLITUDE:START %d dBm", Operational_Power-0.1);
writeline(N9310A_ADDR, Operational_Power_Range_Start);
Operational_Power_CS = sprintf(":AMPLitude:CW %d dBm", Operational_Power);
writeline(N9310A_ADDR, Operational_Power_CS);
writeline(N9310A_ADDR,":SWEEP:STRG IMMEDIATE");
writeline(N9310A_ADDR,":SWEEP:PTRG IMMEDIATE");
RF_Sweep_Points_CMD = sprintf(":SWEEP:STEP:POINTS %d", RFGEN_Sweep_Points);
writeline(N9310A_ADDR, RF_Sweep_Points_CMD);
RF_Sweep_Dwell_CMD = sprintf(":SWEEP:STEP:DWELL %d ms", Dwell_Time);
writeline(N9310A_ADDR, RF_Sweep_Dwell_CMD);

Tune = 0;
Y_Scale = 10;
SPECAN_Max_Grad = sprintf(":DISPLAY:OBWIDTH:WINDOW:TRACE:Y:SCALE:RLEVEL %d dBm", Operational_Power-Tune);
writeline(N1996A_ADDR, SPECAN_Max_Grad);
SPECAN_Y_Scale = sprintf(":DISPlAY:WINDOW:TRACE:Y:SCALE:PDIVISION %f", Y_Scale);
writeline(N1996A_ADDR, SPECAN_Y_Scale);
writeline(N1996A_ADDR, ":INSTRUMENT:SELECT SA");
writeline(N1996A_ADDR, ":SENSE:ROSCILLATOR:SOURCE EXTERNAL");
writeline(N1996A_ADDR, ":SENSE:ROSCILLATOR:EXTERNAL:FREQUENCY 10MHz");
writeline(N1996A_ADDR, ":SENSE:AVERAGE:TCONTROL EXPONENTIAL");
writeline(N1996A_ADDR, ":AVERAGE:TYPE LOG");
SPECAN_Sweep_Avg_Count = sprintf(":SENSE:AVERAGE:COUNT %d", SPECAN_Average_Count);
writeline(N1996A_ADDR, SPECAN_Sweep_Avg_Count);
SPECAN_Sense_Sweep_Points_CMD = sprintf(":SENSE:SWEEP:POINTS %d", SPECAN_Sweep_Points);
writeline(N1996A_ADDR, SPECAN_Sense_Sweep_Points_CMD);


Ticks = 1;
Start_Tick = 1;
Start_Set = 1;
End_Set = size(Full_Test_Range,2);

Frequency_Sweep = zeros((size(Full_Test_Range,2)*SPECAN_Sweep_Points),1);
for test_sets = 1:size(Full_Test_Range,2)
    linspace(Full_Test_Range(1,test_sets),Full_Test_Range(2,test_sets),SPECAN_Sweep_Points);
    for specan_pt = 1:SPECAN_Sweep_Points
        Frequency_Sweep(specan_pt+((test_sets-1)*SPECAN_Sweep_Points),1) = Full_Test_Range(1,test_sets)+((specan_pt-1)*(Step_Over/(SPECAN_Sweep_Points-1)));
    end
end

Componant_Sweep_Storage = zeros((size(Frequency_Sweep,1)+1),2);
for frequencies = 1:size(Frequency_Sweep,1)
    Componant_Sweep_Storage(frequencies+1,1) = Frequency_Sweep(frequencies,1);
end


if(DEV_DEFAULTS ~= 1)
    fprintf("This sweep contains %d test sets, indexed below.\nProvide the desired starting set and then ending set, by index value, to the following prompts.\n",Sets);
    
    for(sets = 1:Sets)
        fprintf("%02d: %d MHz - %d MHz\n",sets, Full_Test_Range(1,sets), Full_Test_Range(2,sets))
    end
    
    Start_Set = input("Provide Starting Set Index:\n");
    End_Set = input("Provide ending Set Index:\n");

    Range_Check = 1;
    clc;
    save(File, 'Start_Set', 'End_Set', '-append')
end

% if(DEV_DEFAULTS == 0)
%     disp("Disabling Display of Agilent N1996A CSA Spectrum Analyzer to increase processing speed.")
%     writeline(N1996A_ADDR, ":DISPLAY:ENABLE OFF");
% end


for sets = Start_Set:End_Set


    fprintf("\n\n")
    for i = 1:184
        fprintf("-")
    end
    fprintf("\n\n")

    Sweep_Start = Full_Test_Range(1,sets);
    Sweep_Stop = Full_Test_Range(2,sets);

    fprintf("Sweep [%d / %d]: ", sets, End_Set);
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

    if(sets == Start_Set)
        pause(3)
    end

    fprintf("Agilent N1996A CSA Spectrum Analyzer configuration complete.\n\n");

    writeline(N9310A_ADDR, ":SWEEP:REPEAT CONTINUOUS");

    writeline(N9310A_ADDR, ":RFOUTPUT:STATE ON");

    fprintf("\nRF Output Enabled - Do Not Touch Conductive Elements!!!!\n\n");
    
    writeline(N1996A_ADDR,":INITIATE:RESTART");
    disp("Triggering Sweep Now..");
    writeline(N9310A_ADDR, ":SWEEP:RF:STATE ON");

    pause(25)

    disp("Pulling Data...")
    Trace_Data_Query = sprintf(":TRACE:DATA? TRACE%d", Trace_Number);
    Active_Spectrum_Data = split(writeread(N1996A_ADDR, Trace_Data_Query), ",");
    fprintf("Reading %d data points from Spectrum Analyzer.\n", size(Active_Spectrum_Data,1));
    ASDT = zeros(size(Active_Spectrum_Data,1),1);
    for asdt = 1:size(Active_Spectrum_Data,1)
        ASDT(asdt,1) = str2double(Active_Spectrum_Data(asdt,1));
    end

    for points = 1:SPECAN_Sweep_Points
    Componant_Sweep_Storage(((SPECAN_Sweep_Points*(sets-1))+points+1),2) = ASDT(points,1);
    end
    save(File, 'Componant_Sweep_Storage', '-append')

    fprintf("Data Writen to Componant_Sweep_Storage at locations %d to %d.\n", ((SPECAN_Sweep_Points*(sets-1))+1+1), ((SPECAN_Sweep_Points*(sets-1))+SPECAN_Sweep_Points+1))
    
    if(DEV_DEFAULTS == 0)
        figure(1)
        plot(Frequency_Sweep(1:end,1),Componant_Sweep_Storage(2:end,2))
        xlim([Full_Test_Range(1,1), Full_Test_Range(2,end)])
        ylim([min(Componant_Sweep_Storage(2:end-1,2)), max(Componant_Sweep_Storage(2:end-1,2))])
    end

    writeline(N9310A_ADDR, ":RFOUTPUT:STATE OFF");
    writeline(N9310A_ADDR, ":SWEEP:RF:STATE OFF");
    disp("RF Output Disabled")
end

if(DEV_DEFAULTS == 0)
    disp("Enabling Display of Agilent N1996A CSA Spectrum Analyzer to increase clarity.")
    writeline(N1996A_ADDR, ":DISPLAY:ENABLE ON");
end
    

%% Shutdown! as if that will ever happen LOL

disp("Good work! That prolly sucked ass!")
pause(5);
disp("Shutting down Testing Rig. Good Morning...")

if(End_Set == Sets)
    Test_Run = 0;
    Full_Test = sprintf("Componant_Sweep_%s_Full_Run_%d.mat", Componant, Test_Run);
    while(isfile(Full_Test) == 1)
        Test_Run = Test_Run+1;
        Full_Test = sprintf("Device_Sweep/Componant_Sweep_%s_Full_Run_%d.mat", Componant, Test_Run);
    end
    
    save(Full_Test,...
            "File",...
            "DEV_DEFAULTS",...
            "Unit",...
            "Componant",...
            "Dwell_Time",...
            "Frequency_Resolution_GEN",...
            "Frequency_Resolution_SPEC",...
            "SPECAN_Average_Count",...
            "Trace_Number",...
            "Step_Over",...
            "Sets",...
            "Full_Test_Range",...
            "Operational_Power",...
            "RFGEN_Sweep_Points",...
            "SPECAN_Sweep_Points",...
            "Ticks",...
            "Start_Tick",...
            "Start_Set",...
            "End_Set",...
            "Componant_Sweep_Storage")
end


writeline(N1996A_ADDR, ":DISPLAY:ENABLE: ON");
delete(N9310A_ADDR);
delete(N1996A_ADDR);
clear("N9310A_ADDR");
clear("N1996A_ADDR");