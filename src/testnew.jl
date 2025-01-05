



DataFrames.rename!(df_2007, [:origname => :from, :destname => :to, :flow => :flow, :travel_10 => :cost])


include("SpinModelCalibration.jl")

my2007 = SpInModelCalibration(parms, df_2007)



