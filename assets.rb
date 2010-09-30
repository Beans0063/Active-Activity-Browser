# myapp.rb
  require 'rubygems'
  require 'sinatra'
  require 'erb'
  require 'Active'
  require 'sinatra/memcache'
  require 'sequel'
#  require 'reverse_markdown'
  require 'sanitize'
  
  REG_ASSET_TYPE="EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
  WORKS_ASSET_TYPE="DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"
  
  configure do 
    content = File.new("database.yml").read
    settings = YAML::load content
    DB = Sequel.connect("#{settings['adapter']}://#{settings['username']}:#{settings['password']}@#{settings['host']}/#{settings['database']}", :max_connections=>8, :pool_timeout=>10)
  end
  
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
  
  def get_or_post(path, opts={}, &block)
    get(path, opts, &block)
    post(path, opts, &block)
  end
    
  get_or_post '/' do
    #ReverseMarkdown.new.parse_string("123") 
    @limit = params[:limit] || 5
    @type = params[:type] || REG_ASSET_TYPE
    calendar_events = DB[:calendar_events]
    result = calendar_events.select(:asset_id).where("asset_type_id = '#{@type}'").limit(@limit)
    @assets = result.collect {|r| r[:asset_id]}

    erb :index

  end