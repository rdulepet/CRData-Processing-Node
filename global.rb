#!/usr/bin/env ruby
#
require 'rubygems'
require 'right_aws'
require 'fileutils'

class Global
  # follow singleton pattern for this (so only way to initialize is thru create method below
  private_class_method :new

  # Class level variables
  @@global = nil
  @@logger = nil
  @@root_dir = nil
  @@results_dir = nil

  # CONSTANTS
  # parse xml find S3 location and store results in S3
  S3_OPTIONS = { 'x-amz-acl' => 'public-read' } # For now all is public
  # Keys for the main CRData Amazon account - read from env!
  AWS_ACCESS_KEY = 'AKIAJZ5KSZXV2N4XIKNA'
  AWS_SECRET_KEY = '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'
  MAIN_BUCKET    = 'crdataapp'
  MAIN_BUCKET_URL = 'http://crdataapp.s3.amazonaws.com/'

  TEMP_DIR = "temp"
  LOG_FILE = "/tmp/processing_node_error.log"

  def Global.create
    @@global = new unless @@global
    @@global
  end

  def self.logger
    @@logger
  end

  def self.set_logger some_logger_object
    @@logger = some_logger_object
  end

  def self.root_dir
      @@root_dir
  end

  def self.results_dir
      @@results_dir
  end

  def self.set_root_dir
      @@root_dir = FileUtils.pwd unless @@root_dir
  end

  def self.set_results_dir
      Dir.mkdir(TEMP_DIR) unless File.exists?(TEMP_DIR)
      @@results_dir = (FileUtils.pwd + "/" + TEMP_DIR) unless @@results_dir
  end

  # Helper to return an interface to S3
  def self.s3if
    # A trck to control the RightAWS logging
    $VERBOSE = nil if @verbose == 0 # Totally silence ruby if we're in silent mode. Useful for cron scripts

    s3_opts = {:multi_thread => true, :logger => nil}

    $S3 ||= RightAws::S3Interface.new(Global::AWS_ACCESS_KEY, Global::AWS_SECRET_KEY, s3_opts)

    $S3
  end

  def self.rand_hex_3(l)
    "%0#{l}x" % rand(1 << l*4)
  end

  def self.rand_uuid
    [8,4,4,4,12].map {|n| rand_hex_3(n)}.join('-')
  end


  def self.create_if_missing_directory *names
    names.each do |name| FileUtils.mkdir(name) unless File.directory?(name) end
  end
end

class String
  def clean_s3_url
     self.gsub(Global::MAIN_BUCKET_URL,'')
  end
  def last_part
     self[self.rindex('/')+1..-1]
  end
end
