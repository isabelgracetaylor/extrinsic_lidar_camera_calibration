function  [delta, plane] = estimateIntrinsicSpherical(num_beams, num_targets, num_scans, data_split_with_ring, data_split_with_ring_raw)
    delta(num_beams).D = struct();
    delta(num_beams).theta = struct();
    delta(num_beams).phi = struct();
    %%
    for i = 1: num_scans
        % Calculate 'ground truth' points by projecting the angle onto the
        % normal plane
        %
        % Assumption: we have the normal plane at this step in the form:
        % plane_normal = [nx ny nz]

        % example normal lies directly on the x axis
        opt.corners.rpy_init = [45 2 3];
        opt.corners.T_init = [2, 0, 0];
        opt.corners.H_init = eye(4);
        opt.corners.method = "Constraint Customize"; %% will add more later on
        opt.corners.UseCentroid = 1;

        plane = cell(1,num_targets);
        for t = 1:num_targets
            X = [];
            for j = 1: num_beams
                X = [X,data_split_with_ring_raw{t}(j).points];
            end
            [plane{t}, ~] = estimateNormal(opt.corners, X(1:3, :), 0.8051);
        end

        opt.delta.D_corr_init = 0;
        opt.delta.theta_corr_init = 0;
        opt.delta.phi_corr_init = 0;
        delta = estimateDeltaSpherical(opt.delta, data_split_with_ring, plane, delta(num_beams), num_beams, num_targets);
    end

end