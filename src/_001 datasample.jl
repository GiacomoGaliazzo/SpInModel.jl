

column_types_df_sample = Dict(:res_name => String, :des_name => String, :flussi => Float64, :total_minu => Float64)
#df_sample = CSV.read("SpInModel.jl/src/flussi_north_lom_minuti_auto.txt", DataFrame; types=column_types_df_sample, delim='\t') 
df_sample = CSV.read("src/flussi_north_lom_minuti_auto.txt", DataFrame; types=column_types_df_sample, delim='\t') 


df_sampple = DataFrame(
    from = ["A", "B", "C", "A", "B", "C" , "A", "B", "C" ], 
    to = ["A","A","A","B","B","B","C","C","C",],
    cost = [string(i) for i in 1:9],
    flow = [string(i) for i in 9:-1:1]
)


column_types_df_sample2 = Dict(:from => String, :to => String, :cost => Float64, :flow => Float64)
#df_sample2 = CSV.read("SpInModel.jl/src/data_test1.csv", DataFrame; types=column_types_df_sample2) 





column_types_df_2007 = Dict(:origname => String, :destname => String, :travel_10 => Float64, :travel_15 => Float64, :travel_20 => Float64, :flow => Float64)
#df_sample = CSV.read("SpInModel.jl/src/flussi_north_lom_minuti_auto.txt", DataFrame; types=column_types_df_sample, delim='\t') 
df_2007 = CSV.read("src/data_2007.txt", DataFrame; types=column_types_df_2007, delim='\t') 







