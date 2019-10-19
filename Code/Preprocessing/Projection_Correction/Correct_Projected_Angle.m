function Corrected_Angle = Correct_Projected_Angle(A,A0,At)
	
	% This function...
	% All angles are given in radians.
	% A is the angle to be corrected (radians) of the rectangle, pointing from the vertex center outside.
	% A0 is the reference angle (of the corresponding midline point).
	% At is the local tilting angle of the plane in the midline coordinates system (the midline is the new x-axis).
		% This local tilted plane intersects with the X-Y plane at the vertex center and the midline axis.
		% This means that on the upper side of the junction (positive midline distance) it goes inside the screen, and on the lower side it comes outside.
		% The vertex center is the rotation origin for rotation around the midline axis.
		
	% Algorithm:
		% 1. Translate the vertex center to the origin [0,0].
		% 2. Find the z-value of the vector on the plane.
			% The plane can be represented by two vectors that lie on it.
			% The tangent is v1. v2 is perpendicular to it in X-Y, and rotated around the tangent to the tilted plane.
			% N = cross(v1,v2); % Normal to the plane.
			% v0 is the rectangle vector.
			% alpha = abs( pi/2 - acos( dot(v0, N)/norm(N)/norm(v0) ) );
		% 3. rotate it back to the X-Y plane by rotating aroung the midline only (use axis-angle representation).
		% 4. 
	
	% The projection always makes the angle smaller than it realy is. The angle is the smallest diff between the rectangle and midline orientation within [0,pi/2].
	% In other words, the orientation of the rectangle relative to the midline always increases as a result of the correction.
	% The bigger the angle ([0,pi/2]), the bigger the y-component and the bigger the tilting angle from the origin of the vetex, but also the smaller the x-component.
	% Altogether, the peak of the error is at pi/4 (45 degrees).
	
	Vt = [cos(A0),sin(A0),0]; % The tangent vector.
	
	% TODO: check if this needs to be normalized:
	Rt = axang2rotm([Vt,At]); % [x,y,z,a]. Axis-angle form.
	Vt_N = transpose(Rt * transpose([cos(At+pi/2),sin(At+pi/2),0])); % Rotate to get another vector that lies on the tilted plane.
	Nt = cross(Vt,Vt_N); % Normal vector to the tilted plane.
	
	Vr = [cos(A),sin(A),0]; % The vector of the rectangle to be corrected.
	Dz = dot(Nt,Vr) ./ norm(Nt); % The signed distance between the end of the vector and the tilted plane.
	
	Vr_M = [Vr(1),Vr(2),Dz]; % The reconstructed vector (with origin at 0) that lies on the tilted plane.
	
	Vr_M_XY = transpose(transpose(Rt) * transpose(Vr_M)); % Rotate back to the XY plane around the midline vector.
	
    Corrected_Angle = atan2(Vr_M_XY(2),Vr_M_XY(1)); % Assuming Vr_M_XY's origin is at [0,0].
    
	%{
	
	% Find the angle difference between the rectangle (A) and the midline (A0):
		% First convert the angles to be within [0,pi]:
		A0_90 = mod(A0,pi);
		A_90 = mod(A,pi);
		
		dA = max(A0_90,A_90) - min(A0_90,A_90); % Positive angle difference (the result is within [0,pi]).
		
		% Find the angle difference between the rectangle and midline orientation, within [0,pi/2], and the corresponding vector:
		d90 = pi/2 - abs(pi/2 - dA); % The angle from 0 within [0,pi/2].
		Vp = [cos(d90),sin(d90),0];
		
		% tan(At) = Lz / Ly (the hypotenuse of the triangle lies on the tilted plane):
		Lz = Vp(2) .* tan(At); % The z-component that is missing in the projection.
		
		Vr_M = [Vp(1),Vp(2),Lz]; % The reconstructed vector (with origin at 0) that lies on the tilted plane.
		
		% Finally, rotate the 3D vector back to the XY plane using x-rotation only (corresponds to midline rotation):
		Vr_M_XY = Vr_M * rotx(At*180/pi); % Now that the cartesian x-axis equals to the medial axis, rotate around x to get the 3D vector in the XY* plane.
		
		Axy = atan2(Vr_M_XY(2) , Vr_M_XY(1)) - atan2(Vp(2) , Vp(1)); % The angle correction factor (additive). [0,pi/2].
		
		% Find the signed angle diff (in 2D) between the original vector (Vp) and the projected-and-rotated vector (Vr_M_XY):
		% d = Axy - A0;
		
		% Finally, apply the difference (d) to the original rectangle angle:
		Corrected_Angle = A + Axy;
		
		
		
		% The angle between the vectors has to increase (get closer to 90).
		
		d1 = max(A0,A) - min(A0,A);
		d2 = min(d1,2*pi - d1);
	%}
end