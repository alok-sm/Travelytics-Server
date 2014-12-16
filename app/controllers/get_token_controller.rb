class GetTokenController < ApplicationController
	include LikesHelper

	def index

		appid = "APP ID"
		appsecret = "APP SECRET"
		callbackurl = "CALLBACK URL"

		$oauth = Koala::Facebook::OAuth.new(appid, appsecret, callbackurl)

		redirect_to $oauth.url_for_oauth_code(
			:permissions => "user_about_me,"+
							"user_likes,user_interests,"+
							"user_friends"
		)
	end

	def callback
		accessToken = $oauth.get_access_token(params[:code])
		render json:accessToken
	end
end
