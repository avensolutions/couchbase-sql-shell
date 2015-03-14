require 'highline'
require '../lib/cli-console'
require 'couchbase'
require "net/http"
require "uri"
@@prompt = "couchbase-sql"

class ShellUI
    private
    extend CLI::Task

    public
	usage 'Usage: SELECT'
    desc 'Run a SELECT statement'

    def select(params)
        puts "param 0 #{params[0]}"
		puts "param 0 #{params[1]}"
		puts "param 0 #{params[2]}"
		puts "param 0 #{params[3]}"
    end	

	@@conn_usage_str = 'Usage: CONNECT <ipaddress>, <username>, <password>, [<bucket_name>]'
	usage @@conn_usage_str
    desc 'Connect to a Couchbase server or cluster'

	@@hostname = 'NOTSET'
	@@username = 'NOTSET'
	@@password = 'NOTSET'
	@@bucketname = 'default'
	@@c = nil
	@@connected = false
	
	def connect(params)
		if params.length <  3
			puts @@conn_usage_str
		else
			@@hostname = params[0].gsub(',','')
			@@username = params[1].gsub(',','')
			@@password = params[2].gsub(',','')
			if params[3]
				@@bucketname = params[3]
			end
			@@c = Couchbase.connect(:hostname => @@hostname)
			listbuckets(@@hostname, false)
			if @@connected
				@@prompt = "#{@@username}@#{@@hostname}[#{@@bucketname}]"
				@@console.start("%s> ",[@@prompt])
			end
		end
	end

	def prettyprintrow(opts={})
		if opts[:type] == "header"
			print "+" +  "-" * (opts[:rowlength]-2) + "+\n"
		elsif opts[:type] == "data"
			rpadding = opts[:rowlength] - opts[:data].length - 3
			print "| " + opts[:data] +  " " * rpadding + "|\n"	
		end	
	end
	
	
	@@show_usage_str = 'Usage: SHOW BUCKETS|VERSION'
	usage @@show_usage_str
    desc 'List buckets or show version for a connected Couchbase instance'

	def show(params)
		if @@c.nil?
			puts "NOT CONNECTED, run CONNECT <ipaddr>, <username>, <password>, [<bucketname>]"
		else
			if params[0] == "buckets"
				listbuckets(@@hostname, true)
			elsif params[0] == "version"
				rowlength = 13
				prettyprintrow({:type => "header", :rowlength => rowlength})
				prettyprintrow({:type => "data", :rowlength => rowlength, :data => "version"})
				prettyprintrow({:type => "header", :rowlength => rowlength})
				prettyprintrow({:type => "data", :rowlength => rowlength, :data => Couchbase::VERSION})
				prettyprintrow({:type => "header", :rowlength => rowlength})
			puts 
			else	
				puts @@show_usage_str 
			end
		end
	end

	def listbuckets(hostname, showresults)
		begin
			uri = URI.parse("http://#{hostname}:8091/pools/default/buckets")
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Get.new(uri.request_uri)
			request.basic_auth(@@username, @@password)
			response = http.request(request)
			resphash = JSON.parse(response.body)
			if showresults
				bucketnameary = Array.new
				arrlen =  resphash.length - 1
				maxbucketlen = 0
				thisbucketlen = 0
				(0..arrlen).each do |n|
					bucketname = resphash[n]["name"]
					thisbucketlen = bucketname.length
					if thisbucketlen >  maxbucketlen
						maxbucketlen = thisbucketlen
					end
					bucketnameary.push(bucketname)
				end
				rowlength = maxbucketlen + 4
				prettyprintrow({:type => "header", :rowlength => rowlength})
				prettyprintrow({:type => "data", :rowlength => rowlength, :data => "name"})
				prettyprintrow({:type => "header", :rowlength => rowlength})
				bucketnameary.each do |bname|
					prettyprintrow({:type => "data", :rowlength => rowlength, :data => bname})
				end
				prettyprintrow({:type => "header", :rowlength => rowlength})
			end	
			@@connected = true
		rescue
			puts "Failed to connect, check user credentials"
			@@connected = false
		end
	end
	
	@@desc_usage_str = 'Usage: DESCRIBE [<bucketname>] --defaults to current bucket'
	usage @@desc_usage_str
    desc 'Describe bucket for a connected Couchbase instance'
	
	def describe(params)
		if @@c.nil?
			puts "NOT CONNECTED, run CONNECT <ipaddr>, <username>, <password>, [<bucketname>]"
		else
			if params.length > 0
				bucketname = params[0]
			else
				bucketname = @@bucketname
			end
			uri = URI.parse("http://#{@@hostname}:8091/pools/default/buckets/#{bucketname}")  
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Get.new(uri.request_uri)
			request.basic_auth(@@username, @@password)
			response = http.request(request)
			resphash = JSON.parse(response.body)
			resphash.delete("vBucketServerMap")
			puts JSON.pretty_generate(resphash)
		end
	end

	def cls(params)
		system('cls')
	end
	
	def clear(params)
		system('clear')
	end
	
end

io = HighLine.new
shell = ShellUI.new
@@console = CLI::Console.new(io)

@@console.addCommand('select', shell.method(:select), 'SELECT <statement...>')
@@console.addCommand('connect', shell.method(:connect), 'CONNECT <ipaddress>, <username>, <password>, [<bucket_name>]')
@@console.addCommand('show', shell.method(:show), 'SHOW BUCKETS|VERSION|VIEWS')
@@console.addCommand('describe', shell.method(:describe), 'DESCRIBE <bucketname>|<viewname>')
@@console.addCommand('cls', shell.method(:cls), 'cls')
@@console.addCommand('clear', shell.method(:clear), 'clear')
#use
#ping

@@console.addHelpCommand('help', 'Help')
@@console.addExitCommand('exit', 'Exit from program')
@@console.addAlias('quit', 'exit')
@@console.addAlias('bye', 'exit')
@@console.addAlias('disconnect', 'exit')

#console.start("%s> ",[Dir.method(:pwd)])
@@console.start("%s> ",[@@prompt])
