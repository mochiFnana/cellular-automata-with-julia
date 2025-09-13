# This code simulates a 2D cellular automaton, similar to Conway's Game of Life.
# It works by generating a random grid and then evolving it over time
# based on a set of rules that determine a cell's next state from its neighbors.

using Random

# dim: Defines the dimensions of the grid (width, height)
dim = [44, 22]

# surface: Creates the initial grid. It's a boolean matrix where each cell
# has a 20% chance of being 'true' (live) and 80% chance of being 'false' (dead).
surface = rand(Float64, (dim[1], dim[2])) .> .8

# rules: An array of tuples defining the core logic. Each tuple contains a
# neighborhood sum (the rule) and the resulting state (true/false) for the cell.
# The sums are complex numbers or integers, which are unique identifiers for
# specific neighborhood patterns.
rules = [(12,      false),
         (1,       true),
         (4,       false),
         (1+2im,   true),
         (2im,     true),
         (1+1im,   false),
         (4im,     false),
         (2+2im,   true),
         (10+1im,  false)
         ]

"""
    display(data, style="0·")

Prints the cellular automaton grid to the console.
- `data`: The boolean matrix representing the grid.
- `style`: A string of two characters to represent true and false cells.
"""
function display(data, style="0·")
    # Maps boolean values to characters from the style string.
    data = map(n->n ? style[1] : style[2], data)
    
    # Iterates through the grid and prints each character.
    # The loops are structured to print column-wise, which appears as rows on the console.
    for i in 1:size(data, 2)
       for n in 1:size(data, 1)
          print(data[n, i])
       end
       println() # Moves to the next line after each row is printed.
    end
end

"""
    convert(data)

Calculates a unique 'sum' for each cell's 3x3 neighborhood.
This sum acts as a key to look up the next state in the `rules` array.
- `data`: The current boolean grid.
- Returns a tuple: (grid of neighborhood sums, grid of neighbor patterns)
"""
function convert(data)
    ret = [] # Stores the 3x3 boolean patterns (not used in the main loop).
    val = [] # Stores the neighborhood sums.

    # axs: A unique value for each of the 9 positions in a 3x3 grid.
    # 1im for top-left, 1 for top-right, 10 for center, etc.
    axs = [n==5 ? 10 : n%2 == 0 ? 1 : 1im for n in 1:9]
    
    # pos: The relative positions of the 9 cells in a 3x3 grid (center is 0+0im).
    pos = [n%3+round(n/3, RoundDown)*1im for n in 0:8] .- [1+1im for _ in 1:9]

    # Loops through each cell of the grid (i, n)
    for i in 1:size(data, 2)
       for n in 1:size(data, 1)
          # con: Checks the state of each neighbor (and the cell itself).
          # `try...catch` handles boundary cases by assuming out-of-bounds cells are 'false'.
          con = [try data[Int(n+real(j)), Int(i+imag(j))] catch; false end for j in pos]
          
          # nek: Maps the 'true' neighbors to their corresponding 'axs' values.
          # The sum of these values is a unique identifier for the neighborhood pattern.
          nek = [i ? axs[n] : 0 for (n, i) in enumerate(con)]
          
          push!(ret, reshape(con, 3, 3))
          push!(val, sum(nek)) # The main value used for rule lookup.
       end
    end
    
    # Reshapes the lists back into the original grid dimensions.
    return reshape(val, size(data, 1), size(data, 2)), ret
end

"""
    update(rules, base)

Applies the rules to a grid of neighborhood sums to determine the next state of each cell.
- `rules`: The array of rule tuples.
- `base`: The grid of neighborhood sums from the `convert` function.
"""
function update(rules, base)
    # Extracts the rule keys (sums) and the new state values from the rules array.
    rule = getindex.(rules, 1)
    valu = getindex.(rules, 2)
    
    new_surface = []
    
    # Loops through each cell in the `base` grid.
    for n in 1:size(base, 2)
       for i in 1:size(base, 1)
          # Checks if the cell's neighborhood sum exists in the rules.
          if base[i, n] in rule
             # Finds the corresponding new state from the `valu` array.
             push!(new_surface, valu[findfirst(isequal(base[i, n]), rule)])
          else
             # If no rule matches, the cell's new state defaults to 'false'.
             push!(new_surface, false)
          end
       end
    end
    
    # Reshapes the new list of states into a 2D grid.
    new_surface = reshape(new_surface, size(base, 1), size(base, 2))
    return new_surface
end

# The main program loop.
while true
    # 1. Convert the current surface to a grid of neighborhood sums.
    value, = convert(surface)
    
    # 2. Update the surface based on the rules.
    surface = update(rules, value)
    
    # 3. Display the new surface.
    display(surface)
    
    # Prints a separator line for readability.
    println("_"^44)
    
    # Pauses the execution for 0.5 seconds.
    sleep(.5)
end
