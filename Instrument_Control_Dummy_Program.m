clc; clear; close all;

Unit = "MHz";

Step_Over = 25;

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

%% Initalization Step
disp("Initalizing Connection to Keysight N9310A RF Signal Generator...");

%N9310A_ADDR = visadev();
%N9310A_ADDR.Terminator = "LF";

    %Spec Ann Ident Check
disp("*IDN?")
fprintf("%s\n\r", "Test IDEN")

disp("Testing Command Interface Connection...")
pause(0.5)

disp(":SYSTEM:DISPLAY: WHITE");
pause(2)
disp(":SYSTEM:DISPLAY: BLUE");
pause(2)
disp(":SYSTEM:DISPLAY: GREEN");
pause(2)
disp(":SYSTEM:DISPLAY: WHITE");
pause(1)

Confirm_Commands_N9310A = input("Did the Keysight N9310A RF Signal Generator display cycle from White, Blue, Green, White? [Y/N] ", "s");
if(strcmp(Confirm_Commands_N9310A,"Y"))
    disp("*RST")
    disp("Keysight N9310A RF Signal Generator System Reset to Factory Defaults.")
else
    disp("SYSTEM:ERROR?");
    Error_Code = 10;
    fprintf("System expirenced error code: %d\nPlease correct This error befor continueing.\n\r", Error_Code);
    pause;
    disp("*CLS");
    disp("Error Cleared - Continue")
end

pause(0.5)

fprintf("\n\n")
for i = 1:184
    fprintf("-")
end
fprintf("\n\n")


disp("Initalizing Connection to Agilent N1996A CSA Spectrum Analyzer...");

%N1996A_ADDR = visadev();
%N1996A_ADDR.Terminator = "LF";
     
    %Sig Gen Ident Check
disp("*IDN?")
fprintf("%s", "Test IDEN")

disp("Testing Command Interface Connection...")
pause(0.5)

disp(":DISPLAY:ENABLE: OFF");
pause(1)
disp(":DISPLAY:ENABLE: ON");
pause(1)
disp(":DISPLAY:ENABLE: OFF");
pause(1)
disp(":DISPLAY:ENABLE: ON");

Confirm_Commands_N1996A = input("Did the Agilent N1996A CSA Spectrum Analyzer display cycle OFF, ON, OFF, ON? [Y/N] ", "s");
if(strcmp(Confirm_Commands_N1996A,"Y"))
    disp("*RST")
    disp("Agilent N1996A CSA Spectrum Analyzer Reset to Factory Defaults.")
else
    disp("SYSTEM:ERROR?");
    Error_Code = 11;
    fprintf("System expirenced error code: %d\nPlease correct This error befor continueing.\n\r", Error_Code);
    pause;
    disp("*CLS");
    disp("Error Cleared - Continue.")
end

