

df_sampple = DataFrame(
    from = ["A", "B", "C", ], 
    to = ["B", "C", "A", ],
    cost = ["22", "33", "44"],
    flow = ["3", "0", "3"]
)


column_types_df_sample2 = Dict(:from => String, :to => String, :cost => Float64, :flow => Float64)
df_sample2 = CSV.read("SpInModel.jl/src/data_test1.csv", DataFrame; types=column_types_df_sample2) 