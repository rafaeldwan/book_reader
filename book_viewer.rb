require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require 'cgi'

def each_chapter
	@contents.each_with_index do |chapter, idx|
		number = idx + 1
		contents = File.read("data/chp#{number}.txt")
		yield number, contents, chapter
	end
end

def chapters_matching(query) 
	results = []
	return results unless query
	each_chapter do |number, contents, chapter|
		if contents.include?(query)
			in_page = []
			contents.split("\n\n").each_with_index do |para, idx| 
				in_page << {par_num: idx, para: "<p>#{para}</p>"} if para.include?(query)
			end
			results << {number: number, chapter: chapter, in_page: in_page}
		end
	end
	results
end

helpers do
	def in_paragraphs(string)
		string.split("\n\n").map.with_index { |para, idx| "<p id = \"#{idx}\">#{para}</p>"}.join
	end

	def strong_term(text, term)
		text.gsub(term, "<strong>#{term}</strong>")
	end
end

before do
  @contents = File.readlines("data/toc.txt")
end

not_found do
	redirect "/"
end

get "/test" do
	@results = chapters_matching("truck")
	erb :test
end

get "/" do
	@title = 'books reading for the electronic computer device'
  erb :home
end

get "/chapters/:number" do
	number = params[:number].to_i
	@title = "Chapter #{number}: #{@contents[number - 1]}"
	@chapter = File.read "data/chp#{number}.txt"
	erb :chapter
end

# get "/show/:name" do
# 	params[:name]
# end

get "/search" do
	query = CGI::unescape(params[:query]) if params[:query] 
	@results = chapters_matching(query)
	erb :search
end
