function Histogram_2D_Plot(Input_Struct,GUI_Parameters,Visuals,X_Min_Max,Y_Min_Max,BinSize,XLabel,YLabel,Title1)
	
	% Description:
		% This function generates...
		% **** and error-bars representing standard devation or standard error.
		% *** Parent functions: Multiple_Choose_Plot.
	% Input:
		% GUI_Parameters: general visual parameters and graphic handles.
		% Field_Name: the field name in the Statistics structure corresponding to a morphological feature.
		% YLabel and Title1: y-axis title and main title (respectively).
	% Output:
		% No output.
	
	% assignin('base','Input_Struct',Input_Struct);
	Ncat = 0; % length(GUI_Parameters.General.Categories_Filter_Values);
	Groups_Num = numel(Input_Struct);
	ColorMap = colorcube(Groups_Num); % Visuals.Active_Colormap(i,:).
	% ColorMap = hsv(Groups_Num); % Visuals.Active_Colormap(i,:).
	
	if(Groups_Num > 0) % If at least one group is ON.
		
		Groups_Names = {Input_Struct.Group_Name}; % Cell array of group names.
		Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});		
		% assignin('base','Groups_Names',Groups_Names);
		if(Ncat == 0)
			
			% Legend_Handles_Array = zeros(1,Groups_Num);
			% for i=Groups_Num:-1:1 % For each group (a unique combination of selected features).
			for i=1:Groups_Num % For each group (a unique combination of selected features).
				% hist3([Input_Struct(i).XValues' , Input_Struct(i).YValues'],'Edges',{X_Min_Max(1):BinSize:X_Min_Max(2) , Y_Min_Max(1):BinSize:Y_Min_Max(2)}); % No normalization.
				Legend_Handles_Array(i) = histogram2(Input_Struct(i).XValues,Input_Struct(i).YValues,X_Min_Max(1):BinSize:X_Min_Max(2),Y_Min_Max(1):BinSize:Y_Min_Max(2),'FaceColor','flat'); % No normalization.
				hold on;
			end
			
			if(GUI_Parameters.Handles.Significance_Bars_CheckBox.Value)
				% Get_Statistically_Significance_Bars(Groups_Struct,Visuals.Active_Colormap(1,:));
			end
			% disp(Title1);
			view(-32,30.8); % (-15.2,59.6)
			set(gca,'FontSize',Visuals.Axes_Lables_Font_Size); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			xlabel(XLabel,'FontSize',Visuals.Axes_Titles_Font_Size);
			ylabel(YLabel,'FontSize',Visuals.Axes_Titles_Font_Size);
			set(gca,'YColor',Visuals.Active_Colormap(1,:));
			title(Title1,'FontSize',Visuals.Main_Title_Font_Size,'Color',Visuals.Active_Colormap(1,:));
			% grid on;
			
			% Lg = legend(Legend_Handles_Array,Groups_Names,'Location','best','Interpreter','none');
			% Lg.TextColor = Visuals.Active_Colormap(1,:);
			% Lg.EdgeColor = Visuals.Active_Colormap(1,:);
			% Lg.FontSize = Visuals.Legend_Font_Size2;
		end
	end
end