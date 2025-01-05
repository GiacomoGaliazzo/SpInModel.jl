include("_000 param_init.jl")


using DataFrames, CSV
include("_001 datasample.jl")
unique_values = unique(vcat(df_sample.res_name, df_sample.des_name))
total_node = length(unique_values)

include("Structs.jl")

parms = SpInModelConfig(DoublyConstrained, Power, true, true, Float64(2.0), Float64(0.0), true, Float64(1.0), Float64(0.0), true, false, "SimodelEvaluation", Float64(0.0), Float64(0.01), Float64(0.00001), Int64(1000), Int64(10), true, true, true)

# include("SpinModelCalibration.jl")

DataFrames.rename!(df_sample, [:res_name => :from, :des_name => :to, :flussi => :flow, :total_minu => :cost])


include("SpinModelCalibration.jl")

myres = SpInModelCalibration(parms, df_sample)





# Create a vector of SpinData
spin_vector = [
    SpinData("A", "B", 10.0, 100.0, 500.0, 600.0, 95.0, 5.0),
    SpinData("C", "D", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C1", "D2", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C12", "D23", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C12", "D23", 20.0, 200.0, 800.0, 900.0, 191.0, 11.0)
    # Add more entries as needed
]

# Create a dictionary for fast lookup
spin_dict = Dict((s.origin, s.destination) => s for s in spin_vector)

# Access an entry quickly
od_key = ("A", "B")
spin_entry = get(spin_dict, od_key, nothing)

if spin_entry !== nothing
    println("Found entry: $spin_entry")
else
    println("No entry for $od_key")
end


od_key = ("C12", "D23")
spin_entry = get(spin_dict, od_key, nothing)

if spin_entry !== nothing
    println("Found entry: $spin_entry")
else
    println("No entry for $od_key")
end





# Create a vector of SpinData
spin_vector = [
    SpinData("A", "B", 10.0, 100.0, 500.0, 600.0, 95.0, 5.0),
    SpinData("C", "D", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C1", "D2", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C12", "D23", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C12", "D23", 20.0, 200.0, 800.0, 900.0, 191.0, 11.0)
    # Add more entries as needed
]






# Create a dictionary, keeping the first occurrence
spin_dict = Dict()
for s in spin_vector
    if !haskey(spin_dict, (s.origin, s.destination))
        spin_dict[(s.origin, s.destination)] = s
    else
        println("duplicate " , s)
    end
end


od_key = ("C12", "D23")
spin_entry = get(spin_dict, od_key, nothing)

if spin_entry !== nothing
    println("Found entry: $spin_entry")
else
    println("No entry for $od_key")
end



origin_dict = Dict{String, Vector{SpinData}}()

for s in spin_vector
    if !haskey(origin_dict, s.origin)
        origin_dict[s.origin] = [s]  # Create a new vector if key is not present
    else
        push!(origin_dict[s.origin], s)  # Append to the existing vector
    end
end

# Example: Access SpinData entries for a specific origin
origin_key = "C12"
spin_entries = get(origin_dict, origin_key, [])
println("Entries for origin '$origin_key': $spin_entries")

length(spin_entries)



data__x = [
    SpinData("C12", "D23", 20.0, 200.0, 800.0, 900.0, 190.0, 10.0),
    SpinData("C12", "D23", 20.0, 200.0, 800.0, 900.0, 190.0, 111110.0),
    SpinData("C12", "D231", 20.0, 200.0, 800.0, 900.0, 191.0, 11.0),
    SpinData("C12", "D233", 20.0, 200.0, 800.0, 900.0, 191.0, 11.0),
    SpinData("C12", "D234", 20.0, 200.0, 800.0, 900.0, 191.0, 11.0)
]


index = findfirst(x -> x.destination == "D234", data__x)



isnothing(index)