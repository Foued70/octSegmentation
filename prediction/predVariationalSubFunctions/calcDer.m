% calc terms described as $\tilde{p}_{j,k}$ in the paper
% P for Sigma is the same as P for mu

if collector.options.printTimings
	calcDerTic = tic;
end

p_mu = eval(sprintf('zeros(1,numColumnsShapeTotal*numBounds,%s);',collector.options.dataType));

for volRegion = 1:numVolRegions
	idx = 1:numRows;
	idx = idx(ones(1,numColumnsShape(volRegion)),:);
	for k = 1:numBounds
		columns = (1:numColumnsShape(volRegion)) + (k-1)*numColumnsShape(volRegion) + sum(numColumnsShape(1:volRegion-1))*numBounds;
		if collector.options.calcOnGPU
			factor = GPUsingle((sum(squeeze(q_c.singleton(volRegion,columnsShapePred{volRegion},k,:)).*idx,2) - models.shapeModel.mu(columns))./sigma_tilde_squared(columns)');
		else
			factor = (sum(squeeze(q_c.singleton(volRegion,columnsShapePred{volRegion},k,:)).*idx,2) - models.shapeModel.mu(columns))./sigma_tilde_squared(columns)';
		end
		p_mu = p_mu + factor'*A_k(columns,:);
	end
end

if collector.options.printTimings
    if collector.options.calcOnGPU
        GPUsync;
    end
	fprintf('[calcDer]: %.3fs\n',toc(calcDerTic));
end
