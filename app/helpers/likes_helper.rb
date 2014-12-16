module LikesHelper
	def getLikes(accessToken)
		@graph = Koala::Facebook::API.new(accessToken)
		raw_likes = @graph.get_connections("me", "likes",:limit => 100000)
		likes = []
		raw_likes.each do |e|
     		likes << {:id => e["id"], :name => e["name"], :category => e["category"]}
   		end
   		return likes
	end

	def getProfile(accessToken)
		@graph = Koala::Facebook::API.new(accessToken)
		profile = @graph.get_object("me")
		profile["picture"] = @graph.get_picture(profile["id"])
		return profile
	end

	def getData(tokens)

      like_threads = []
      profile_threads = []

      tokens.each do |t|
      	like_threads << Thread.new{[t, getLikes(t)]}
      	profile_threads << Thread.new{[t,getProfile(t)]}
      end

      raw_likes = Hash[like_threads.map(&:value)]
      raw_profile = Hash[profile_threads.map(&:value)]
      likes = []
      profiles = []

      tokens.each do |t|
        likes << raw_likes[t]
        profiles << raw_profile[t]
      end

      data = []
      likes.zip(profiles).each do |l,p|
        data << {:likes => l, :profile => p}
      end
      return data
  end
end
