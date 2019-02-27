function Custom_2_2_Mean_Segment_Curvature(GUI_Parameters,Visuals,YLabel,Title1)
	
	Medial_Range = [0,40];
	Curvature_Range = [0,.1]; % [.02,.1]
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		V1 = []; % zeros(1,length(Fg));
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			
			if(0)
				F1 = find([W.Segments.Curvature] >= Curvature_Range(1) & [W.Segments.Curvature] <= Curvature_Range(2));
				F2 = find([W.Segments.Distance_From_Medial_Axis] >= Medial_Range(1) & [W.Segments.Distance_From_Medial_Axis] <= Medial_Range(2));
				F = intersect(F1,F2);
				V1 = [ V1 , ([W.Segments(F).Curvature]) ]; % Mean curvature of segments.
			else
				F1 = find([W.Segments.Max_Curvature] >= Curvature_Range(1) & [W.Segments.Max_Curvature] <= Curvature_Range(2));
				F2 = find([W.Segments.Distance_From_Medial_Axis] >= Medial_Range(1) & [W.Segments.Distance_From_Medial_Axis] <= Medial_Range(2));
				F = intersect(F1,F2);
				V1 = [ V1 , ([W.Segments(F).Max_Curvature]) ]; % Mean maximum curvature of segments.
			end
		end
				
		Mean1 = nanmean(V1);
		STD_SE = nanstd(V1);
		C = [0,0,0];
		hold on;
		scatter(g*ones(1,length(V1)),V1,10,'MarkerFaceColor',[.5,.5,.5],'MarkerEdgeColor',ColorMap(g,:),'jitter','on','jitterAmount',.2);
		errorbar(g,Mean1,STD_SE,'LineWidth',Visuals.ErrorBar_Width1,'Color',Visuals.ErrorBar_Color1);
		Legend_Handles_Array(g) = plot(g+[-1,+1]*.2,[Mean1,Mean1],'Color',C,'LineWidth',3);
		
		Groups_Struct(end+1).Group_ID = g;
		Groups_Struct(end).Values = V1;
		Groups_Struct(end).Mean = Mean1;
		Groups_Struct(end).SE = STD_SE;
		Groups_Struct(end).Category = 0;
			
		if(GUI_Parameters.Handles.Significance_Bars_CheckBox.Value)
			Get_Statistically_Significance_Bars(Groups_Struct,Visuals.Active_Colormap(1,:));
		end
	end
	
	set(gca,'XTick',1:Groups_Num,'XTickLabel',Groups_Names,'FontSize',16); % ,'FontSize',Visuals.Axes_Lables_Font_Size/(Groups_Num/2)); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientatio
	ylabel(YLabel,'FontSize',20);
	xlabel('Group','FontSize',20);
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title(Title1,'FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	xlim([0.5,Groups_Num+0.5]);
	YLIMITS = get(gca,'ylim');
	ylim([0,YLIMITS(2)]);
	grid on;
end