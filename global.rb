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
  SUCCESSFUL_JOB = 'Successful Job'
  FAILED_JOB = 'Failed Job'
  RETURN_STATUS = 'FAILED JOB, PLEASE CHECK LOG'
  JOB_LOG = 'job.log'

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
  def last_part
     self[self.rindex('/')+1..-1]
  end
  def last_part_without_params
    self[self.rindex('/')+1..-1].gsub /\?Signature.*/, ''
  end
end
