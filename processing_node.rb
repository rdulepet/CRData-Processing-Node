#!/usr/bin/env ruby
#
################################################################################
# File:         processing_node.rb
# Description:  This is the main loop processing requests on worker machine.
#               It continuously polls the server for jobs to run. Once a job
#               is available to run, it calls the relevant R script through
#               RSRuby interface. It will block on the job is complete before
#               accepting a new job. This cycle is repeated forever until the
#               worker machine is shut down.
# License:      Creative Common License, CRdata.org project
################################################################################

require 'rubygems'
require 'rest_client'
require 'logger'

require 'job'
require 'global'
require 'util'

class ProcessingNode
  attr_reader :server_node, :site

  def initialize(server)
    @server_node = server
    @site = RestClient::Resource.new(@server_node)
  end

  def run
    #while true
      # main processing loop that accepts new job from server, server address
      # is passed as argument to the program.

      # STEP 1: Fetch new job from server
      # STEP 2: If there are no jobs, sleep and try again
      # STEP 3: If there is a job found in STEP 1, then parse the payload
      # STEP 4: Assuming new job, create tempdir()
      # STEP 5: Save the r-script that was fetched as part of new job payload
      # STEP 5: Fetch Datasets, if any from S3 if indicated in job payload.
      #         Currently the datasets is not yet supported in Phase 1 so not
      #         implemented yet.
      # STEP 6: Call RSRuby wrapper code to execute the R script, this is a
      #         currently blocking call, not multithreaded etc.
      # STEP 7: Next step is calling storage wrapper code to store results
      #         and logs in S3.
      # STEP 8: Mark status of the job on server as 'done' or 'cancelled'
      # STEP 9: Repeat STEP 1.
      job = nil
      begin
        # STEP 1
        job = fetch_next_job()

        # STEP 3-6
        job.run if !job.nil?

        # STEP 7
        store_results_and_logs(job) if !job.nil?

        # STEP 8
        job_completed(job, true) if !job.nil?
      rescue => err
        $logger.fatal(err)

        # STEP 7
        store_results_and_logs(job) if !job.nil?

        # STEP 8
        job_completed(job, false) if job.nil?
        job = nil
      end

      # STEP 2 & STEP 9
      sleep(1)
    #end
  end

  def fetch_next_job
    # issue command to fetch next job
    xml_response = @site['jobs_queues/run_next_job'].put '', {:content_length => '0', :content_type => 'text/xml'}
    job = Job.new(xml_response)

    job
  end

  def store_results_and_logs(job)
    # since job is complete, fetch from server the location to store output
    # two locations for log and results
    upload_payload_length = "upload_type=logs&files=job.log".length
    job.store_logs(@site["jobs/#{job.get_id}/uploadurls.xml"].get 'upload_type=logs&files=job.log', {:content_length => "#{upload_payload_length.to_s}", :content_type => 'text/plain'})

    upload_payload_length = "upload_type=results&files=job.log".length
    job.store_results(@site["jobs/#{job.get_id}/uploadurls.xml"].get 'upload_type=results&files=job.log', {:content_length => "#{upload_payload_length.to_s}", :content_type => 'text/plain'})
  end
  
  def job_completed(job, successful)
    # mark status of the job on server
    if successful
      success_length = "success=true".length
      @site["jobs/#{job.get_id}/done.xml"].put 'success=true', {:content_length => "#{success_length.to_s}", :content_type => 'text/plain'}
    else
      success_length = "success=false".length
      @site["jobs/#{job.get_id}/done.xml"].put 'success=false', {:content_length => "#{success_length.to_s}", :content_type => 'text/plain'}
    end
  end
end

#################################################################
# MAIN PROGRAM CALL (this is the START)
# initialize and launch, ensure command line has server address
$curr_uuid = rand_uuid
create_if_missing_directory $curr_uuid

$logger = Logger.new("#{$curr_uuid}/processing_node_error.log")

server = ARGV[0]

processing_node = ProcessingNode.new(server)
processing_node.run
