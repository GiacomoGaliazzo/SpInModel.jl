include("_000 param_init.jl")
include("_001 datasample.jl")
unique_values = unique(vcat(df_sample2.from, df_sample2.to))
total_node = length(unique_values)




include("Structs.jl")


parms = SpinModelConfig(DoublyConstrained, Power, true, true, Float64(2.0), Float64(0.0), true, Float64(1.0), Float64(0.0), true, false, "0.4", Float64(0.0), Float64(0.01), Float64(0.00001), Int64(1000.0), Int64(10.0), true, true, true, true )

include("SpinModelCalibration.jl")

myres = SpinModelCalibration(parms, df_sample2)
