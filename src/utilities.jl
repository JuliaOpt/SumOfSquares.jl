# The second type is ignored. For `T = VariableRef`, it should be `Float64` anyway
# since JuMP only supports `Float64`.
_promote_sum(T::Type, ::Type=Float64) = MA.promote_operation(+, T, T)
# `+` is not defined between `MOI.SingleVariable`.
_promote_sum(::Type{MOI.SingleVariable}, T::Type=Float64) = MOI.ScalarAffineFunction{T}

_promote_add_mul(T::Type) = MA.promote_operation(MA.add_mul, T, T, T)
_promote_add_mul(::Type{MOI.SingleVariable}) = MOI.ScalarQuadraticFunction{Float64}
function MP.polynomial(p::GramMatrix{MOI.SingleVariable, B, U}) where {B, U}
    Q = convert(Vector{U}, p.Q.Q)
    return MP.polynomial(GramMatrix(SymMatrix(Q, p.Q.n), p.basis))
end
#function MP.polynomial(p::GramMatrix{F}) where {F <: MOI.AbstractFunction}
#    MP.polynomial(p, MOIU.promote_operation(+, Float64, F, F))
#end

function primal_value(model, p::GramMatrix{MOI.SingleVariable})
    # TODO [perf] use MOI typed mapped array
    Q = MOI.get(model, MOI.VariablePrimal(),
                MOI.VariableIndex[sv.variable for sv in p.Q.Q])
    return GramMatrix(SymMatrix(Q, p.Q.n), p.basis)
end

_complex(::Type{T}, ::Type) where {T} = T
_complex(::Type{T}, ::Type{SumOfSquares.COI.HermitianPositiveSemidefiniteConeTriangle}) where {T} = Complex{T}
