module SpInModel

using DataFrames
export beta_calibration

include("Structs.jl")

include("SpinModelCalibration.jl")


beta_calibration = Float64(0.0)


end
