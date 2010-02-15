#!/usr/bin/env ruby
#
require 'rubygems'
require 'fileutils'
require 'global'


class InstrumentDeveloperScript
  # follow singleton pattern for this (so only way to initialize is thru create method below
  private_class_method :new

  ######## TAG LIBRARY
  CRDATA_HEADER = "^\s*#\s*<\s*crdata_header\s*/>"
  CRDATA_TITLE = "^\s*#\s*<\s*crdata_title\s*>\s*(.*)\s*</\s*crdata_title\s*>"
  CRDATA_TEXT = "^\s*#\s*<\s*crdata_text\s*>\s*(.*)\s*</\s*crdata_text\s*>"
  CRDATA_OBJECT = "^\s*#\s*<\s*crdata_object\s*>(.*)</\s*crdata_object\s*>"
  CRDATA_SECTION = "^\s*#\s*<\s*crdata_section\s*/>"
  CRDATA_EMPTY_LINE = "^\s*#\s*<\s*crdata_empty_line\s*/>"
  CRDATA_IMAGE_START = "^\s*#\s*<\s*crdata_image\s+caption\s*=\s*\"(.*)\"\s*>"
  CRDATA_IMAGE_START_ALT = "^\s*#\s*<\s*crdata_image\s*>"
  CRDATA_IMAGE_START_END = "^\s*#\s*<\s*crdata_image(\s+caption\s*=\s*\"(.*)\")?\s*>(.*)(<\/\s*crdata_image\s*>)?"
  CRDATA_IMAGE_END = "^\s*#\s*</\s*crdata_image\s*>"
  CRDATA_IMAGE_END_ALT = "\s*</\s*crdata_image\s*>"
  CRDATA_FOOTER = "^\s*#\s*<\s*crdata_footer\s*/>"

  ALREADY_INSTRUMENTED = "library.*R2HTML"

  def self.checkif_already_instrumented_code orig_r_script
    File.open(orig_r_script, "r").each do | line |
      amatch = /#{ALREADY_INSTRUMENTED}/.match(line)
      if amatch
        # well it looks like already instrumented with R2HTML
        # so just trust the code and run with it without
        # instrumentation.
        return true
      end
    end

    return false
  end
  
  def self.instrument_code orig_r_script
    arr_instrumented = Array.new
    curr_random_uuid = ""
    curr_caption = ""

    # automatically take care of HEADER mandatory tag
    arr_instrumented[arr_instrumented.length] = "library(\"R2HTML\")\ncrdata_job_log <- file(\"job.log\", open=\"wt\")\nsink(crdata_job_log)\ncrdata_target <- HTMLInitFile(getwd(), filename=\"index\")\ntryCatch({\n"

    File.open(orig_r_script, "r").each do | line |
=begin
      # commented this code because we want to take care MANDATORY tagging automatically
      # this essentially applies to HEADER and FOOTER
      amatch = /#{CRDATA_HEADER}/.match(line)
      if amatch
        arr_instrumented[arr_instrumented.length] = "library(\"R2HTML\")\ncrdata_job_log <- file(\"job.log\", open=\"wt\")\nsink(crdata_job_log)\ncrdata_target <- HTMLInitFile(getwd(), filename=\"index\")\n"
      elsif amatch = /#{CRDATA_FOOTER}/.match(line)
        arr_instrumented[arr_instrumented.length] = "HTMLEndFile()\nsink()\n"
      elsif
=end
      if amatch = /#{CRDATA_SECTION}/.match(line)
        arr_instrumented[arr_instrumented.length] = "HTML(\"<hr>\", file=crdata_target)\n"
      elsif amatch = /#{CRDATA_EMPTY_LINE}/.match(line)
        arr_instrumented[arr_instrumented.length] = "HTML(\"<br>\", file=crdata_target)\n"
      elsif amatch = /#{CRDATA_TITLE}/.match(line)
        arr_instrumented[arr_instrumented.length] = "HTML(as.title(\"#{amatch[1]}\"),file=crdata_target)\n"
      elsif amatch = /#{CRDATA_TEXT}/.match(line)
        arr_instrumented[arr_instrumented.length] = "HTML(\"#{amatch[1]}\", file=crdata_target)\n"
      elsif amatch = /#{CRDATA_OBJECT}/.match(line)
        arr_instrumented[arr_instrumented.length] = "HTML(#{amatch[1]}, file=crdata_target)\n"
      elsif amatch = /#{CRDATA_IMAGE_START_END}/.match(line)
        curr_random_uuid = Global.rand_uuid
        curr_caption = ""
        some_r_code_found = ""

        curr_caption = amatch[2] if amatch[2] != nil and amatch[2] != ""
        some_r_code_found = amatch[3] if amatch[3] != nil and amatch[3] != ""
        arr_instrumented[arr_instrumented.length] = "\npng(file.path(getwd(),\"#{curr_random_uuid}.png\"))\n"
        if some_r_code_found != nil and some_r_code_found != ""
          arr_instrumented[arr_instrumented.length] = some_r_code_found.gsub(/#{CRDATA_IMAGE_END_ALT}/,"")
          # now see if we found END tag also, if so then insert image end instrumentation
          if /#{CRDATA_IMAGE_END_ALT}/.match(some_r_code_found)
            arr_instrumented[arr_instrumented.length] = "\ndev.off()\nHTMLInsertGraph(\"#{curr_random_uuid}.png\", file=crdata_target,caption=\"#{curr_caption}\")\n"
            curr_random_uuid = ""
            curr_caption = ""
          end
        end
=begin
      elsif amatch = /#{CRDATA_IMAGE_START}/.match(line)
        curr_random_uuid = Global.rand_uuid
        curr_caption = ""
        curr_caption = amatch[1] if amatch.length == 2
        arr_instrumented[arr_instrumented.length] = "png(file.path(getwd(),\"#{curr_random_uuid}.png\"))\n"
      elsif amatch = /#{CRDATA_IMAGE_START_ALT}/.match(line)
        curr_random_uuid = Global.rand_uuid
        curr_caption = ""
        arr_instrumented[arr_instrumented.length] = "png(file.path(getwd(),\"#{curr_random_uuid}.png\"))\n"
=end
      elsif amatch = /#{CRDATA_IMAGE_END}/.match(line)
        arr_instrumented[arr_instrumented.length] = "\ndev.off()\nHTMLInsertGraph(\"#{curr_random_uuid}.png\", file=crdata_target,caption=\"#{curr_caption}\")\n"
        curr_random_uuid = ""
        curr_caption = ""
      else
        arr_instrumented[arr_instrumented.length] = line
      end
    end

    # automatically take care of FOOTER mandatory tag
    arr_instrumented[arr_instrumented.length] = "\n}, interrupt = function(ex) {\nprint (\"got exception: Failed Job\");\n returnstatus=\"FAILED JOB, PLEASE CHECK LOG\"; \nHTML(returnstatus, file=crdata_target);\nprint(ex);\n}, error = function(ex) {\nprint (\"got error: Failed Job\");\n returnstatus=\"FAILED JOB, PLEASE CHECK LOG\"; \nHTML(returnstatus, file=crdata_target);\nprint(ex);\n}, finally = {\nHTMLEndFile()\nsink()\n\n})\n"

    # now write instrumented array into the original R script
    r_script_file_handle = File.open(orig_r_script, aModeString="w")
    r_script_file_handle.puts arr_instrumented.to_s
    r_script_file_handle.close
  end

end

# dummy test for instrumentation, commented in production mode
#InstrumentDeveloperScript.instrument_code("some.r")
