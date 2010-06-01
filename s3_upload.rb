require 'rubygems'
require 'xmlsimple'
require 'cgi'
require 'net/https'

def upload_results_to_s3 (server_name, job_id, type, fname, fpath_name)
  s3_data = ''
  response =  Net::HTTP.get(URI.parse("http://#{server_name}/jobs/#{job_id}/uploadurls.xml?upload_type=#{type}&files=#{fname}"))

  s3_data = XmlSimple.xml_in(response)
  # puts s3_data.inspect

  #this is just so we can parse it fast
  host = s3_data["files"].first[fname].first['host'].first
  port =  s3_data["files"].first[fname].first['port'].first
  header =  s3_data["files"].first[fname].first['header'].first
  ssl =  s3_data["files"].first[fname].first['ssl'].first['content']
  path =  s3_data["files"].first[fname].first['path'].first

  File.open(fpath_name, 'rb') do |up_file|
     send_request('Put', host, port, path, header, up_file, ssl) 
  end

end


def upload_data_to_s3 (server_name, job_id, type, fname, fpath_name)
  s3_data = ''
  response =  Net::HTTP.get(URI.parse("http://#{server_name}/jobs/#{job_id}/uploadurls.xml?upload_type=#{type}&files=#{fname}"))

  s3_data = XmlSimple.xml_in(response)
  #puts s3_data.inspect

  #this is just so we can parse it fast
  host = s3_data["files"].first[fname].first['host'].first
  port =  s3_data["files"].first[fname].first['port'].first
  header =  s3_data["files"].first[fname].first['header'].first
  ssl =  s3_data["files"].first[fname].first['ssl'].first['content']
  path =  s3_data["files"].first[fname].first['path'].first
  
  File.open(fpath_name, 'rb') do |up_file|
     send_request('Put', host, port, path, header, up_file, ssl) 
  end

  #create dataset object form path
  Net::HTTP.get(URI.parse("http://#{server_name}/data_sets/create_from_path.xml?name=#{fname}&job_id=#{job_id}&path=#{path}"))
end

def fetch_data_file(s3url, dest_file)
	url = URI.parse s3url
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == 'https')

  puts url.path

  # save output
  data_file_handle = File.new(dest_file, 'wb')

  request = Net::HTTP::Get.new(url.path)
  # stream the file (efficient for larger files
  http.request(request) do |res|
    size, total = 0, res.header['Content-Length'].to_i
    res.read_body do |chunk|
      size += chunk.size
      #puts "%d%% done (%d of %d)" % [(size * 100) / total, size, total]
      data_file_handle.write chunk
    end
  end
  data_file_handle.close
end

# Helper to generate REST requests, handle authentication and errors
def send_request(req_type, host, port, url, fields_hash, up_file, ssl)
  res = false
  conn_start(host, port, ssl) do |http|
    request = Module.module_eval("Net::HTTP::#{req_type}").new(url)
    fields_hash.each_pair{|n,v| request[n] = v} # Add user defined header fields
    request.content_length = up_file.lstat.size   
    request.body_stream = up_file  # For uploads using streaming
    begin
      response = http.request(request)
      
    rescue Exception => ex
      response = ex.to_s
    end

    # Handle auth errors and other errors!
    if !response.is_a?(Net::HTTPOK)
      puts 'Failed to upload!'
      log_request(request, response)
    else
      res = true
    end
  end
end

  
# Create a connection with all the needed setting
# And yeald to the block
def conn_start host, port, ssl
  con = Net::HTTP.new(host, port)
  if ssl
    con.use_ssl = true
    con.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  con.start
  if block_given?
    begin
      return yield(con)
    ensure
      con.finish
    end
  end
  con
end

# Display the request and response...
def log_request(request, response)
  puts "\nRequest Headers"
  request.each {|head,val| puts "#{head}: #{val}"}
  puts "\nResponse Headers"
  response.each {|head,val| puts "#{head}: #{val}"}
  puts "\nResponse Body"
  puts response.body
  puts "\nResponse Type"
  puts "#{response.class} (#{response.code})"
end

#upload_results_to_s3("crdata.org", 184, "logs", "job.log", "job.log")
#upload_results_to_s3("crdata.org", 184, "results", "index.html", "index.html")
