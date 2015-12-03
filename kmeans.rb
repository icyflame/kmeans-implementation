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

# Data Collection from the text file

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

# Define variables

@means = Array.new

@num_means = 3

p @r_max
p @g_max
p @b_max

# Calculate the initial set of centroids

'
Use a set of equally spaced centroids
Does not work so well

r_diff = @r_max / @num_means
g_diff = @g_max / @num_means
b_diff = @b_max / @num_means

@means = [[0, 0, 0]]

(1..@num_means-1).to_a.each do |i|
	@means.push([@means[i-1][0] + r_diff, @means[i-1][1] + g_diff, @means[i-1][2] + b_diff])
end
'

'
Use a random set of initial centroids
'

(1..@num_means).to_a.each do |ind|
	@means.push([rand(256), rand(256), rand(256)])
end

@clustered = Hash.new

@means.each_with_index do |item, index|
	@clustered[index] = []
end

@old_means = [-1, -1, -1]

# Define number of iterations

num_iteration = 100

# Start iterations loop

(0..num_iteration).to_a.each do |item|

	# Re-init clustered
	@clustered = Hash.new

	@means.each_with_index do |item, index|
		@clustered[index] = []
	end

	# Find distance for each data-point, and cluster it

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

		# if red.count == 0 or green.count == 0 or blue.count == 0
		#	next
		# end

		@means[index] = [red.count != 0 ? red.mean : @means[index][0], green.count != 0 ? green.mean : @means[index][1], blue.count != 0 ? blue.mean : @means[index][2]]
	end

	p "--------------------"
	p "Old means"
	p @old_means
	p "New means"
	p @means

	@clustered.each_with_index do |item, index|
		p index.to_s + " : " + @clustered[index].count.to_s
	end
end

@red_all = Array.new
@green_all = Array.new
@blue_all = Array.new

@clustered.each_with_index do |cluster, ind|
	red = Array.new
	green = Array.new
	blue = Array.new

	p "Cluster"
	p cluster.count

	p "index"
	p ind
	p @clustered[ind].count

	@clustered[ind].each_with_index do |item, index|
		red.push(item[0])
		green.push(item[1])
		blue.push(item[2])
	end

	@red_all.push(red)
	@green_all.push(green)
	@blue_all.push(blue)
end

@plot_datasets = Array.new

@red_all.each_with_index do |item, index|
	@plot_datasets.push(Gnuplot::DataSet.new( [@red_all[index], @green_all[index], @blue_all[index]]) { |ds|
		ds.with = "points"
		ds.title = "Cluster " + index.to_s
	})
end

File.open("array_plot.dat", "w") do |gp|
	Gnuplot::SPlot.new( gp ) do |plot|

		plot.title  "Array Plot Example"
		plot.xlabel "red"
		plot.ylabel "green"
		plot.zlabel "blue"

		plot.data = @plot_datasets
	end
end
