function Custom_4_3_Rects_Medial_Orientation_VS_Distance_2D_Hist(GUI_Parameters,Visuals,YLabel,Title1)
	
	Worm_Radius_um = 45;
	Medial_Range = [0,40];
	
	Dist_Func = @(x0,y0,Vx,Vy) ( (Vx-x0).^2 + (Vy-y0).^2).^(.5);
	Get_Plane_Tilting_Angle_Func = @(d) asin(d./Worm_Radius_um); % Input: distance (in um) from the medial axis.
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	V1 = [];
	V2 = [];
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			
			if(isempty(W.Medial_Axis))
				continue;
			end
			
			Scale_Factor = W.User_Input.Scale_Factor;
			
			for s=1:numel(W.Segments)
				if(numel(W.Segments(s).Rectangles) <= 2)
					continue;
				end
				
				R = W.Segments(s).Rectangles;
				
                dx = [R(2:end).X] - [R(1:end-1).X];
                dy = [R(2:end).Y] - [R(1:end-1).Y];
                
                Rect_Angles = atan2( dy,dx );
				Angle_Diffs = zeros(1,length(Rect_Angles));
				Rects_Distances = zeros(1,length(Rect_Angles));
				
				for r=1:numel(R) - 1
					D = Dist_Func(R(r).X,R(r).Y , W.Medial_Fit.X,W.Medial_Fit.Y);
					f1 = find(D == min(D));
					f1 = f1(1);
					
					A0 = W.Medial_Fit.Angle(f1); % Medial angle.
					
					if(0)
						At = Get_Plane_Tilting_Angle_Func(D(f1) .* Scale_Factor); % Using the worm radius and the distance of the vertex from the medial axis to find the tilting angle of the vertex plane.
						[~,A_A0_Diff,~,~] = Correct_Projected_Angle(Rect_Angles(r),A0,At);
					else
						d = max(A0,Rect_Angles(r)) - min(A0,Rect_Angles(r));
						% A_A0_Diff = mod(min(d,(2.*pi)-d),pi/2); % Angle difference between A0 and the corrected A.
						A_A0_Diff = min(d,(2.*pi)-d); % Angle difference between A0 and the corrected A.
					end
					Angle_Diffs(r) = mod(A_A0_Diff,pi./2);
					
					Cxy = [R(r).X , R(r).Y];
					Rects_Distances(r) = Find_Medial_Distance(Cxy,W.Medial_Axis,Scale_Factor);
				end
				V1 = [V1 , Angle_Diffs];
				V2 = [V2 , Rects_Distances];
			end
			
			% F = find([W.Segments.Distance_From_Medial_Axis] >= Medial_Range(1) & [W.Segments.Distance_From_Medial_Axis] <= Medial_Range(2));
		end
	end
	
	% histogram(V1,0:.002:.1,'Normalization','probability');
	histogram2(V1,V2,'Normalization','probability','FaceColor','flat');
	
    set(gca,'XTick',0:pi/6:pi./2,'XTickLabel',0:30:90,'FontSize',16); % 0:pi/3:2*pi
	xlabel('Angle [degrees]','FontSize',20);
	ylabel('Distance [\mum]','FontSize',20);
	zlabel('Probability','FontSize',20);
	% xlabel('Group','FontSize',20);
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title(Title1,'FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	xlim([0,pi./2]); % xlim([0,pi]);
	ylim([0,60]);
	% YLIMITS = get(gca,'ylim');
	% ylim([0,YLIMITS(2)]);
	% xlim([0,Curvature_Range(2)]);
	grid on;
	
	function D = Find_Medial_Distance(Cxy,XY_Med,Scale_Factor)
		Dm = Dist_Func(XY_Med(:,1),XY_Med(:,2),Cxy(1),Cxy(2));
		f1 = find(Dm == min(Dm));
		Medial_Distance = Dm(f1(1)); % Minimal distance of the vertex center of the medial axis (= distance along the Y' axis).
		D = Medial_Distance.*Scale_Factor;
	end
end