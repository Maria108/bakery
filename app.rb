require "sinatra"
require 'dotenv/load'
require "sendgrid-ruby"
require "json"
require "erb"

include SendGrid

file = File.read('data/catalog.json')
data = JSON.parse(file)

get "/" do
  erb :index
end

get "/cakes" do
    @catalog = data["data"]["cakes"]
    erb :cakes
end

get "/cupcakes" do
    @catalog = data["data"]["cupcakes"]
    erb :cupcakes
end

get "/macaroons" do
    @catalog = data["data"]["macaroons"]
    erb :macaroons
end

post "/contacts" do
    @name, @email = params[:name], params[:email]

    @data = render_email

    from = Email.new(email: 'maria.abash@gmail.com')
    to = Email.new(email: @email)
    subject = "Catalog"
    content = Content.new(type: 'text/html', value: @data)
    mail = Mail.new(from, subject, to, content)
  
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
  
    redirect "/"
  end

def render_email
    file = File.read('data/catalog.json')
    data = JSON.parse(file)
    @catalog = data["data"]
    @template = File.read('./views/email.erb')
    ERB.new(@template).result( binding )
end
