function [Vertices,Segments] = Segment_Skeleton(Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints,Im_Skel_Rad)
	
	Messages = 0;
	
	[Im_Rows,Im_Cols] = size(Im1_branchpoints);
	BP_Min_Dis = 4;
	
	if(Messages)
		assignin('base','Im1_NoiseReduction',Im1_NoiseReduction);
		assignin('base','Im1_branchpoints',Im1_branchpoints);
		assignin('base','Im1_endpoints',Im1_endpoints);
		assignin('base','Im_Skel_Rad',Im_Skel_Rad);
	end
	
	Vertices = struct('Vertex_Index',{},'Coordinate',{});
	% Segments = struct('Segment_Index',{},'Skeleton_Linear_Coordinates',{},'Vertex1_Index',{},'Vertices(2)',{});
	Segments = struct('Segment_Index',{},'Skeleton_Linear_Coordinates',{},'Vertices',{});
	Vi = 0;
	Si = 0;
	Vertices(200).Vertex_Index = 0;
	Segments(200).Segment_Index = 0;
	[Segments.Vertices] = deal([0,0]);
	
	Im1_NoiseReduction = double(Im1_NoiseReduction);
	% Im1_Vertices = 3*Im1_branchpoints + Im1_endpoints; % 3=branch-point ; 1 = end-point.
	Im1_Vertices = Im1_branchpoints + Im1_endpoints; % 3=branch-point ; 1 = end-point.
	
	[By,Bx] = find(Im1_Vertices);
	for b=1:length(By) % For each vertex (a branch-point or a tip).
		Vi = Vi + 1;
		% Vertices(Vi).Vertex_Index = Vi*(Im1_Vertices(By(b),Bx(b)) - 2); % Plus 1 (=3-2) for branch-points. Minus 1 (=1-2) for end-points.
		Vertices(Vi).Vertex_Index = Vi; % Plus 1 (=3-2) for branch-points. Minus 1 (=1-2) for end-points.
		Vertices(Vi).Coordinate = Im_Rows*(Bx(b)-1)+By(b);
		Vertices(Vi).Order = sum(sum(Im1_NoiseReduction(By(b)-1:By(b)+1,Bx(b)-1:Bx(b)+1))) - 1; % # of "1" pixels connected to the vertex (tip or branch-point).
	end
	
	Fv = find([Vertices.Order] >= 3);
	% for v=Fv % For each branch-point.
	for v=1:numel(Vertices) % For each vertex (a branch-point or a tip).
		[Vy,Vx] = ind2sub([Im_Rows,Im_Cols],Vertices(v).Coordinate);
		Im1_NoiseReduction(Vy,Vx) = 0; % Delete the branch-point.
		[Ry,Rx] = find(Im1_NoiseReduction(Vy-1:Vy+1,Vx-1:Vx+1) > 0); % Find the 1st pixel of each route connected to this branch-point.
		Ry = Ry + Vy - 2; % Convert back to the full image coordinates.
		Rx = Rx + Vx - 2; %
		
		Im1_NoiseReduction(Im_Rows.*(Rx-1)+Ry) = -1; % Mark the 1st pixels (using linear indices).
		
		F3 = find(Im1_NoiseReduction == -1);
		
		for r=1:length(Ry) % For each route connected to this branch-point.

			% If a pixel is connected to a branchpoint and no longer connected to anything else,
			% (it was traced from the opposite side), ignore it.
			if( length(find(Im1_NoiseReduction(Ry(r)-1:Ry(r)+1,Rx(r)-1:Rx(r)+1) > 0)) == 0)
				if(Messages)
					disp(['I detected a pixel which is connected to a branchpoint but not to anything else. I am ignoring this pixel. Coordinate: [',num2str([Rx(r),Ry(r)]),'].']);
				end
				continue;
			end
			
			Si = Si + 1; % Define a new segment:
			
			Segments(Si).Segment_Index = Si;
			% Segments(Si).Vertex1_Index = Vertices(v).Vertex_Index; % Log the 1st vertex (never an end-point). TODO: not true.
			Segments(Si).Vertices(1) = Vertices(v).Vertex_Index; % Log the 1st vertex.
			
			Ry0 = Ry(r);
			Rx0 = Rx(r);
			Fr1 = Im_Rows*(Rx0-1)+Ry0;
			Segments(Si).Skeleton_Linear_Coordinates = Fr1; % Log the 1st point of the segment.
			
			while(1) % Collect segment coordinates (pixels).
				% Im1_NoiseReduction(Fr1) = 0; % Delete the current pixel.
				[Ry1,Rx1] = find(Im1_NoiseReduction(Ry0-1:Ry0+1,Rx0-1:Rx0+1) > 0); % Find the pixels connected to the pixel (excluding the deleted current pixel and previously visited\deleted pixels).
				Ry2 = Ry1 + Ry0 - 2; % Conversion of the small frame to the coordinates of the full image.
				Rx2 = Rx1 + Rx0 - 2; % ".
				Fr1 = Im_Rows*(Rx2-1)+Ry2; % Conversion of the frame coordinates (in the full image) to linear indices.
				
				if(length(Fr1) == 1) % Only one new point in the neighborhood (a segment point, a junction or a tip).
					if(length(find([Vertices.Coordinate] == Fr1))) % If it's vertex.
						Segments(Si).Vertices(2) = Vertices(find([Vertices.Coordinate] == Fr1)).Vertex_Index; % Find the vertex with the same coordinate.
						break;
					else
						Segments(Si).Skeleton_Linear_Coordinates(end+1) = Fr1; % Taking 1st just in case there's more than one option (should not occur).
						Im1_NoiseReduction(Fr1) = 0; % Delete the current pixel.
					end
				elseif(length(Fr1) > 1) % More than one point in the neighborhood.					
					% [Ry1,Rx1] = ind2sub([Im_Rows,Im_Cols],Fr1); % Conversion of all neighborhood pixels to subscripts.
					% D10 = ((Rx1-Rx2).^2 + (Ry1-Ry2).^2).^.5; % The distance from each new pixel to the current pixel.
					D10 = (((Rx2-Rx0).^2 + (Ry2-Ry0).^2).^.5)'; % The distance from each new pixel to the current pixel.
                    
                    % for d=1:length(Ry1) % For each potential next pixel.
					for d=1:length(Ry2) % For each potential next pixel.
						D10(2,d) = length(find([Vertices.Coordinate] == Fr1(d))); % Check if it's a branch-point.
                    end
					
					F1 = find(D10(2,:) == 1); % Find which of the potential next-points are branch-points.
					if(length(F1)) % If there is at least 1 branch-point. Take the first value (there should be only one).
						Segments(Si).Vertices(2) = Vertices(find([Vertices.Coordinate] == Fr1(F1(1)))).Vertex_Index; % Find the vertex with the same coordinate.
						if(Messages)	
							disp('Let me know if you detect more than one branch-point in one neighborhood');
						end
						break;
					else % If the array does not contain any branch-point.
						F2 = find(D10(1,:) == min(D10(1,:)));
						Fr1 = Fr1(F2(1)); % Taking F2(*1*) just in case there's more than one option (should not occur).
						Segments(Si).Skeleton_Linear_Coordinates(end+1) = Fr1;
						Im1_NoiseReduction(Fr1) = 0; % Delete the current pixel.
						if(Messages && length(F2) > 1)
							disp('F2 should always have a single value. Let me know if it does not');
						end
					end
				else % No new pixels in the neighborhood (length(Fr1) == 0 from the first place).
					% Check if it's a loop:
					[Ry1,Rx1] = find(Im1_NoiseReduction(Ry0-1:Ry0+1,Rx0-1:Rx0+1) == -1); % (-1) are pixels connected to a branch-point. Find the pixels connected to the pixel (excluding the deleted current pixel).
					[Cy1,Cx1] = find(Im1_branchpoints(Ry0-1:Ry0+1,Rx0-1:Rx0+1)); % Find the pixels connected to the pixel (excluding the deleted current pixel).
					if(length(Cy1)) % Loop test.
						if(length(Cy1) > 1) % If more than branch-point was found, just take the first.
							Cx1 = Cx1(1);
							Cy1 = Cy1(1);
							if(Messages)
								disp(['I am probably in a loop but I found two possible ending branch-points. I am taking the first option. Segment ',num2str(Si),'.']);
							end
						end						
						Cy2 = Cy1 + Ry0 - 2; % Conversion of the small frame to the coordinates of the full image.
						Cx2 = Cx1 + Rx0 - 2; % ".
						Fr1 = Im_Rows*(Cx2-1)+Cy2; % Conversion to linear indices.
						Segments(Si).Vertices(2) = Vertices(find([Vertices.Coordinate] == Fr1)).Vertex_Index; % Find the vertex with the same coordinate.
						if(Messages)
							disp('It is a Loop!');
						end
						break;
					elseif(length(Ry1)) % This must come after looking for a branch-point (1st if, same level). Because a point might be connected to both a branch-point and a -1 point which belongs to a different segment.
						Ry2 = Ry1 + Ry0 - 2; % Conversion of the small frame to the coordinates of the full image.
						Rx2 = Rx1 + Rx0 - 2; % ".
						Fr1 = Im_Rows*(Rx2-1)+Ry2; % Conversion to linear indices.
						Segments(Si).Skeleton_Linear_Coordinates(end+1) = Fr1(1); % Taking 1st just in case there's more than one option (should not occur).
						Im1_NoiseReduction(Fr1) = 0; % Delete the current pixel.
						if(Messages && length(Fr1) > 1)
							disp('More than 1 coordinate found (1). Taking the 1st (arbitrarily). TODO: check why this happens.');
						end
						if(Messages)
							disp('You are probably going to have a Loop...');
						end
					else
						Segments(Si).Vertices(2) = -1;
						if(Messages)
							disp(['The array of neighborhood pixels was empty. Segment ',num2str(Si)]);
						end
						break;
					end
				end
				if(Messages && length(Fr1) > 1)
					disp('More than 1 coordinate found (2). Taking the 1st (arbitrarily). TODO: check why this happens.');
					% TODO: I sometimes get a cencentration of pixels in junctions. This should be prevented during
						% the generation of the skeleton.
				end
				Fr1 = Fr1(1);
				[Ry0,Rx0] = ind2sub([Im_Rows,Im_Cols],Fr1);
			end
		end
	end
	
	Vertices = Vertices(1:Vi); % Delete extra rows.
	Segments = Segments(1:Si); % Delete extra rows.
	
	for v=1:numel(Vertices) % Convert linear index to subscripts.
		[I,J] = (ind2sub([Im_Rows,Im_Cols],Vertices(v).Coordinate));
		Vertices(v).Coordinate = [J,I];
	end
	
	% TODO: instead of merging, just use the skeleton to trace the short segment and find the relevant angles (and update the order accordingly).
	% Merge close vertices:
	V = [Segments.Vertices];
	V1 = V(1:2:end);
	V2 = V(2:2:end);
	for v=1:numel(Vertices)
		I = zeros(0,4); % [index,x,y,order].
		if(Vertices(v).Order == 1)
			continue; % Don't merge tips.
		end
		for v1=1:numel(Vertices)
			if(Vertices(v1).Order == 1)
				continue; % Don't merge tips.
			end
			D = ((Vertices(v).Coordinate(1) - Vertices(v1).Coordinate(1))^2 + (Vertices(v).Coordinate(2) - Vertices(v1).Coordinate(2))^2)^.5;
			if(D <= BP_Min_Dis)
				I(end+1,:) = [v1,Vertices(v1).Coordinate,Vertices(v1).Order];
			end
		end
		if(size(I,1) > 1) % One element means that it is only vertex v compared to itself.
			Vertices(I(1,1)).Coordinate = [mean(I(:,2)),mean(I(:,3))];
			Vertices(I(1,1)).Order = sum(I(:,4)) - 2*(size(I,1)-1);
			[Vertices(I(2:end,1)).Vertex_Index] = deal(0);
			for i=2:size(I,1) % For each redundant vertex.
				% Update the vertices changes in the Segments struct.
				% Assuming each segment is assigned with exactly 2 vertices.
				for j=find(V1 == I(i,1))
					if(Segments(j).Vertices(2) == I(1,1)) % If the short segment will have the same vertex as v1 & v2, mark it for deletion.
						Segments(j).Segment_Index = 0;
					else
						Segments(j).Vertices(1) = I(1,1);
					end
				end
				for j=find(V2 == I(i,1))
					if(Segments(j).Vertices(1) == I(1,1)) % If the short segment will have the same vertex as v1 & v2, mark it for deletion.
						Segments(j).Segment_Index = 0;
					else
						Segments(j).Vertices(2) = I(1,1);
					end
				end
			end
		end
	end
	Vertices(find([Vertices.Vertex_Index] == 0)) = [];
	Segments(find([Segments.Segment_Index] == 0)) = [];
	% TODO: delete the segments that are supposed to be deleted.
	
	% ColorMap = jet(20);
	% imshow(Im1_NoiseReduction);
	% hold on;
	% for s=1:numel(Segments)
		% [Py,Px] = ind2sub([Im_Rows,Im_Cols],Segments(s).Skeleton_Linear_Coordinates);
		% plot(Px,Py,'.','MarkerSize',15,'Color',rand(1,3));
		
		% Rads = Im_Skel_Rad(Segments(s).Skeleton_Linear_Coordinates)+1;
		% scatter(Px,Py,Rads,ColorMap(Rads,:)); % rand(1,3)
		
		% hold on;
		% scatter(Px,Py,[],rand(1,3)); %
		% plot(Bx,By,'or','MarkerSize',20);
	% end
	% assignin('base','Segments',Segments);
	% assignin('base','Vertices',Vertices);
end