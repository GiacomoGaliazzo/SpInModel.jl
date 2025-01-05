

function SpInModelCalibration(prm::SpInModelConfig, data::DataFrame)

    flag_full_matrix::Bool = true

    _ret::SpInResult = SpInResult(false, "init", NaN, Array{SpInModelStatistic}(undef, 0), Array{SpInData}(undef, 0), Float64(0.0), Float64(0.0),"")

    inputdata::Vector{SpInData} = Vector{SpInData}(undef, 0)

    if prm.includeinnerflow
        inputdata = Vector{SpInData}(undef, nrow(data))
    end

    for i in 1:nrow(data)

        cost = data.cost[i]
        flow = data.flow[i]

        if prm.setminimumdatavalue
            if !prm.includeinnerflow
                if data.from[i] != data.to[i]
                    cost = cost > prm.minimumcost ? cost : prm.minimumcost
                    flow = flow > prm.minimumflow ? flow : prm.minimumflow
                    push!(inputdata, SpInData(data.from[i], data.to[i], cost, flow, 0.0, 0.0, 0.0, 0.0))
                end
            else
                cost = cost > prm.minimumcost ? cost : prm.minimumcost
                flow = flow > prm.minimumflow ? flow : prm.minimumflow
                inputdata[i] = SpInData(data.from[i], data.to[i], cost, flow, 0.0, 0.0, 0.0, 0.0)
            end
        else 
            if !prm.inlcudeinnerflow
                if data.from[i] != data.to[i]
                    push!(inputdata, SpInData(data.from[i], data.to[i], cost, flow, 0.0, 0.0, 0.0, 0.0))
                end
            else
                inputdata[i] = SpInData(data.from[i], data.to[i], cost, flow, 0.0, 0.0, 0.0, 0.0)
            end
        end
    end

    spin_dict = Dict()
    origin_dict = Dict{String, Vector{SpInData}}()
    destination_dict = Dict{String, Vector{SpInData}}()
    for s in inputdata

        if !haskey(spin_dict, (s.origin, s.destination))
            spin_dict[(s.origin, s.destination)] = s
        else
            _ret = SpInResult(false, "duplicate vector", NaN, Array{SpInModelStatistic}(undef, 0), [s], Float64(0.0), Float64(0.0), "")
            return _ret
        end

        if !haskey(origin_dict, s.origin)
            origin_dict[s.origin] = [s]  
        else
            push!(origin_dict[s.origin], s) 
        end

        if !haskey(destination_dict, s.destination)
            destination_dict[s.destination] = [s]  
        else
            push!(destination_dict[s.destination], s) 
        end

    end


    if prm.model == DoublyConstrained
        node_unique = sort(unique(vcat([s.origin for s in inputdata]..., [s.destination for s in inputdata]...)))
        node_index = Dict(node => idx for (idx, node) in enumerate(node_unique))
        total_node = length(node_unique)

        A = zeros(Float64, total_node)
        previous_A = zeros(Float64, total_node)
    
        B = zeros(Float64, total_node)
        previous_B = zeros(Float64, total_node)

        SecondArray = zeros(Float64, total_node, total_node)
        full_matrix_flow = zeros(Float64, total_node, total_node)
        full_matrix_time = zeros(Float64, total_node, total_node)
            
        origindistinct = zeros(Float64, total_node)
        destinationdistinct = zeros(Float64, total_node)
    
   

        modelformulastring::Array{String} = Vector{String}(undef, 0)
        
        
        beta_stable::Bool = false
            
        
        previous_C_::Float64 = Float64(0.0)
            
        Flow_estimate = zeros(Float64, total_node, total_node)
        first_sumflows::Float64 = Float64(0.0)
        sumflows::Float64 = Float64(0.0)
            
        
        delta_beta::Float64 = Float64(0.0)
        delta_C_::Float64 = Float64(0.0)
        delta_Flow_estimate = zeros(Float64, total_node, total_node)
        delta_sumflows::Float64 = Float64(0.0)
        delta_error::Float64 = Float64(0.0)

        convergenceouter1::Float64 = NaN
        convergenceinner1::Float64 = NaN

        datamatrix = Array{Float64}(undef, total_node, total_node, 2);

        sumorigin = Vector{Float64}(undef, total_node);
        sumdestination = Vector{Float64}(undef, total_node);

        for i in 1:total_node
            from_origin = get(origin_dict, node_unique[i], [])
            if length(from_origin) == 0
                if prm.fillmissingdata
                    sumorigin[i] = prm.fillmissingflow * total_node
                    for j in 1:total_node
                        datamatrix[i,j,1] = prm.fillmissingcost
                        datamatrix[i,j,2] = prm.fillmissingflow
                        sumdestination[j] += prm.fillmissingflow
                    end
                else
                    flag_full_matrix = false
                    sumorigin[i] = Float64.NaN
                    for j in 1:total_node
                        datamatrix[i,j,1] = Float64.NaN
                        datamatrix[i,j,2] = Float64.NaN
                    end
                end
            else
                for j in 1:total_node
                    from_origin_index = findfirst(x -> x.destination == node_unique[j], from_origin)
                    if isnothing(from_origin_index)
                        if prm.fillmissingdata
                            datamatrix[i,j,1] = prm.fillmissingcost
                            datamatrix[i,j,2] = prm.fillmissingflow
                            sumorigin[i] += prm.fillmissingflow
                            sumdestination[j] += prm.fillmissingflow
                        else
                            flag_full_matrix = false
                            datamatrix[i,j,1] = Float64.NaN
                            datamatrix[i,j,2] = Float64.NaN
                        end
                    else 
                        datamatrix[i,j,1] = from_origin[from_origin_index].cost
                        datamatrix[i,j,2] = from_origin[from_origin_index].flow
                        sumorigin[i] += from_origin[from_origin_index].flow
                        sumdestination[j] += from_origin[from_origin_index].flow
                    end
                end
            end
        end

        A = zeros(Float64, total_node)
        previous_A = zeros(Float64, total_node)
        B = ones(Float64, total_node)
        previous_B = ones(Float64, total_node)

        first_beta::Float64 = Float64(0.0)
        first_C_::Float64 = Float64(0.0)
        _C_::Float64 = Float64(0.0)
        beta::Float64 = Float64(0.0)
        first_Ratio_C_sumflow::Float64 = Float64(0.0)
        delta_increase::Float64 = Float64(1.0) / exp(20)
        previous_beta::Float64 = Float64(0.0)
        innerloopdyn::Int64 = 0
        outerloopdyn::Int64 = 0
        sumsA::Float64 = 0.0
        sumsB::Float64 = 0.0
        sumabsA::Float64 = 0.0
        sumabsB::Float64 = 0.0

        _infinite::Bool = false
        _issubnormal::Bool = false
        _isfinite::Bool = false
        
        if prm.useSIModelMethod
            if flag_full_matrix
                for i in 1:total_node
                    for j in 1:total_node
                        first_C_ += datamatrix[i,j,1] * datamatrix[i,j,2]
                        first_sumflows += datamatrix[i,j,2]
                    end
                end
            else
                for i in 1:total_node
                    for j in 1:total_node
                        if !isnan(datamatrix[i,j,1]) && !isnan(datamatrix[i,j,2])
                            first_C_ += datamatrix[i,j,1] * datamatrix[i,j,2]
                            first_sumflows += datamatrix[i,j,2]
                        end
                    end
                end
            end
        else
            for i in 1:length(inputdata)
                first_C_ += inputdata[i].cost * inputdata[i].flow
            end
        end

        if prm.startingValueType == "SimodelEvaluation"
            if prm.useSIModelMethod
                first_beta = Float64(3.0) / (Float64(2.0) * first_C_ )
            elseif prm.formula == Exponential
                first_beta = first_sumflows / first_C_ 
            else
                first_beta = Float64(0.75)
            end
        else
            first_beta = customBetaInput
        end

        #=
            for j in 1:total_node
                B[j] = 1; A[j] = 0;
            end
        =#
        
        Nocriteriumget::Bool = true; outerloopdyn = Int64(0); ExternalLoop::Bool = true; Noexitbymaximumloop::Bool = true;
        overFlowCalc::Bool = false;
        while(ExternalLoop)
            outerloopdyn += 1;
            println("outerloopdyn: ", outerloopdyn)
            if outerloopdyn == 1
                beta = first_beta; _C_ = first_C_;
                if prm.useSIModelMethod
                    sumflows = first_sumflows
                    first_Ratio_C_sumflow = first_C_ / first_sumflows
                    delta_increase =  Float64(1.0) / exp(20)
                else
                    sumflows = 0;
                    first_Ratio_C_sumflow = 0;
                end
            end

            innerloopdyn = 0
            Nocriteriumget = true; 
            Noexitbymaximumloop = true;

            B .= 1; 
            A .= 0;

            while (Nocriteriumget && Noexitbymaximumloop && !overFlowCalc)

                # inner loop

                innerloopdyn += 1
                println("253 innerloopdyn: ", innerloopdyn)
                if prm.formula == Exponential
                    if flag_full_matrix
                        for i in 1:total_node
                            previous_A[i] = A[i]; A[i] = 0;
                            for j in 1:total_node
                                A[i] = A[i] + (B[j] * sumdestination[j] * exp(-beta * datamatrix[i,j,1]))
                            end
                            if A[i] != 0
                                A[i] = 1 / A[i]
                            end
                        end
                    else
                        for i in 1:total_node
                            previous_A[i] = A[i]; A[i] = 0;
                            for j in 1:total_node
                                if !isnan(datamatrix[i,j,1]) 
                                    A[i] = A[i] + (B[j] * sumdestination[j] * exp(-beta * datamatrix[i,j,1]))
                                end
                            end
                            if A[i] != 0
                                A[i] = 1 / A[i]
                            end
                        end
                    end
                    if flag_full_matrix
                        for j in 1:total_node
                            previous_B[j] = B[j]; B[j] = 0;
                            for i in 1:total_node
                                B[j] = B[j] + (A[i] * sumorigin[i] * exp(-beta * datamatrix[i,j,1]))
                            end
                            if B[j] != 0
                                B[j] = 1 / B[j]
                            end
                        end
                    else
                        for j in 1:total_node
                            previous_B[j] = B[j]; B[j] = 0;
                            for i in 1:total_node
                                if !isnan(datamatrix[i,j,1]) 
                                    B[j] = B[j] + (A[i] * sumorigin[i] * exp(-beta * datamatrix[i,j,1]))
                                end
                            end
                            if B[j] != 0
                                B[j] = 1 / B[j]
                            end
                        end
                    end

                    sumabsA = sum(abs.(A .- previous_A))
                    sumabsB = sum(abs.(B .- previous_B))

                    #=
                    for i in 1:total_node
                        sumabsA += Math.Abs(A[i] - previous_A[i]);
                        sumabsB += Math.Abs(B[i] - previous_B[i]);
                    end
                    =#
                    
                    if sumabsA <= prm.innerloopconstr && sumabsB <= prm.innerloopconstr
                        Nocriteriumget = false
                    end
                    if innerloopdyn >= prm.innerloopvalue
                        Noexitbymaximumloop = false
                    end
                    sumsA = sumabsA; sumsB = sumabsB;

                    _infinite = isinf(sumsA) || isinf(sumsB)
                    _issubnormal = issubnormal(sumsA) || issubnormal(sumsB)
                    _isfinite = isfinite(sumsA) && isfinite(sumsB)

                    if !(_isfinite && !_infinite && !_issubnormal )
                        overFlowCalc = true;
                    end
                elseif prm.formula == Power
                    if flag_full_matrix
                        for i in 1:total_node
                            previous_A[i] = A[i]; A[i] = 0;
                            for j in 1:total_node
                                A[i] = A[i] + (B[j] * sumdestination[j] * (datamatrix[i,j,1] ^ -beta ))
                            end
                            if A[i] != 0
                               A[i] = 1 / A[i]
                            end
                        end
                    else
                        for i in 1:total_node
                            previous_A[i] = A[i]; A[i] = 0;
                            for j in 1:total_node
                                if !isnan(datamatrix[i,j,1]) 
                                    A[i] = A[i] + (B[j] * sumdestination[j] * (datamatrix[i,j,1]^ -beta))
                                end
                            end
                            if A[i] != 0
                                    A[i] = 1 / A[i]
                            end
                        end
                    end
                    if flag_full_matrix
                        for j in 1:total_node
                            previous_B[j] = B[j]; B[j] = 0;
                            for i in 1:total_node
                                B[j] = B[j] + (A[i] * sumorigin[i] * (datamatrix[i,j,1]^ -beta))
                            end
                            if B[j] != 0
                               B[j] = 1 / B[j]
                            end
                        end
                    else
                        for j in 1:total_node
                            previous_B[j] = B[j]; B[j] = 0;
                            for i in 1:total_node
                                if !isnan(datamatrix[i,j,1]) 
                                    B[j] = B[j] + (A[i] * sumorigin[i] * (datamatrix[i,j,1]^ -beta))
                                end
                            end
                            if B[j] != 0
                                B[j] = 1 / B[j]
                            end
                        end
                    end
    
                    sumabsA = sum(abs.(A .- previous_A))
                    sumabsB = sum(abs.(B .- previous_B))
    
                    #=
                        for i in 1:total_node
                            sumabsA += Math.Abs(A[i] - previous_A[i]);
                            sumabsB += Math.Abs(B[i] - previous_B[i]);
                        end
                    =#
                        
                    if sumabsA <= prm.innerloopconstr && sumabsB <= prm.innerloopconstr
                        Nocriteriumget = false
                    end
                    if innerloopdyn >= prm.innerloopvalue
                        Noexitbymaximumloop = false
                    end
                    sumsA = sumabsA; sumsB = sumabsB;
    
                    _infinite = isinf(sumsA) || isinf(sumsB)
                    _issubnormal = issubnormal(sumsA) || issubnormal(sumsB)
                    _isfinite = isfinite(sumsA) && isfinite(sumsB)
    
                    if !(_isfinite && !_infinite && !_issubnormal )
                        overFlowCalc = true;
                    end
                else

                end

                # end inner loop
            end

            #Flow_estimate .= 0.0  

            if prm.formula == Exponential
                if flag_full_matrix

                    Flow_estimate .= (A .* sumorigin) * (B .* sumdestination)' .* exp.(-beta .* datamatrix[:, :, 1])

                    #=
                    for i in 1:total_node
                        for j in 1:total_node
                            Flow_estimate[i, j] = A[i] * sumorigin[i] * B[j] * sumdestination[j] * Math.Exponential(-beta * datamatrix[i,j,1])
                        end
                    end
                    =#

                else

                    Flow_estimate = [(!isnan(datamatrix[i, j, 1]) ? A[i] * sumorigin[i] * B[j] * sumdestination[j] * exp(-beta * datamatrix[i, j, 1]) : 0.0)
                                        for i in 1:total_node, j in 1:total_node]

                    #=                                        
                    for i in 1:total_node
                        for j in 1:total_node
                            if !isnan(datamatrix[i,j,1]) 
                                Flow_estimate[i, j] = A[i] * sumorigin[i] * B[j] * sumdestination[j] * Math.Exponential(-beta * datamatrix[i,j,1])
                            end
                        end
                    end
                    =#

                end
            elseif prm.formula == Power
                if flag_full_matrix

                    Flow_estimate .= (A .* sumorigin) * (B .* sumdestination)' .* datamatrix[:, :, 1] .^ -beta

                    #=
                    for i in 1:total_node
                        for j in 1:total_node
                            Flow_estimate[i, j] = A[i] * sumorigin[i] * B[j] * sumdestination[j] * Math.Power(datamatrix[i,j,0], -beta)
                        end
                    end
                    =#

                else

                    Flow_estimate = [(isfinite(datamatrix[i, j, 1]) ? A[i] * sumorigin[i] * B[j] * sumdestination[j] * datamatrix[i, j, 1] ^ -beta : 0.0)
                                        for i in 1:total_node, j in 1:total_node]

                    #=                                        
                    for i in 1:total_node
                        for j in 1:total_node
                            if !isnan(datamatrix[i,j,0]) 
                                Flow_estimate[i, j] = A[i] * sumorigin[i] * B[j] * sumdestination[j] * Math.Power(datamatrix[i,j,0], -beta)
                            end
                        end
                    end
                    =#

                end
            else

            end

            previous_C_ = _C_; _C_ = 0; sumflows = 0;
            previous_beta = beta;

            if prm.useSIModelMethod
                if flag_full_matrix

                    _C_ = sum(datamatrix[:,:,1] .* Flow_estimate)
                    sumflows = sum(Flow_estimate)
                else

                    _C_ = sum(datamatrix_[:,:,1] .* Flow_estimate .* (isfinite.(Flow_estimate) .& isfinite.(datamatrix_[:,:,1])))
                    sumflows = sum(Flow_estimate .* (isfinite.(Flow_estimate) .& isfinite.(datamatrix_[:,:,1])) )

                end

                if !isfinite(_C_)
                    overFlowCalc = true
                    ExternalLoop = false
                end

                Ratio_C_sumflow::Float64 = _C_ / sumflows

                if abs(first_Ratio_C_sumflow - Ratio_C_sumflow) <= prm.outerloopconstr || outerloopdyn >= prm.outerloopvalue
                    ExternalLoop = false
                else
                    beta = beta + delta_increase

                    innerloopdyn = 0; Noexitbymaximumloop = true; Nocriteriumget = true; overFlowCalc = false;

                    A .= 0;
                    B .= 1; 

                    while (Nocriteriumget && Noexitbymaximumloop && !overFlowCalc)

                        # inner loop
        
                        innerloopdyn += 1
                        println("508 innerloopdyn: ", innerloopdyn)
                        if prm.formula == Exponential
                            if flag_full_matrix
                                for i in 1:total_node
                                    previous_A[i] = A[i]; A[i] = 0;
                                    for j in 1:total_node
                                        A[i] = A[i] + (B[j] * sumdestination[j] * exp(-beta * datamatrix[i,j,1]))
                                    end
                                    if A[i] != 0
                                        A[i] = 1 / A[i]
                                    end
                                end
                            else
                                for i in 1:total_node
                                    previous_A[i] = A[i]; A[i] = 0;
                                    for j in 1:total_node
                                        if !isnan(datamatrix[i,j,1]) 
                                            A[i] = A[i] + (B[j] * sumdestination[j] * exp(-beta * datamatrix[i,j,1]))
                                        end
                                    end
                                    if A[i] != 0
                                        A[i] = 1 / A[i]
                                    end
                                end
                            end
                            if flag_full_matrix
                                for j in 1:total_node
                                    previous_B[j] = B[j]; B[j] = 0;
                                    for i in 1:total_node
                                        B[j] = B[j] + (A[i] * sumorigin[i] * exp(-beta * datamatrix[i,j,1]))
                                    end
                                    if B[j] != 0
                                        B[j] = 1 / B[j]
                                    end
                                end
                            else
                                for j in 1:total_node
                                    previous_B[j] = B[j]; B[j] = 0;
                                    for i in 1:total_node
                                        if !isnan(datamatrix[i,j,1]) 
                                            B[j] = B[j] + (A[i] * sumorigin[i] * exp(-beta * datamatrix[i,j,1]))
                                        end
                                    end
                                    if B[j] != 0
                                        B[j] = 1 / B[j]
                                    end
                                end
                            end
        
                            sumabsA = sum(abs.(A .- previous_A))
                            sumabsB = sum(abs.(B .- previous_B))
        
                            #=
                            for i in 1:total_node
                                sumabsA += Math.Abs(A[i] - previous_A[i]);
                                sumabsB += Math.Abs(B[i] - previous_B[i]);
                            end
                            =#
                            
                            if sumabsA <= prm.innerloopconstr && sumabsB <= prm.innerloopconstr
                                Nocriteriumget = false
                            end
                            if innerloopdyn >= prm.innerloopvalue
                                Noexitbymaximumloop = false
                            end
                            sumsA = sumabsA; sumsB = sumabsB;
        
                            _infinite = isinf(sumsA) || isinf(sumsB)
                            _issubnormal = issubnormal(sumsA) || issubnormal(sumsB)
                            _isfinite = isfinite(sumsA) && isfinite(sumsB)
        
                            if !(_isfinite && !_infinite && !_issubnormal )
                                overFlowCalc = true;
                            end
                        elseif prm.formula == Power
                            if flag_full_matrix
                                for i in 1:total_node
                                    previous_A[i] = A[i]; A[i] = 0;
                                    for j in 1:total_node
                                        A[i] = A[i] + (B[j] * sumdestination[j] * (datamatrix[i,j,1]^ -beta ))
                                    end
                                    if A[i] != 0
                                    A[i] = 1 / A[i]
                                    end
                                end
                            else
                                for i in 1:total_node
                                    previous_A[i] = A[i]; A[i] = 0;
                                    for j in 1:total_node
                                        if !isnan(datamatrix[i,j,1]) 
                                            A[i] = A[i] + (B[j] * sumdestination[j] * (datamatrix[i,j,1]^ -beta))
                                        end
                                    end
                                    if A[i] != 0
                                            A[i] = 1 / A[i]
                                    end
                                end
                            end
                            if flag_full_matrix
                                for j in 1:total_node
                                    previous_B[j] = B[j]; B[j] = 0;
                                    for i in 1:total_node
                                        B[j] = B[j] + (A[i] * sumorigin[i] * (datamatrix[i,j,1]^ -beta))
                                    end
                                    if B[j] != 0
                                    B[j] = 1 / B[j]
                                    end
                                end
                            else
                                for j in 1:total_node
                                    previous_B[j] = B[j]; B[j] = 0;
                                    for i in 1:total_node
                                        if !isnan(datamatrix[i,j,1]) 
                                            B[j] = B[j] + (A[i] * sumorigin[i] * (datamatrix[i,j,1]^ -beta))
                                        end
                                    end
                                    if B[j] != 0
                                        B[j] = 1 / B[j]
                                    end
                                end
                            end
            
                            sumabsA = sum(abs.(A .- previous_A))
                            sumabsB = sum(abs.(B .- previous_B))
            
                            #=
                                for i in 1:total_node
                                    sumabsA += Math.Abs(A[i] - previous_A[i]);
                                    sumabsB += Math.Abs(B[i] - previous_B[i]);
                                end
                            =#
                                
                            if sumabsA <= prm.innerloopconstr && sumabsB <= prm.innerloopconstr
                                Nocriteriumget = false
                            end
                            if innerloopdyn >= prm.innerloopvalue
                                Noexitbymaximumloop = false
                            end
                            sumsA = sumabsA; sumsB = sumabsB;
            
                            _infinite = isinf(sumsA) || isinf(sumsB)
                            _issubnormal = issubnormal(sumsA) || issubnormal(sumsB)
                            _isfinite = isfinite(sumsA) && isfinite(sumsB)
            
                            if !(_isfinite && !_infinite && !_issubnormal )
                                overFlowCalc = true;
                            end
                        else
        
                        end
        
                        # end inner loop
                    end  #while (Nocriteriumget && Noexitbymaximumloop && !overFlowCalc) 
                    
                    delta_Flow_estimate .= 0.0

                    if prm.formula == Exponential
                        if flag_full_matrix
        
                            delta_Flow_estimate .= (A .* sumorigin) * (B .* sumdestination)' .* exp.(-beta .* datamatrix[:, :, 1])
    
                        else
        
                            delta_Flow_estimate = [(!isnan(datamatrix[i, j, 1]) ? A[i] * sumorigin[i] * B[j] * sumdestination[j] * exp(-beta * datamatrix[i, j, 1]) : 0.0)
                                                for i in 1:total_node, j in 1:total_node]
        
                        end
                    elseif prm.formula == Power
                        if flag_full_matrix
        
                            delta_Flow_estimate .= (A .* sumorigin) * (B .* sumdestination)' .* datamatrix[:, :, 1] .^ -beta
        
                        else
        
                            delta_Flow_estimate = [(isfinite(datamatrix[i, j, 1]) ? A[i] * sumorigin[i] * B[j] * sumdestination[j] * datamatrix[i, j, 1] ^ -beta : 0.0)
                                                for i in 1:total_node, j in 1:total_node]
    
                        end
                    else
                    end

                    delta_C_ = 0; delta_sumflows = 0;

                    
                    if flag_full_matrix
        
                        delta_C_ = sum(datamatrix[:,:,1] .* delta_Flow_estimate)
                        delta_sumflows = sum(delta_Flow_estimate)
                    else
        
                        delta_C_ = sum(datamatrix_[:,:,1] .* delta_Flow_estimate .* (isfinite.(delta_Flow_estimate) .& isfinite.(datamatrix_[:,:,1])))
                        delta_sumflows = sum(delta_Flow_estimate .* (isfinite.(delta_Flow_estimate) .& isfinite.(datamatrix_[:,:,1])))
                    end

                    delta_Ratio_C_sumflow::Float64 = delta_C_ / delta_sumflows;
                    delta_beta = 1 / ((Ratio_C_sumflow - delta_Ratio_C_sumflow) / delta_increase);
                    delta_error = delta_beta * (first_Ratio_C_sumflow - Ratio_C_sumflow);
                    beta = beta - delta_error;
                    if ( !isfinite(beta) || (abs(beta - previous_beta) <= 0.000000000000001))
                        ExternalLoop = false; 
                    end
                end

                if !overFlowCalc

                else
                    if !Nocriteriumget
                        if ExternalLoop
                        
                        else
                            if abs(beta-previous_beta) <= 0.000000000000001
                                beta_stable = true
                            end

                        end
                    else
                        if ExternalLoop
                        
                        else
                            if abs(beta-previous_beta) <= 0.000000000000001
                                beta_stable = true
                            end

                        end

                    end
                end
            else
                _C_ = sum(datamatrix[:,:,1] .* Flow_estimate)

                if abs(_C_ - previous_C_) <= prm.outerloopconstr || outerloopdyn >= prm.outerloopvalue
                    ExternalLoop = false
                else
                    beta = _C_ * previous_beta / first_C_;
                end

                if !isfinite(beta) || abs(beta-prevfloat) <= 0.000000000000001
                    ExternalLoop = false
                end

                if !Nocriteriumget
                    if ExternalLoop
                    
                    else
                        if abs(beta-previous_beta) <= 0.000000000000001
                            beta_stable = true
                        end

                    end
                else
                    if ExternalLoop
                    
                    else
                        if abs(beta-previous_beta) <= 0.000000000000001
                            beta_stable = true
                        end

                    end

                end

            end
        end # while(ExternalLoop

        if overFlowCalc
            println("771")
        else
            if prm.returnStatistics || prm.returnFullData || prm.returnRSquared
                println("774")
                outputdata::Vector{SpInData} = Vector{SpInData}(undef, 0)
                for q in inputdata
                    i = get(node_index,q.origin, -1)
                    j = get(node_index,q.destination, -1)

                    if (i < 0 || j < 0)

                        if (i < 0)
                            _origin = q.origin 
                            _ret = SpInResult(false, "error inner procedure on origin $_origin ", NaN, Array{SpInModelStatistic}(undef, 0), [q], Float64(0.0), Float64(0.0), "")
                            return _ret
                        else 
                            _destination = q.destination 
                            _ret = SpInResult(false, "error inner procedure on destination $_destination ", NaN, Array{SpInModelStatistic}(undef, 0), [q], Float64(0.0), Float64(0.0), "")
                            return _ret
                        end
                    else
                        if flag_full_matrix
                            push!(outputdata , SpInData(q.origin, q.destination, q.cost, q.flow, 0.0, 0.0, Flow_estimate[i, j], q.flow - Flow_estimate[i, j]))
                        else
                            if (isfinite(datamatrix[i, j, 1]) && isfinite(datamatrix[i, j, 2]))
                                push!(outputdata , SpInData(q.origin, q.destination, q.cost, q.flow, 0.0, 0.0, Flow_estimate[i, j], q.flow - Flow_estimate[i, j]))
                            end
                        end
                    end
                end

                nobs::Int64 = length(outputdata)

                total_flow::Float64, total_estimate::Float64, total_diff::Float64 = Float64(0.0), Float64(0.0), Float64(0.0);
                real_total_estimate::Float64, real_total_flow::Float64 = Float64(0.0), Float64(0.0);
                sum_of_obs_x_predic::Float64, sum_square_predic::Float64 = Float64(0.0), Float64(0.0);
                sum_square_of_diff_obs_pred::Float64, avrg_obs::Float64, avrg_estim::Float64 = Float64(0.0), Float64(0.0), Float64(0.0);

                for q in outputdata
                    total_flow += abs(q.flow); total_estimate += abs(q.estimatedflow); total_diff += abs(q.difference);
                    real_total_estimate += q.estimatedflow; real_total_flow += q.flow; 
                    sum_of_obs_x_predic += (q.flow * q.estimatedflow); sum_square_predic += q.estimatedflow^2;
                    sum_square_of_diff_obs_pred += (q.flow - q.estimatedflow)^2;
                end

                avrg_estim = real_total_estimate / nobs;
                avrg_obs = real_total_flow / nobs;

                rsq_num::Float64, rsq_den_obs::Float64, rsq_den_est::Float64 = Float64(0.0), Float64(0.0), Float64(0.0);
                ss_tot::Float64, ss_err::Float64 = Float64(0.0), Float64(0.0);

                for q in outputdata
                    rsq_num += (q.flow - avrg_obs) * (q.estimatedflow - avrg_estim);
                    rsq_den_obs += (q.flow - avrg_obs)^2;
                    rsq_den_est += (q.estimatedflow - avrg_estim)^2;
                    ss_err += (q.flow - q.estimatedflow)^2;
                end
                ss_tot = rsq_den_obs;
                R_Squared::Float64 =  (rsq_num/( sqrt(rsq_den_obs * rsq_den_est) ))^2;
                beta_fitting::Float64 = rsq_num / rsq_den_est;
                alpha_fitting::Float64 = avrg_obs - (beta_fitting * avrg_estim);
                SE_beta::Float64 = sqrt((sum_square_of_diff_obs_pred / (nobs - 2)) / ( sum_square_predic - real_total_estimate^2 / nobs ));               
                t_statistics::Float64 = abs((beta_fitting - 1) / SE_beta);
                r_formula::String = """Formula: Tij(observed) = $(alpha_fitting) + $(beta_fitting) * Tij(estimated)($(SE_beta)) """;

                spStatistics = SpInModelStatistic[];
                push!(spStatistics, SpInModelStatistic("alpha_fit", alpha_fitting))
                push!(spStatistics, SpInModelStatistic("beta_fit", beta_fitting))
                push!(spStatistics, SpInModelStatistic("se_beta", SE_beta))
        
                _ret = SpInResult(true, "", beta, spStatistics, outputdata, R_Squared, t_statistics, r_formula)
                return _ret

            end



        end





    elseif prm.model == SingleConstrained_Origin

    elseif prm.model == SingleConstrained_Destination

    elseif prm.model == UnConstrained

    end

    

    

    return _ret
end


