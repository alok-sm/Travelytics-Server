class TempController < ApplicationController
	include LikesHelper
	def multi
		tokens = ["TOKEN ARRAY TO TEST MULTI THREADED DATA FETCH"]

  		render json: getData(tokens)
	end
end
