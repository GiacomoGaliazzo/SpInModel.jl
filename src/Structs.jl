

struct SpinModelConfig
    model::String
    formula::String
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
    innerloopvalue::Float64
    outerloopvalue::Float64
    checkStatistics::Bool
    checkFullData::Bool
    checkRSquared::Bool
    checkFlgColName::Bool
end

