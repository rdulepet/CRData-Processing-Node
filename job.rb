#!/usr/bin/env ruby
#
require 'rubygems'
require 'hpricot'
require 'logger'
require 'ftools'

require 'global'
require 'util'

class Job
  attr_reader :r_script_filename, :job_id

  def initialize(xml_response)
    @r_script_filename = nil
    @job_id = 0
    
    create_if_missing_directory $curr_uuid
    @r_script_filename = "#{$curr_uuid}/#{$curr_uuid}.r"
    doc = Hpricot(xml_response)

    # at the moment we extract only JOB ID and script content
    # rest such as data we will look at it in later phases.
    @job_id = (doc/'job'/'id').inner_text
    $logger.info("JOB_ID = #{@job_id}, LOCAL_DIR = #{Dir::pwd}/#{$curr_uuid}, SCRIPT_NAME = #{@r_script_filename}")
    r_script = (doc/'source-code').inner_text
    r_script_file_handle = File.open(@r_script_filename, aModeString="w")
    r_script_file_handle.puts r_script
    r_script_file_handle.close

    # just some temporary logic/hack for data if script uses some .dat,.csv file
    # this will be removed when we have data support in CRdata
    `cp /tmp/*.dat /tmp/*.csv #{Dir::pwd}/#{$curr_uuid}`
  end

  def run
    $logger.info('successfully created job and saved R file')
    # this will run the R program that generates log file and results
    system "cd #{Dir::pwd}/#{$curr_uuid}; r CMD BATCH #{@r_script_filename}; mv  #{@r_script_filename}.Rout job.log"

    # move log file
  end

  def get_id
    @job_id
  end

  def store_results(xml_response)
    # parse xml find S3 location and store results in S3
  end

  def store_logs(xml_response)
    # parse xml find S3 location and store logs in S3
  end
end
