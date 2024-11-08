
#=
abstract type SpinModel end
struct DoublyConstrained <: SpinModel end
struct SingleConstrained <: SpinModel end
struct UnConstrained <: SpinModel end

abstract type SpinModelFormula end
struct Power <: SpinModelFormula end
struct Exponential <: SpinModelFormula end
=#

@enum SpinModel begin
    DoublyConstrained = 1
    SingleConstrained = 2
    UnConstrained = 3
end

@enum SpinModelFormula begin
    Power = 1
    Exponential = 2
end




struct SpinModelConfig
    model::SpinModel
    formula::SpinModelFormula
    checkinnerflow::Bool
    checkminimumdatavalue::Bool
    minimumcost::Float64
    minimumflow::Float64
    checkfillmissingdata::Bool
    fillmissingcost::Float64
    fillmissingflow::Float64
    checkSIModelMethod::Bool
    checkModifyontheFly::Bool
    startingValueSelect::String
    customBetaInput::Float64
    innerloopconstr::Float64
    outerloopconstr::Float64
    innerloopvalue::Int64
    outerloopvalue::Int64
    checkStatistics::Bool
    checkFullData::Bool
    checkRSquared::Bool
    checkFlgColName::Bool
end

