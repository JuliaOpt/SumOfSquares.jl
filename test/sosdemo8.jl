# Adapted from:
# SOSDEMO8 --- Bounds in Probability
# Section 3.8 of SOSTOOLS User's Manual

facts("SOSDEMO8") do
for solver in sdp_solvers
context("With solver $(typeof(solver))") do
    @polyvar x

    # The probability adds up to one.
    μ0 = 1
    # Mean
    μ1  = 1
    # Variance
    σ = 1/2
    # E(x^2)
    μ2 = σ^2+μ1^2
    # Support of the random variable
    R = [0,5]

    # Event whose probability we want to bound
    E = [4,5]

    m = Model()

    @variable m a
    @variable m b
    @variable m c

    P = a + b*x + c*x^2

    # Nonnegative on the support
    @polyconstraint(m, P >= 0, domain = 0 <= x && x <= 5)

    # Greater than one on the event
    @polyconstraint(m, P >= 1, domain = 4 <= x && x <= 5)

    # The bound
    bnd =  a * μ0 + b * μ1 + c * μ2

    @objective m Min bnd

    status = solve(m)

    @fact isapprox(getobjectivevalue(m), 1/37, rtol=1e-7) --> true
    @fact isapprox(getvalue(P), ((12/37)x-11/37)^2, rtol=1e-3) --> true
end; end; end
