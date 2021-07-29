# allow plotting of Portfolios or other collections via the classification dendrogram
using CairoMakie

function plot(cpc::Patents.AbstractClassification; vertical=false)
	xs, ys, paths = solve_positions(Zarate(), cpc.g)
	
	xl = vcat([e[1] for e in values(paths)]...)
	yl = vcat([e[2] for e in values(paths)]...)
	
	align=(:right, :center) 
	offset=(-15, -15)
	
	if vertical
		xs, ys = ys, -xs
		xl, yl = yl, -xl
		align = (:left, :center)
		offset = (20, 0)
	end

	labels = Patents.code.(symbols(cpc))
	textpos = [(x,y) for (x,y) in zip(xs, ys)]
	
	fig = Figure()
	ax = Axis(fig[1,1])

	linesegments!(ax, xl, yl)
	scatter!(ax, xs, ys)
	
	text!(labels, position = textpos, align=align, offset=offset)
	hidedecorations!(ax)
	
	fig
end