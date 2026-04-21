clear; close all;

Targe_MAT_File = input("Provide the path relative to the local directory for the .mat filt to be loaded.\n", "s");
Workspace_Path = sprintf("%s/%s", pwd, Targe_MAT_File)
Workspace = load(Workspace_Path);

fieldnames(Workspace)

Target_Variable_Name_Result = 0;
while(Target_Variable_Name_Result ~= 1)
    Target_Variable_Name = input("Provide the name of the variable to change.\n", "s");
    
    if(isvarname(Target_Variable_Name) == 1)
        if(isfield(Workspace, Target_Variable_Name) == 1)
            fprintf("\n%s exists in this workspace.\n",Target_Variable_Name);
            Target_Variable_Name_Result = 1;
        else
            fprintf("\n[ERROR]: %s does not exists in this workspace.\n", Target_Variable_Name);
        end
    else
        fprintf("\n[ERROR] %s is not a valid variable name.\n", Target_Variable_Name);
    end
end

New_Variable_Name_Result = 0;
while(New_Variable_Name_Result ~= 1)
    New_Variable_Name = input("\nProvide the new name of the variable being changed.\n", "s");
    
    if(isvarname(New_Variable_Name) == 1)
        if(isfield(Workspace, New_Variable_Name) == 1)
            fprintf("\n[WARNING] %s exists in this workspace.\n",New_Variable_Name);
        else
            fprintf("\n%s does not exists in this workspace.\n", New_Variable_Name);
            New_Variable_Name_Result = 1;
        end
    else
        fprintf("\n[ERROR] %s is not a valid variable name.\n", New_Variable_Name);
    end
end


fprintf("\n\n[ALERT] Replacing %s with %s. This CANNOT be undone.\n", Target_Variable_Name, New_Variable_Name)
Confirm = input("Continue? [Y/N]\n", "s");

if(strcmpi(Confirm, "Y"))
    Workspace.(New_Variable_Name) = Workspace.(Target_Variable_Name);
    fprintf("Removing %s from Workspace...\n", Target_Variable_Name)
    Workspace = rmfield(Workspace, Target_Variable_Name);
    disp("Overwriting previous workspace...")
    save(Workspace_Path, '-struct', "Workspace");
    disp("Renaming Compleated!")
    fieldnames(Workspace)
else
    disp("Aborting variable renaming.")
end

clear all;

fprintf("\n\n\n")
for i = 1:184
    fprintf("-")
end
fprintf("\n\n\n")