

function SpinModelCalibration(prms::SpinModelConfig, data::DataFrame)

    node_unique = unique(vcat(data.from, data.to))
    total_node = length(node_unique)

    SecondArray = zeros(Float64, total_node, total_node)
    full_matrix_flow = zeros(Float64, total_node, total_node)
    full_matrix_time = zeros(Float64, total_node, total_node)
            
    origindistinct = zeros(Float64, total_node)
    destinationdistinct = zeros(Float64, total_node)
    
    A = zeros(Float64, total_node)
    previuos_A = zeros(Float64, total_node)

    B = zeros(Float64, total_node)
    previuos_B = zeros(Float64, total_node)

    modelformulastring::Array{String} = Vector{String}(undef, 0)
    beta::Float64 = Float64(0.0)
    previous_beta::Float64 = Float64(0.0)
            
    first_beta::Float64 = Float64(0.0)
    _C_::Float64 = Float64(0.0)
    previous_C_::Float64 = Float64(0.0)
            
    first_C_::Float64 = Float64(0.0)
            
    Flow_estimate = zeros(Float64, total_node, total_node)
    first_sumflows::Float64 = Float64(0.0)
    sumflows::Float64 = Float64(0.0)
    first_Ratio_C_sumflow::Float64 = Float64(0.0)
            
    delta_increase::Float64 = Float64(0.0)
    delta_beta::Float64 = Float64(0.0)
    delta_C_::Float64 = Float64(0.0)
    delta_Flow_estimate = zeros(Float64, total_node, total_node)
    delta_sumflows::Float64 = Float64(0.0)
    delta_error::Float64 = Float64(0.0)
            
            


    


    _ret::Float64 = Float64(0.0);

    return _ret
end