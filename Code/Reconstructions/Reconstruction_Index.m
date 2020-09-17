function Reconstruction_Index(GP,ii)
	
	% GP is a short for GUI_Parameters.
	
	% TODO:
		% Move out: Worm_Radius_um.
	
	Worm_Radius_um = 45;
	LineWidth_1 = 2; % [2,6].
	DotSize_1 = 10; % 80;
	DotSize_2 = 15; % 80;
	Scale_Factor = GP.Workspace(ii).Workspace.User_Input.Scale_Factor;
	
	if(1)
		figure(1);
		hold on;
	else
		H = figure;
		set(H,'Position',[19,561,1786,526]);
		%{
		GP.Handles.Axes = axes;
		XY = [1140,1250,550,660];
		% GP.Workspace(ii).Workspace.Image0 = GP.Workspace(ii).Workspace.Image0(XY(3):XY(4),XY(1):XY(2));
		GP.Workspace(ii).Workspace.NN_Probabilities = GP.Workspace(ii).Workspace.NN_Probabilities(XY(3):XY(4),XY(1):XY(2));
		GP.Workspace(ii).Workspace.Im_BW = GP.Workspace(ii).Workspace.Im_BW(XY(3):XY(4),XY(1):XY(2));
		%}
		hold on;
	end
	
	Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
	
	switch GP.General.Active_Plot
		case 'Raw Image - Grayscale'
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			
		case 'Raw Image - RGB'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			colormap hot;
		case 'Cell Body' % Detect and display CB and the outsets of the branches connected to it:
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes
			hold on;
			CB_BW_Threshold = GP.Workspace(ii).Workspace.Parameters.Cell_Body.BW_Threshold;
			
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(GP.Workspace(ii).Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			% set(gca,'YDir','normal','Position',[0,0,1,1]);
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(GP.Workspace(ii).Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
			
			% plot(CB_Perimeter(:,1),CB_Perimeter(:,2),'LineWidth',4);
		case 'CNN Image - Grayscale'
			imshow(GP.Workspace(ii).Workspace.NN_Probabilities); % ,'Parent',GP.Handles.Axes);
		case 'CNN Image - RGB'
			imshow(GP.Workspace(ii).Workspace.NN_Probabilities); % ,'Parent',GP.Handles.Axes
			colormap hot;
		case 'Binary Image'
			imshow(GP.Workspace(ii).Workspace.Im_BW); % ,'Parent',GP.Handles.Axes
			
		case 'Raw + Binary Image - RGB'
			Im_RGB = repmat(GP.Workspace(ii).Workspace.Image0(:,:,1),[1,1,3]);
			Im_RGB(:,:,1) = Im_RGB(:,:,1) .* uint8(~GP.Workspace(ii).Workspace.Im_BW);
			Im_RGB(:,:,2) = Im_RGB(:,:,2) .* uint8(GP.Workspace(ii).Workspace.Im_BW);
			imshow(Im_RGB,'Parent',GP.Handles.Axes);
		case 'Skeleton'
			[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Pixel_Trace_Post_Proccessing(GP.Workspace(ii).Workspace.Im_BW,Scale_Factor);
			imshow(Im1_NoiseReduction);
			
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
					y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
					hold on;
					plot(x,y,'LineWidth',LineWidth_1); % plot(x,y,'.','MarkerSize',30,'Color',rand(1,3));
				end
			end
			[Y,X] = find(Im1_branchpoints); hold on; plot(X,Y,'.k','MarkerSize',30);
			[Y,X] = find(Im1_endpoints); hold on; plot(X,Y,'.r','MarkerSize',30);
			
			%{
			% Color connected components:
			CC = bwconncomp(Im1_NoiseReduction);
			for c=1:length(CC.PixelIdxList)
				[y,x] = ind2sub(size(Im1_NoiseReduction),CC.PixelIdxList{c});
				hold on;
				plot(x,y,'.','MarkerSize',7);
			end
			%}
		case 'Blob'
			Find_Worm_Longitudinal_Axis(GP.Workspace(ii).Workspace,1); % GP.Handles.Axes
		case 'Trace'
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			plot([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],'.','Color',[0.12,0.56,1],'MarkerSize',DotSize_1);
			plot([GP.Workspace(ii).Workspace.All_Vertices.X],[GP.Workspace(ii).Workspace.All_Vertices.Y],'.k','MarkerSize',DotSize_2); % [0.6,0,0].
		case 'Segmentation'
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			
			Class_Indices = [1,2,3,4];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0];
			
			if(isfield(GP.Workspace(ii).Workspace,'Segments'))
				for s=1:numel(GP.Workspace(ii).Workspace.Segments)
					if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
						x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
						y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
						plot(x,y,'LineWidth',LineWidth_1);
					end
				end
				% Reconstruct_Segmented_Trace(GP.Workspace(ii).Workspace,GP.Handles.Analysis); % Reconstruct_Segments(GP.Workspace(1).Workspace);
			end
		case 'Segments by Length'
			
			Max_Length = 50; % [um].
			CM = jet(1000);
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
					y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
					c = [GP.Workspace(ii).Workspace.Segments(s).Length];
					if(isnan(c) || c <= 0)
						plot(x,y,'Color','w','LineWidth',3);
					else
						plot(x,y,'Color',CM(round(rescale(c,1,1000,'InputMin',0,'InputMax',Max_Length)),:),'LineWidth',3);
					end
				end
			end
			
			X = [GP.Workspace(ii).Workspace.All_Vertices.X];
			Y = [GP.Workspace(ii).Workspace.All_Vertices.Y];
			hold on;
			scatter(X,Y,20,[0,0.6,0],'filled');
		case 'Axes'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			
			%{
			Np = str2num(GP.Handles.Tracing.Midline_Points_Num.String);
			
			XY = [GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0.X ; GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0.Y];
			
			pp = cscvn(XY); % Fit a cubic spline.
			Vb = linspace(pp.breaks(1),pp.breaks(end),Np);
			XY = fnval(pp,Vb);
			
			hold on;
			plot(XY(1,:),XY(2,:),'LineWidth',3);
			plot(XY(1,:),XY(2,:),'.','MarkerSize',20);
			
			for p=1:numel(GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0)
				x = GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0(p).X;
				y = GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0(p).Y;
				a = GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0(p).Tangent_Angle + (pi/2);
				
				plot(x + 40.*[0,cos(a)] , y + 40.*[0,sin(a)]);
			end
			%}
		case 'Axes Mapping Process'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			Map_Worm_Axes(GP.Workspace(ii).Workspace,GP.Workspace(ii).Workspace.Neuron_Axes,1,0,GP.Handles.Axes);
		case {'Radial Distance','Angular Coordinate'}
			
			X = [GP.Workspace(ii).Workspace.All_Points.X];
			Y = [GP.Workspace(ii).Workspace.All_Points.Y];
			
			switch GP.General.Active_Plot
				case 'Radial Distance'
					Field_1 = 'Radial_Distance_Corrected';
				case 'Angular Coordinate'
					Field_1 = 'Angular_Coordinate';
			end
			D = abs([GP.Workspace(ii).Workspace.All_Points.(Field_1)]);
			
			[~,~,Ic] = histcounts(D,1000);
			F = find(Ic ~=0);
			Ic = Ic(F);
			X = X(F);
			Y = Y(F);
			
			CM = hsv(1000);
			
			% CM = [O,.5.*O,1-O];
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			scatter(X,Y,DotSize_1,CM(Ic,:),'filled');
			% scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM,'filled');
		case 'Midline Orientation'
			
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Midline_Orientation])';
			CM = [1-O,O,0.*O+0.1];
			
			% O = round(rescale([GP.Workspace(ii).Workspace.All_Points.Midline_Orientation],1,100)');
			% CM = jet(100);
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes
			hold on;
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],DotSize_1,CM,'filled'); % [5,100]
			% scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM(O,:),'filled');
			
			% C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))),:);
			% CM = jet(1000);
			% h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',3);
			
		case 'Longitudinal Gradient'
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes
			hold on;
			
			O = round(rescale([GP.Workspace(ii).Workspace.All_Points.Axis_0_Position],1,100)');
			CM = jet(100);
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM(O,:),'filled');
			
			%{
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM,'filled');
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Axis_0_Position])';
			CM = [O,0.*O,1-O];
			%}
		case 'Dorsal-Vental'
			
			Field_1 = 'Radial_Distance_Corrected';
			
			X = [GP.Workspace(ii).Workspace.All_Points.X];
			Y = [GP.Workspace(ii).Workspace.All_Points.Y];
			Dist = [GP.Workspace(ii).Workspace.All_Points.(Field_1)];
			
			D = find(Dist <= 0);
			V = find(Dist > 0);
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			scatter(X(D),Y(D),DotSize_1,'b','filled');
			scatter(X(V),Y(V),DotSize_1,'r','filled');
		
		case {'Vertices Angles','Vertices Angles - Corrected'}
			
			a = 5;
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			Reconstruct_Vertices(GP.Workspace(ii).Workspace);
			
			%{
			F1 = find([GP.Workspace(ii).Workspace.All_Points.Vertex_Order] >= 3); % Find rectangles of junctions.
			X = [GP.Workspace(ii).Workspace.All_Points(F1).X];
			Y = [GP.Workspace(ii).Workspace.All_Points(F1).Y];
			A = [GP.Workspace(ii).Workspace.All_Points(F1).Angle];
			Vx = [X ; X + a.*cos(A)];
			Vy = [Y ; Y + a.*sin(A)];
			
			plot([GP.Workspace(ii).Workspace.All_Vertices.X],[GP.Workspace(ii).Workspace.All_Vertices.Y],'.','MarkerSize',50);
			hold on;
			plot(Vx,Vy,'LineWidth',3);
			%}
		case {'3-Way Junctions - Position','Tips - Position'}
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			
			switch GP.General.Active_Plot
				case '3-Way Junctions - Position'
					Vertex_Order = 3;
					Junction_Classes = [1,1,2 ; 2,3,3 ; 3,3,4]; % 234,344
				case 'Tips - Position'
					Vertex_Order = 1;
					Junction_Classes = 1:4;
			end
			
			Max_PVD_Orders = length(Junction_Classes);
			CM = lines(Max_PVD_Orders);
			
			for v=1:numel(GP.Workspace(ii).Workspace.All_Vertices)
				if(GP.Workspace(ii).Workspace.All_Vertices(v).Order == Vertex_Order && length(GP.Workspace(ii).Workspace.All_Vertices(v).Class) == Vertex_Order)
					[I,i] = ismember(sort(GP.Workspace(ii).Workspace.All_Vertices(v).Class),Junction_Classes,'rows');
					if(I) % If the class is a member of the Junction_Classes matrix, plot it.
						X = [GP.Workspace(ii).Workspace.All_Vertices(v).X];
						Y = [GP.Workspace(ii).Workspace.All_Vertices(v).Y];
						
						hold on;
						scatter(X,Y,40,CM(i,:),'filled');
					end
				end
			end
			
		case 'Curvature'
			Curvature_Min_Max = [0,0.3]; % 0.2
			CM_Lims = [1,1000];
			CM = jet(CM_Lims(2));
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					
					C = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Curvature];
					f = find(~isnan(C));
					
					X = [GP.Workspace(ii).Workspace.Segments(s).Rectangles(f).X];
					Y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles(f).Y];
					C = C(f);
					
					C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))),:);
					% C = rescale(C,0,1,'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))';
					
					Y(end) = nan;
					h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
				end
			end
			% Reconstruct_Curvature(GP.Workspace(ii).Workspace,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),1);
		case 'PVD Orders - Points'
			
			Class_Num = max([GP.Workspace(ii).Workspace.All_Points.Class]);
			
			C = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0 ; .5,.5,.5];
			
			% figure;
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			Midline_Distance = [GP.Workspace(ii).Workspace.All_Points.X];
			Midline_Orientation = [GP.Workspace(ii).Workspace.All_Points.Y];
			Classes = [GP.Workspace(ii).Workspace.All_Points.Class]; % Classes = [GP.Workspace(ii).Workspace.All_Points.Segment_Class];
			Classes(isnan(Classes)) = Class_Num + 1;
			
			scatter(Midline_Distance,Midline_Orientation,10,C(Classes,:),'filled');
			
			% assignin('base','All_Points',GP.Workspace(ii).Workspace.All_Points);
			
		case 'PVD Orders - Segments'
			Class_Num = max([GP.Workspace(ii).Workspace.All_Points.Class]);
			
			% C = lines(Class_Num+1);
			Class_Indices = [1,2,3,4]; %  [1,2,3,3.5,4,5];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0]; % 3=0,0.8,0.8 ; 3.5=0,0,1 ; 5=0.5,0.5,0.5
			
			imshow(GP.Workspace(ii).Workspace.Image0); % ,'Parent',GP.Handles.Axes);
			hold on;
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
					y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
					c = find(Class_Indices == GP.Workspace(ii).Workspace.Segments(s).Class);
					if(isempty(c)) % isnan(c)
						plot(x,y,'Color',Class_Colors(end,:),'LineWidth',LineWidth_1);
					else
						plot(x,y,'Color',Class_Colors(c,:),'LineWidth',2); % Use 5 when zooming in. Otherwise 2.
					end
				end
			end
			
			% Plot the vertices:
			%
			X = [GP.Workspace(ii).Workspace.All_Vertices.X];
			Y = [GP.Workspace(ii).Workspace.All_Vertices.Y];
			
			hold on;
			scatter(X,Y,10,'k','filled'); % Use 100 when zooming in. Otherwise 10.
			%}
			
			% Use when zooming in:
			% F = find([GP.Workspace(ii).Workspace.All_Vertices.Order] >= 2);
			% R = [GP.Workspace(ii).Workspace.All_Vertices.Radius] .* GP.Workspace(1).Workspace.User_Input.Scale_Factor ./ 10;
			% viscircles([X(F)',Y(F)'],R(F),'Color','k','LineWidth',5); % [0.6350 0.0780 0.1840]
		otherwise
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			Reconstruct_Trace(GP.Workspace(ii).Workspace);
	end
	set(gca,'position',[0,0,1,1]);
	axis tight;
	
	% set(gca,'YDir','normal');
	%{
	H.Position = [114,469,1692,498]; % [10,50,900,900];
	set(GP.Handles.Axes,'unit','normalize');
	set(GP.Handles.Axes,'position',[0,0,1,1]);
	axis tight;
	%}
	
	% axis(XY);
	
	%{
	hold on;
	Scale_Factor = GP.Workspace(1).Workspace.User_Input.Scale_Factor;
	plot([20,20+50*(1/Scale_Factor)],[20,20],'w','LineWidth',3);
	text(15+25,25,['50 \mum'],'FontSize',20,'Color','w');
	%}
	
	% hold on;
	% Compass1 = imread('Compass.tif');
	% imshow(Compass1);
	% imshow(imresize(Compass1,1)); % 0.1*GP.Workspace(1).Workspace.Parameters.General_Parameters.Im_Rows));
	
	function Set_Dynamic_Sliders_Values(Handles,Min_Value,Max_Value)
		set(Handles.Dynamic_Slider_Min,'Enable','on');
		set(Handles.Dynamic_Slider_Max,'Enable','on');
		if(Handles.Dynamic_Slider_Min.Min ~= Min_Value || Handles.Dynamic_Slider_Min.Max ~= Max_Value || ...
			Handles.Dynamic_Slider_Max.Min ~= Min_Value || Handles.Dynamic_Slider_Max.Max ~= Max_Value) % Update the slider only if the max or min have changed. Otherwise, keep the last chosen values.
			Handles.Dynamic_Slider_Min.Min = Min_Value; % Scale dynamic sliders.
			Handles.Dynamic_Slider_Min.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Max.Min = Min_Value;% ".
			Handles.Dynamic_Slider_Max.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Min.Value = Min_Value;
			Handles.Dynamic_Slider_Max.Value = Max_Value;
			Handles.Dynamic_Slider_Text_Min.String = [num2str(Handles.Dynamic_Slider_Min.Value),char(181),'m']; % Update sliders text.
			Handles.Dynamic_Slider_Text_Max.String = [num2str(Handles.Dynamic_Slider_Max.Value),char(181),'m']; % ".
		end
	end
	
end