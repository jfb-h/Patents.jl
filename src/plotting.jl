using GraphMakie

# @recipe(MainPathPlot) do scene
#     Attributes(
#         startmarker => :cross
#     )
# end

convert_arguments(::GraphPlot, x::MainPath) = (x.mainpath,)


