

function readInstance(filename)
    f = open(filename)
    readline(f)
    #header line comment

    #read instance size data
    data = split(readline(f))
    G = parse(Int64,data[1]) # no. guests
    T = parse(Int64,data[2]) # no. tables
    S = parse(Int64,data[3]) # no. sits per table

    #read common interests data
    readline(f);readline(f) #empty line + header
    shared_interests = zeros(Int64,G,G)
    for g1 in 1:G
        data = parse.(Int64,split(readline(f)))
        for g2 in 1:G
            shared_interests[g1,g2] = data[g2]
        end
    end

    #read guests' data
    readline(f);readline(f) #empty line + header
    partner = zeros(Int64,G)
    gender = zeros(Int64,G)

    for g in 1:G
        data = split(readline(f))#read guest data
        partner[g] = parse(Int64,data[1])#read partner
        gender[g]=data[2]=="M" ? 0 : 1 #read gender Male 0, Female 1
        #TODO: read the list of guest that guest g knows.
    end
    close(f)
    return G, T, S, shared_interests, partner, gender

end
# function assignCouple(guest::Array{Int64, T, S}, partner::Array{Int64,G})

function initializeSolution(G::Int64, T::Int64, S::Int64, partner)
    guest = zeros(Int64, T, S)
    P = partner[ : ]
    t = 1
    s = 1
    couple = 1 #couple guest pointer
    while P[couple] < 1 # find the first couple
        if couple <= G
            couple += 1
        end
    end

    single = 1 #single guest pointer
    while P[single] != 0 #find the first single person
        if single <= G
            single += 1
        end
    end

    while t <= T || s <= S #assign guest
        
        if t == T && s == S
            guest[t, s] = single
            break
        end

        if couple <= G && s <= S-2
            guest[t, s] = couple
            # println("cp01:" *string(couple) * " t:" * string(t) * " s:" * string(s))
            guest[t, s+1] = P[couple]
            # println("cp02:" *string(P[couple]) * " t:" * string(t) * " s:" * string(s+1))
            P[P[couple]] = -1
            P[couple] = -1
            if s == S-1 && t <T
                t += 1
                s = 1
            elseif s < S-1
                s += 2
            end
            while couple <= G && P[couple] < 1
                couple += 1
            end
        else
            guest[t, s] = single
            # println("single:" * string(single) * " t:" * string(t) * " s:" * string(s))
            if s == S && t < T
                t += 1
                s = 1
            elseif s < S
                s += 1
            end
            single += 1
            while single <= G && P[single] != 0
                single += 1
            end
        end
    end
    return guest
end

# function getCost(guest, interest, partner)
