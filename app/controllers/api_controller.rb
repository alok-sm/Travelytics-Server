class ApiController < ApplicationController
	include LikesHelper

	def index #USER FOR TESTING
		seat_data = {
			"a1" => {
				:occupied => true, 
				:fb => "TEST TOKEN 1"
			},
			"a2" => {
				:occupied => false
			},
			"a3" => {
				:occupied => false
			},
			"a4" => {
				:occupied => false
			},
			"a5" => {
				:occupied => true, 
				:fb => "TEST TOKEN 2"
			},
			"a6" => {
				:occupied => false
			},
			"a7" => {
				:occupied => false
			},
			"a8" => {
				:occupied => false
			},
			"a9" => {
				:occupied => true
			}
		}

		adjacency_data = [
			["a1","a2"],
			["a2","a3"],
			["a4","a5"],
			["a5","a6"],
			["a7","a8"],
			["a8","a9"]
		]

		user_token = "TEST USER TOKEN"
		redirect_to :controller => 'api', :action => 'compute', :seat_data => seat_data.to_json, :adjacency_data => adjacency_data.to_json, :user_token => user_token
	end

	def compute
		seat_data = JSON.parse(params[:seat_data])
		adjacency_data = JSON.parse(params[:adjacency_data])
		user_token = params[:user_token]

		tokens = [user_token]

		seat_data.each do |k,v|
			if(v["occupied"] == true)
				if(!v["fb"].nil?)
					tokens << v["fb"]
				end
			end
		end

		data = getData(tokens)

		user_data = data.shift

		seat_data.each do |k,v|
			if(v["occupied"] == true)
				if(!v["fb"].nil?)
					v["fb"] = data.shift
				end
			end
		end

		ret_data = seat_data.dup

		ret_data.each do |k,v|
			if(v["occupied"] == true)
				if(v["fb"].nil?)
					ret_data[k] = -1
				else
					_likes = v["fb"][:likes] & user_data[:likes]
					likes = []
					_likes.each do |l|
						likes << l[:name]
					end
					ret_data[k] = {
						:matched_likes => likes,
						:matched_num => likes.length,
						:co_likes => v["fb"][:likes].length,
						:co_name => v["fb"][:profile]["name"],
						:co_image => v["fb"][:profile]["picture"]
					}
				end
			else
				ret_data[k] = getMatch(k,adjacency_data,seat_data,user_data)
			end
		end

		max = 0
		ret_data.each do |k,v|
			if(v.is_a?Integer)
				if(v > max)
					max = v
				end
			end
		end

		if(max !=0)
			ret_data.each do |k,v|
				if(v.is_a?Integer)
					if(v>0)
						ret_data[k]=(v.to_f/max.to_f).round(2)
					end
				end
			end
		end

		render json: ret_data
	end

	def getMatch(k,adjacency_data,seat_data,user_data)
		ret = 0
		adjacency_data.each do |_edge|
			edge = _edge.dup
			if(edge.include? k)
				edge.delete(k)
				seat_index = edge[0]
				curr_seat_data = seat_data[seat_index]
				if(curr_seat_data["occupied"] == true && !curr_seat_data["fb"].nil?)
					likes = curr_seat_data["fb"][:likes]
					ret += (likes & user_data[:likes]).length

				end
			end
		end
		return ret
	end
end
