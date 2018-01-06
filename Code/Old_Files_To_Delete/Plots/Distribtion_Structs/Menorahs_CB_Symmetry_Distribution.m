function Struct1 = Menorahs_CB_Symmetry_Distribution(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for m=1:numel(Workspace1.Menorahs)
		
		if(Workspace1.Menorahs(m).IsMenorah && Workspace1.Menorahs(m).Total_Length > 0) % If it has at least one branch of order >= 3 AND has a neighbor.
			
			% Positive values mean that the part closer to the CB is longer:
			if(Workspace1.Menorahs(m).Primary_Arc_Distance_From_CB > 0) % Anterior menorah.
				Struct1(end+1).Property = (Workspace1.Menorahs(m).Posterior_Length - ...
					Workspace1.Menorahs(m).Anterior_Length) / Workspace1.Menorahs(m).Total_Length; % The distance from its anterior neighbor.
			else % Posterior Menorah.
				Struct1(end+1).Property = (Workspace1.Menorahs(m).Anterior_Length - ...
					Workspace1.Menorahs(m).Posterior_Length) / Workspace1.Menorahs(m).Total_Length; % The distance from its anterior neighbor.
			end
			Struct1(end).Order = 0;
			Struct1(end).Weight = 1;
			Struct1(end).Dorsal_Ventral = Workspace1.Menorahs(m).Dorsal_Ventral;
			
		end
	end
end