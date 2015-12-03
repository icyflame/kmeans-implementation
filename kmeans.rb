#!/usr/bin/env ruby

require 'statsample'
require 'gnuplot'

@all_data = Array.new
@r_max = 0
@g_max = 0
@b_max = 0

def find_distance(a, b)
	return Math.sqrt((a[0]-b[0])**2 + (a[1]-b[1])**2 + (a[2]-b[2])**2)
end

File.open("./train_file_red.txt", "r") do |filin|
	while (line = filin.gets)
		list_rgb = line.split(" ")
		list_rgb_int = Array.new
		list_rgb.each do |data_point|
			list_rgb_int.push data_point.to_i
		end
		@all_data.push(list_rgb_int)
		if list_rgb_int[0] > @r_max
			@r_max = list_rgb_int[0]
		end
		if list_rgb_int[1] > @g_max
			@g_max = list_rgb_int[1]
		end
		if list_rgb_int[2] > @b_max
			@b_max = list_rgb_int[2]
		end
	end
end

@means = Array.new

@first_mean = [0, 0, 0]

@num_means = 2

p @r_max
p @g_max
p @b_max

r_diff = @r_max / @num_means
g_diff = @g_max / @num_means
b_diff = @b_max / @num_means

@means = [[0, 0, 0]]

(1..@num_means-1).to_a.each do |i|
	@means.push([@means[i-1][0] + r_diff, @means[i-1][1] + g_diff, @means[i-1][2] + b_diff])
end

@means = [[60, 60, 60], [75, 75, 120]]
# p @means

@clustered = Hash.new

@means.each_with_index do |item, index|
	@clustered[index] = []
end

num_iteration = 20

(0..num_iteration).to_a.each do |item|
	@clustered = Hash.new

	@means.each_with_index do |item, index|
		@clustered[index] = []
	end
	@all_data.each do |data_point|
		mean_distances = Array.new
		@means.each do |mean|
			mean_distances.push(find_distance(data_point, mean))
		end

		# find minimum distance and classify the data_point

		cluster_num = mean_distances.index(mean_distances.min)

		@clustered[cluster_num].push(data_point)
	end

	# p @clustered

	# calculate the new means

	@means.each_with_index do |item, index|
		red = Array.new
		green = Array.new
		blue = Array.new
		@clustered[index].each_with_index do |item, index|
			red.push(item[0])
			green.push(item[1])
			blue.push(item[2])
		end
		# p red
		if red.count == 0 or green.count == 0 or blue.count == 0
			next
		end
		@means[index] = [red.mean, green.mean, blue.mean]
	end

	p "New means"
	p @means

	@clustered.each_with_index do |item, index|
		p index.to_s + " : " + @clustered[index].count.to_s
	end
end

red = Array.new
green = Array.new
blue = Array.new

@clustered[1].each_with_index do |item, index|
	red.push(item[0])
	green.push(item[1])
	blue.push(item[2])
end

Gnuplot.open do |gp|
	Gnuplot::SPlot.new( gp ) do |plot|

		plot.title  "Array Plot Example"
		plot.xlabel "red"
		plot.ylabel "green"
		plot.zlabel "blue"

		x = (0..50).collect { |v| v.to_f }
		y = x.collect { |v| v ** 2 }

		plot.data << Gnuplot::DataSet.new( [red, green, blue] ) do |ds|
			ds.with = "points"
			ds.notitle
		end
	end
end
