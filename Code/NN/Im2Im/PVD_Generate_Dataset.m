function PVD_Generate_Dataset()
	
	% This function generates a training set made of input-output pairs of PVD patches from annotated grayscale images.
	
	% Note:
		% To generate samples with an even number of rows and columns, an asymmetric x-range and y-range are used around each pixel (-d:(d-1)).
	
	rng('default'); % Reset the random seed.
	
	S = PVD_CNN_Params();
	
	File_List = dir([S.Projects_Path,'Project_WT*.mat']); % List all project files.
	
	T_Set = table('Size',[S.Ns,2],'VariableTypes',{'cell','cell'},'VariableNames',{'Input','Output'});
	t = 0;
	
	for f=1:numel(File_List) % For each project file.
		
		% Load file:
		P.Data = load([File_List(f).folder,filesep,File_List(f).name]);
		P.Data = P.Data.Project;
		
		for p=1:numel(P.Data) % For each project within file f.
			
			ID = P.Data(p).Info.Experiment(1).Identifier;
			disp(ID);
			
			% Get raw and annotated images:
			Im = S.Input_Image_Func(P.Data(p).Info.Files.Raw_Image); % Raw image.
			Im_BW = P.Data(p).Info.Files.Binary_Image; % Binary image.
			Im_Size = size(Im);
			
			% Get pixel indices and randomize their order:
			Xr = S.Full_Image_Margin:(Im_Size(2)-S.Full_Image_Margin); % X range.
			Yr = S.Full_Image_Margin:(Im_Size(1)-S.Full_Image_Margin); % Y range.
			XYr = combvec(Xr,Yr); % All pixel coordinates.
			XYr = XYr(:,randperm(size(XYr,2))); % Randomize pixels order.
			
			tt = 0; % Image-specific sample counter (counts the number of pixels used to generate samples).
			for i=1:size(XYr,2) % For each pixel.
				
				% Generate sample:
				Ixy = XYr(:,i) + (-S.Input_Half_Size:(S.Input_Half_Size-1)); % [2 x Np].
				In = Im(Ixy(2,:),Ixy(1,:));
				Out = Im_BW(Ixy(2,:),Ixy(1,:));
				
				if(S.Sample_In_Func(In) && S.Sample_Out_Func(Out))
					t = t + 1; % Global sample index.
					tt = tt + 1; % Image-specific sample index.
					
					% Apply random rotation:
					Ri = randi(length(S.Rotation_Vector));
					In = imrotate(In,S.Rotation_Vector(Ri));
					Out = imrotate(Out,S.Rotation_Vector(Ri));
					
					% Apply random reflection
					Ri = randi(length(S.Reflection_Vector));
					In = S.Reflection_Vector{Ri}(In);
					Out = S.Reflection_Vector{Ri}(Out);
					
					% Save sample:
					File_Name = [num2str(ID),'-',num2str(XYr(1,i)),'-',num2str(XYr(2,i)),S.Image_Format]; % [image_identifier - x - y . tif].
					
					imwrite(In,[S.Save_Dir_Input,File_Name],'Compression','none'); % Save input image.
					imwrite(Out,[S.Save_Dir_Output,File_Name],'Compression','none'); % Save output image.
					
					T_Set.Input{t} = [S.Train_Dir_Input,File_Name];
					T_Set.Output{t} = [S.Train_Dir_Output,File_Name];
					
					% Validate:
					% H = figure; subplot(1,2,1); imshow(In); subplot(1,2,2); imshow(Out); waitforbuttonpress; close(H);
				end
				
				
				if(tt == S.Samples_Per_Image)
					break;
				end
			end
		end
	end
	
	T_Set = T_Set(1:t,:);
	save([S.Main_Dir,'T_Set_1'],'T_Set');
	
end