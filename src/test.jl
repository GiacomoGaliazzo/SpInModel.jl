using DataFrames

# Sample DataFrame
df = DataFrame(from = ["A", "B", "C", "A", "10211"], to = ["B", "C", "A", "D", "call"])

# Combine and get unique values
unique_values = unique(vcat(df.from, df.to))


total_node = length(unique_values)