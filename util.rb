def rand_hex_3(l)
  "%0#{l}x" % rand(1 << l*4)
end

def rand_uuid
  [8,4,4,4,12].map {|n| rand_hex_3(n)}.join('-')
end


def create_if_missing_directory *names
  names.each do |name| Dir::mkdir(name) unless File.directory?(name) end
end

