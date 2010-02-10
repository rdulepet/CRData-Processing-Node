require 'rubygems'
require 'fileutils'
require 'global'


class InstrumentDeveloperScript
  # follow singleton pattern for this (so only way to initialize is thru create method below
  private_class_method :new

  ######## TAG LIBRARY
  CRDATA_HEADER = "#<crdata_header/>"
  CRDATA_TITLE = "#<crdata_title>(.*)</crdata_title>"
  CRDATA_TEXT = "#<crdata_text>(.*)</crdata_text>"
  CRDATA_OBJECT = "#<crdata_object>(.*)</crdata_object>"
  CRDATA_SECTION = "#<crdata_section/>"
  CRDATA_EMPTY_LINE = "#<crdata_empty_line/>"
  CRDATA_IMAGE_START = "#<crdata_image caption=\"(.*)\">"
  CRDATA_IMAGE_END = "#</crdata_image>"
  CRDATA_FOOTER = "#<crdata_footer/>"

  def self.instrument_code orig_r_script
    arr_instrumented = Array.new
    curr_random_uuid = ""
    curr_caption = ""

    File.open(orig_r_script, "r").each do | line |
      amatch = /#{CRDATA_HEADER}/.match(line)
      if amatch
        arr_instrumented[arr_instrumented.length] = "library(\"R2HTML\")\ncrdata_target <- HTMLInitFile(getwd(), filename=\"index\")\n"
      else
        amatch = /#{CRDATA_FOOTER}/.match(line)
        if amatch
          arr_instrumented[arr_instrumented.length] = "HTMLEndFile()\n"
        else
          amatch = /#{CRDATA_SECTION}/.match(line)
          if amatch
            arr_instrumented[arr_instrumented.length] = "HTML(\"<hr>\", file=crdata_target)\n"
          else
            amatch = /#{CRDATA_EMPTY_LINE}/.match(line)
            if amatch
              arr_instrumented[arr_instrumented.length] = "HTML(\"<br>\", file=crdata_target)\n"
            else
              amatch = /#{CRDATA_TITLE}/.match(line)
              if amatch
                arr_instrumented[arr_instrumented.length] = "HTML(as.title(\"#{amatch[1]}\"),file=crdata_target)\n"
              else
                amatch = /#{CRDATA_TEXT}/.match(line)
                if amatch
                  arr_instrumented[arr_instrumented.length] = "HTML(\"#{amatch[1]}\", file=crdata_target)\n"
                else
                  amatch = /#{CRDATA_OBJECT}/.match(line)
                  if amatch
                    arr_instrumented[arr_instrumented.length] = "HTML(#{amatch[1]}, file=crdata_target)\n"
                  else
                    amatch = /#{CRDATA_IMAGE_START}/.match(line)
                    if amatch
                      curr_random_uuid = Global.rand_uuid
                      curr_caption = ""
                      curr_caption = amatch[1] if amatch.length == 2
                      arr_instrumented[arr_instrumented.length] = "png(file.path(getwd(),\"#{curr_random_uuid}.png\"))\n"
                    else
                      amatch = /#{CRDATA_IMAGE_END}/.match(line)
                      if amatch
                        arr_instrumented[arr_instrumented.length] = "dev.off()\nHTMLInsertGraph(\"#{curr_random_uuid}.png\", file=crdata_target,caption=\"#{curr_caption}\")\n"
                      else
                        arr_instrumented[arr_instrumented.length] = line
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    # now write instrumented array into the original R script
    r_script_file_handle = File.open(orig_r_script, aModeString="w")
    r_script_file_handle.puts arr_instrumented.to_s
    r_script_file_handle.close
  end

end

InstrumentDeveloperScript.instrument_code("some.r")
