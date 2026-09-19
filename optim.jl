using JuMP
import Ipopt

# ---------- Data ----------
N     = 1:11
edges = [(1,2),(1,11),(2,3),(2,11),(3,4),(3,9),(4,5),(5,6),
         (5,8),(6,7),(7,8),(7,9),(8,9),(9,10),(10,11)]
bval  = [-20.1,-22.3,-16.8,-17.2,-11.7,-19.4,-10.8,-12.3,
          -9.2,-13.9, -8.7,-11.3, -7.7,-13.5,-26.7]
gval  = [ 4.12, 5.67, 2.41, 2.78, 1.98, 3.23, 1.59, 1.71,
          1.26, 1.11, 1.32, 2.01, 4.41, 2.14, 5.06]

b = Dict(); g = Dict(); A = Tuple{Int,Int}[]
for (m,(k,l)) in enumerate(edges)
    b[(k,l)] = b[(l,k)] = bval[m]        # b_kl = b_lk
    g[(k,l)] = g[(l,k)] = gval[m]        # g_kl = g_lk
    push!(A,(k,l)); push!(A,(l,k))       # två riktade bågar per kant
end
nbr = Dict(k => [l for l in N if haskey(b,(k,l))] for k in N)

G     = 1:9
gnode = [2, 2, 2, 3, 4, 5, 7, 9, 9]
Pmax  = [0.02, 0.15, 0.08, 0.07, 0.04, 0.17, 0.17, 0.26, 0.05]
cost  = [175., 100., 150., 150., 300., 350., 400., 300., 200.]
Gk    = Dict(k => [i for i in G if gnode[i]==k] for k in N)

D = zeros(11)
D[1]=0.10; D[4]=0.19; D[6]=0.11; D[8]=0.09; D[9]=0.21; D[10]=0.05; D[11]=0.04

# ---------- Modell ----------
m = Model(Ipopt.Optimizer)

@variable(m, 0 <= P[i in G] <= Pmax[i])                    # aktiv produktion
@variable(m, -0.03Pmax[i] <= Q[i in G] <= 0.03Pmax[i])     # reaktiv produktion
@variable(m, 0.98 <= v[N] <= 1.02, start = 1.0)            # spänningsamplitud
@variable(m, -pi <= th[N] <= pi, start = 0.0)              # fasvinkel
@constraint(m, th[1] == 0)                                 # referensnod, (10)

# Flödesekvationer (2)-(3), definierade på riktade bågar
@NLexpression(m, p[(k,l) in A],
     v[k]^2*g[(k,l)] - v[k]*v[l]*g[(k,l)]*cos(th[k]-th[l])
                     - v[k]*v[l]*b[(k,l)]*sin(th[k]-th[l]))
@NLexpression(m, q[(k,l) in A],
    -v[k]^2*b[(k,l)] + v[k]*v[l]*b[(k,l)]*cos(th[k]-th[l])
                     - v[k]*v[l]*g[(k,l)]*sin(th[k]-th[l]))

# Nodbalanser (4)-(5)
@NLconstraint(m, Pbal[k in N],
    sum(P[i] for i in Gk[k]) - sum(p[(k,l)] for l in nbr[k]) == D[k])
@NLconstraint(m, Qbal[k in N],
    sum(Q[i] for i in Gk[k]) - sum(q[(k,l)] for l in nbr[k]) == 0)

@objective(m, Min, sum(cost[i]*P[i] for i in G))           # (1)

optimize!(m)

# ---------- Kontroller ----------
losses = sum(value(p[(k,l)]) for (k,l) in A)
println("Total kostnad: ", objective_value(m), " SEK")
println("Total produktion: ", sum(value.(P)), " pu")
println("Total efterfrågan: ", sum(D), " pu")
println("Nätförluster: ", losses, " pu")

println("Status: ", termination_status(m))

println("\nGenerator   P [pu]    Q [pu]")
for i in G
    println(rpad("G$i", 10), lpad(round(value(P[i]), digits=4), 8),
            lpad(round(value(Q[i]), digits=5), 10))
end

println("\nNod    v [vu]    theta [rad]")
for k in N
    println(rpad(k, 5), lpad(round(value(v[k]), digits=4), 8),
            lpad(round(value(th[k]), digits=5), 12))
end

println("\nBåge (k,l)   p_kl [pu]    q_kl [pu]")
for (k,l) in A
    println(rpad("($k,$l)", 12), lpad(round(value(p[(k,l)]), digits=5), 10),
            lpad(round(value(q[(k,l)]), digits=5), 12))
end
