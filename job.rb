#!/usr/bin/env ruby
#
require 'rubygems'
require 'hpricot'
require 'logger'
require 'ftools'
require 'right_aws'
require 'fileutils'
require 'rake'

require 'global'
require 'util'

class Job
  attr_reader :r_script_filename, :job_id, :curr_uuid


  def initialize(xml_response)
    @r_script_filename = nil
    @job_id = 0
    @curr_uuid = rand_uuid

    create_if_missing_directory @curr_uuid
    @r_script_filename = "#{@curr_uuid}/#{@curr_uuid}.r"
    doc = Hpricot(xml_response)

    # at the moment we extract only JOB ID and script content
    # rest such as data we will look at it in later phases.
    @job_id = (doc/'job'/'id').inner_text
    $logger.info("JOB_ID = #{@job_id}, LOCAL_DIR = #{Dir::pwd}/#{@curr_uuid}, SCRIPT_NAME = #{@r_script_filename}")
    r_script = (doc/'source-code').inner_text
    r_script_file_handle = File.open(@r_script_filename, aModeString="w")
    r_script_file_handle.puts r_script
    r_script_file_handle.close

    # just some temporary logic/hack for data if script uses some .dat,.csv file
    # this will be removed when we have data support in CRdata
    `cp /tmp/*.dat /tmp/*.csv #{Dir::pwd}/#{@curr_uuid}`
  end

  def run
    $logger.info('successfully created job and saved R file')
    # this will run the R program that generates log file and results
    system "cd #{Dir::pwd}/#{@curr_uuid}; r CMD BATCH #{@curr_uuid}.r; mv #{@curr_uuid}.r.Rout job.log; "

    # move log file
  end

  def get_id
    @job_id
  end

  def store_results_and_logs
    # parse xml find S3 location and store results in S3
    options = { 'x-amz-acl' => 'public-read' } # For now all is public

    # first create a specific object name for S3
    # current convention is that JOB ID is maximum 10 digits
    # so if job_id < 10 digits, then prepend 0s
    str_job_id = get_id.to_s
    len_str_job_id = str_job_id.length
    while len_str_job_id <= 9
      str_job_id = "0" + str_job_id
      len_str_job_id += 1
    end

    # first store log
    s3if.put('crdataapp', "logs/job_#{str_job_id}/job.log", File.open("#{@curr_uuid}/job.log"), options)

    # now iterate through directory and store all results files (web content only)
    
    # upload only web content files for results
    # .html,.htm,.css,.png,.pdf,.jpg
    # iterate through directory and store files one at a time in S3
    upload_files = Dir[File.join(@curr_uuid, "*")].select{|file| File.ftype(file) == "file" &&
                  (File.extname(file) == '.jpg' ||
                  File.extname(file) == '.png' ||
                  File.extname(file) == '.html' ||
                  File.extname(file) == '.htm' ||
                  File.extname(file) == '.js' ||
                  File.extname(file) == '.css' ||
                  File.extname(file) == '.pdf')}.each{|name|
                      name = name.split("/").last
                      s3if.put('crdataapp', "results/job_#{str_job_id}/#{name}", File.open("#{@curr_uuid}/#{name}"), options)
                  }

  end

  # Helper to return an interface to S3
  def s3if
    # A trck to control the RightAWS logging
    $VERBOSE = nil if @verbose == 0 # Totally silence ruby if we're in silent mode. Useful for cron scripts

    s3_opts = {:multi_thread => true, :logger => nil}

    $S3 ||= RightAws::S3Interface.new($AWS_ACCESS_KEY, $AWS_SECRET_KEY, s3_opts)

    $S3
  end
end
