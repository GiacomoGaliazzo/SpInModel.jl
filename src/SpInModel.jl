module SpInModel

using DataFrames
export spinModelresult

include("Structs.jl")

include("SpinModelCalibration.jl")

spinModelresult = SpinResult(false, "initialization", NaN, Array{String}(undef, 0), Array{spinData}(undef, 0), Float64(0.0), "")
prms = SpinModelConfig(DoublyConstrained, Power, true, true, Float64(2.0), Float64(0.0), true, Float64(1.0), Float64(0.0), true, false, "SimodelEvaluation", Float64(0.0), Float64(0.01), Float64(0.00001), Int64(1000), Int64(10), true, true, true)
df_sample = DataFrame(
    from = ["A", "B", "C", "A", "B", "C" , "A", "B", "C" ], 
    to = ["A","A","A","B","B","B","C","C","C",],
    cost = [string(i) for i in 1:9],
    flow = [string(i) for i in 9:-1:1]
)
spinModelresult = SpinModelCalibration(prms, df_sample)


end
