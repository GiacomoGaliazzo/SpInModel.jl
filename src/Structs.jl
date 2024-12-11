
#=
abstract type SpinModel end
struct DoublyConstrained <: SpinModel end
struct SingleConstrained <: SpinModel end
struct UnConstrained <: SpinModel end

abstract type SpinModelFormula end
struct Power <: SpinModelFormula end
struct Exponential <: SpinModelFormula end
=#

@enum SpInModelEnum begin
    DoublyConstrained = 1
    SingleConstrained_Origin = 2
    SingleConstrained_Destination = 3
    UnConstrained = 4
end

@enum SpInModelFormula begin
    Power = 1
    Exponential = 2
end

struct SpInModelConfig
    model::SpInModelEnum
    formula::SpInModelFormula
    includeinnerflow::Bool
    setminimumdatavalue::Bool
    minimumcost::Float64
    minimumflow::Float64
    fillmissingdata::Bool
    fillmissingcost::Float64
    fillmissingflow::Float64
    useSIModelMethod::Bool
    ModifyontheFly::Bool
    startingValueType::Float
    customBetaInput::Float64
    innerloopconstr::Float64
    outerloopconstr::Float64
    innerloopvalue::Int64
    outerloopvalue::Int64
    returnStatistics::Bool
    returnFullData::Bool
    returnRSquared::Bool
end

struct SpInModelStatistic
    name::String
    value::Float64
end

struct SpInData
        origin::String
        destination::String
        cost::Float64
        flow::Float64
        sumoriginflow::Float64
        sumdestinationflow::Float64
        estimatedflow::Float64
        difference::Float64
end

struct SpInResult
    convergence::Bool
    reason::String
    beta::Float64
    statistics::Array{SpInModelStatistic}
    spInData::Array{SpInData}
    r^2::Float64
    t_Statistics::Float64
    rFormula::String
end
