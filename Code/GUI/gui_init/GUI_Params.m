function GUI_Params(P)
	
	P(1).GUI_Handles.Software_Name = 'Neuronalyzer';
	P(1).GUI_Handles.Software_Version = '2.0.0';
	
	P.GUI_Handles.UI = 1; % 0 = figure. 1 = uifigure.
	P.GUI_Handles.Multi_View = 0; % 0 = Single-view project. Multiple files are loaded as separate projects. 1 = Multi-view project. All files are loaded as one project.
	P.GUI_Handles.Save_Input_Data_Path = 0; % 0 = Save input data explicitly (e.g. image). 1 = Save only the path to the input data.
	
	P.GUI_Handles.Input_Data_Formats = {'*.png;*.tif';'.jpg'};
	
	P.GUI_Handles.Buttons_Names = {'Load Data','Load Project','Edit Parameters' ; 'Denoise Image','Trace Neuron','Extract Features' ; 'Save Image','Save Project','Save All Projects'};
	P.GUI_Handles.Step_Buttons_Names = {'Back','Start','Denoising','Vertex Detection','Neuron Tracing','Validation','Analysis','Next'};
	P.GUI_Handles.Info_Fields_List = {'Experiment','Analysis'}; % Fields to include as tabs and tables in the info panel.
	P.GUI_Handles.Menu_Names = {'Project','Reconstructions','Plots'};
	
	P.GUI_Handles.Reconstruction_Menu_Entries = {'Project','Reconstruction','Plot'};
	
	switch(P.GUI_Handles.UI)
	case 0
		P.GUI_Handles.Buttons_FontSize = 12;
	case 1
		P.GUI_Handles.Buttons_FontSize = 16;
	end
	P.GUI_Handles.Step_Buttons_FontSize = 16;
	
	P.GUI_Handles.BG_Color_1 = [.25,.25,.25];
	P.GUI_Handles.BG_Color_2 = [1,1,1];
	
	P.GUI_Handles.Step_BG_Before = [.7,.2,.2];
	P.GUI_Handles.Step_BG_Active = [.8,.8,0];
	P.GUI_Handles.Step_BG_Done = [.1,.5,.1];
	
	P.GUI_Handles.Button_BG_Neurtral = [0.0980,0.0980,0.4392]; % [0,0,0.5]; [0.2549,0.4118,0.8824]; [.1,.1,.9];
end