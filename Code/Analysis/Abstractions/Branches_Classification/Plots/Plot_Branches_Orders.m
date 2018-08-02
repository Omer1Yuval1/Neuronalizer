function Plot_Branches_Orders(Workspace)
	
	% This function plots the branches overlayed on the original grayscale image.
	
	cmap = colormap(jet);
	rows = randi(size(cmap,1),[numel(Workspace.Branches),1]);
	
	imshow(Workspace.Image0);
	hold on;
	for b=1:numel(Workspace.Branches)
		switch(Workspace.Branches(b).Order)
			case 1
				C = [.3,.3,.3];
			case 2
				C = [.8,0,0];
			otherwise
				C = cmap(rows(b),:);
		end
		for si = [Workspace.Branches(b).Segments]
			sr = find([Workspace.Segments.Segment_Index] == si);
			if(~isempty(sr))
				plot(Workspace.Segments(sr).Skel_X,Workspace.Segments(sr).Skel_Y,'Color',C,'linewidth',3);
			end
		end
	end
	hold off;
	set(gca,'YDir','normal');
end
