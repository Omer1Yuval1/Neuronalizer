function Branches = construct_branches(Workspace,Curvature_Threshold)
	
	% This function constructs Branches from segments.
    
	% TODO: add the reduced segments.
	
    Branches = probability_scores(Workspace,Curvature_Threshold);
	
	Branches = Merge_Segments(Branches);
	
	% return;
	Branches = rmfield(Branches,{'Segment_Index_1','Segment_Index_2','Merged','Score','Probabilities','angle_average','vertex_angle',...
									'chunk_orientation'});
	
	[Branches.Branch_Index] = deal(0);
	[Branches.Delete] = deal(0);
	
	b1 = 0;
	while(b1 < numel(Branches)-1)
		for b1=1:numel(Branches)-1
			for b2=b1+1:numel(Branches) % (b1+1) because we can assume that previous branches were considered in earlier values of b1.
				if(any(ismember(Branches(b1).Segments,Branches(b2).Segments))) % Check whether the two branches share one of their segments.
					Branches(b1).Segments = unique([Branches(b1).Segments,Branches(b2).Segments]);
					Branches(b1).Vertices = unique([Branches(b1).Vertices,Branches(b2).Vertices]);
					Branches(b2).Delete = 1;
					
					% disp([Branches(b1).Vertices,Branches(b2).Vertices]);
				end
			end
			F = find([Branches.Delete] == 1);
			if(~isempty(F))
				Branches(F) = []; % Delete rows that were merged with another row.
				break; % If any rows were deleted, break the for loop so that numel(Branches) updates.
			end % If no rows were deleted, just continue to the next branch.
		end
	end
	
	for i=1:numel(Branches)
		Branches(i).Branch_Index = i;
		% Branches(i).Segments = unique(Branches(i).Segments);
	end
	
	Branches = rmfield(Branches,{'Delete'});
	
	%}
	
	% TODO: adapt add_segments functions so that deleted segments are merged to the correct branch
	% Deleted_Segments = Workspace.Segments(find([Workspace.Segments.Delete] == -1));
	% Branches = add_segments(Branches,Deleted_Segments);
end