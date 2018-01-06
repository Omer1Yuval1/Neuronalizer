function Smallest_Angles_2D_Menorah_Orders(GUI_Parameters)
	
	% assignin('base','GUI_Parameters',GUI_Parameters);
	
	Groups_Names = {GUI_Parameters.Workspace.Group_Name};
	Ng = length(GUI_Parameters.General.Groups_OnOff); % Number of (activated) groups.
	
	% ColorMap = [GUI_Parameters.Visuals.Active_Colormap(1,:) ; hsv(14)]; % hsv; % colorcube;
	ColorMap = hsv(15); % hsv; % colorcube;
	% ColorMap = hsv(64); % hsv; % colorcube;
	% ColorMap = ColorMap([1:4:64],:);
	% ColorMap = GUI_Parameters.Visuals.Active_Colormap;
	
	Means_struct = struct('X',{},'Y',{});
	Means_struct(max(1,size(GUI_Parameters.General.Categories_Filter_Values,1))).Y = [];
	
	for g=1:Ng % For each group.
		
		Means_struct = struct('X',{},'Y',{});
		Means_struct(max(1,size(GUI_Parameters.General.Categories_Filter_Values,1))).Y = [];
		
		subplot(1,Ng,g,'Color',1-GUI_Parameters.Visuals.Active_Colormap(1,:));
		
		hold on;
		for m=1:length(GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files); % For each memeber of group g.
			for v=1:numel(GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files{m}.Vertices) % For each vertex.
				Current_Category = GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files{m}.Vertices(v).Order;
				if(length(Current_Category) == 3)
					V = sort(GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files{m}.Vertices(v).Rects_Angles_Diffs);
					if(length(GUI_Parameters.General.Categories_Filter_Values) > 0) % If at least one category is selected.
						C1 = ismember(GUI_Parameters.General.Categories_Filter_Values,Current_Category,'rows');
						if(sum(C1)) % If the category of the v-vertex is one the chosen categories.
							Hm = findobj(GUI_Parameters.General.Categories_Filter_Handles,'UserData',Current_Category);
							n = str2num(Hm.Tag);
							plot(V(1),V(2),'.','MarkerSize',10,'Color',ColorMap(n,:));
							F1 = find(C1 == 1); % Find the category number (in the filtered list).
							Means_struct(F1).X(end+1) = V(1);
							Means_struct(F1).Y(end+1) = V(2);
						end
					else % If no categories are selected.
						plot(V(1),V(2),'.','MarkerSize',10,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
						Means_struct(1).X(end+1) = V(1);
						Means_struct(1).Y(end+1) = V(2);
					end
				end
			end
		end
		
		set(GUI_Parameters.General.Categories_Filter_Handles,'BackgroundColor',[.7,.7,.7]);
		
		hold on;
		if(length(GUI_Parameters.General.Categories_Filter_Values) == 0)
			MeanY = mean([Means_struct(1).Y]);
			MeanX = mean([Means_struct(1).X]);
			
			if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
				Y_STD = nanstd([Means_struct(1).Y]);
				X_STD = nanstd([Means_struct(1).X]);
				plot([MeanY-Y_STD,MeanY+Y_STD],[MeanX,MeanX],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % Y-Error-Bar.
				plot([MeanY,MeanY],[MeanX-X_STD,MeanX+X_STD],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % X-Error-Bar.
			end
			
			plot(MeanY,MeanX,'.','MarkerSize',35,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
			
		else
			for m=1:numel(Means_struct) % For each category, calculate the means of X and Y.
				Hm = findobj(GUI_Parameters.General.Categories_Filter_Handles,'UserData',GUI_Parameters.General.Categories_Filter_Values(m,:));
				n = str2num(Hm.Tag);
				MeanY = mean([Means_struct(m).Y]);
				MeanX = mean([Means_struct(m).X]);
				
				if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
					Y_STD = nanstd([Means_struct(m).Y]);
					X_STD = nanstd([Means_struct(m).X]);
					plot([MeanY-Y_STD,MeanY+Y_STD],[MeanX,MeanX],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % Y-Error-Bar.
					plot([MeanY,MeanY],[MeanX-X_STD,MeanX+X_STD],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % X-Error-Bar.
				end
				
				plot(MeanY,MeanX,'.','MarkerSize',35,'Color',ColorMap(n,:));
				set(Hm,'BackgroundColor',ColorMap(n,:));
			end
		end
		
		plot([0 180],[0 180],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		plot([0 180],[180 0],'r');
		plot([0 120 180],[180 120 0],'Color',[0.16 0.4 1],'LineWidth',3); % Mathamatical bound (2y<=360-a).
		plot([0 30],[30 0],'Color',[0.16 0.4 1],'LineWidth',3); % Algorithmic bound.
		set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size,'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
		set(gca,'XTick',0:30:180,'YTick',0:30:180);
		
		title(Groups_Names(GUI_Parameters.General.Groups_OnOff(g)),'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		xlabel('Angle 1 (Degrees)','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		ylabel('Angle 2 (Degrees)','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		axis square;
		grid on;
		grid minor;
		axis([0 180 0 180]);
	end
	
	% hold on;
	% ST = suptitle('Two Smallest Angles of 3-way Junctions');
	% ST.Color = GUI_Parameters.Visuals.Active_Colormap(1,:);
	% ST.FontSize = 40;
	% ST.EdgeColor = 'w';
	% ST.Position = [.5,.5,0]
	
end