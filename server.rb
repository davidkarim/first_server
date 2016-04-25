# Sinatra web server
# This server takes in a parameter (i.e. stock=msft) and responds with a formatted page that displays the
# stock information.
require 'sinatra'
require 'httparty'
require 'nokogiri'

get '/' do
  begin
    ticker_symbol = params['stock'].upcase
  rescue NoMethodError
    return "<h2>Please use a proper argument</h2>"
  end

  if ticker_symbol
    url = "http://finance.yahoo.com/q?s=#{ticker_symbol}"
    response = HTTParty.get url

    dom = Nokogiri::HTML(response.body)

    price_object = dom.xpath("//span[@id='yfs_l84_#{ticker_symbol.downcase}']").first
    if price_object
      price = price_object.content

      company = dom.xpath("//*[@id='yfi_rt_quote_summary']/div[1]/div/h2").first.content
      prev_close = dom.xpath("//table[@id='table1']/tr[1]/td").first.content
      pe_ratio = dom.xpath("//*[@id='table2']/tr[6]/td").first.content

      response = "<H2>Company name: #{company}</H2>" + "Value: $%.2f" % price + "</br>"
      response += "Previous close $%.2f" % prev_close + "</br>"
      response += "P/E Ratio: %.2f" % pe_ratio + "</br>"
      return response
    else
      return "<h2>Symbol doesn't exist</h2>"
    end
  else
    return "<h2>No Argument</h2>"
  end
end
