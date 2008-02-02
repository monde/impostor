require 'autotest'

class Autotest::Impostor < Autotest

  def initialize # :nodoc:
    super
    # ignore these types of iles
    @exceptions = /\.(yml)$/

    # files to their test files
    @test_mappings = {
      %r%^lib/imposter.rb$% => proc { |_, m|
        ["test/test_www_imposter.rb"]
      },
      %r%^lib/www/imposter.rb$% => proc { |_, m|
        ["test/test_www_imposter.rb"]
      },
      %r%^lib/www/impostor/(.+).rb$% => proc { |_, m|
        ["test/test_www_impostor_#{m[1]}.rb"]
      },
      %r%^test/test_.*\.rb$% => proc { |filename, _|
        filename
      }
    }
  end

  # Given the string filename as the path, determine
  # the corresponding tests for it, in an array.
  def tests_for_file(filename)
    super.select { |f| @files.has_key? f }
  end

  # Convert the pathname s to the name of class in the s file
  def path_to_classname(s)
    return "WWW::ImpostorTest" if s =~ /test\/test_www_impostor.rb$/
    c = s.sub(/test\/test_www_impostor_(.+).rb$/, '\1')
    "WWW::Impostor::#{c.capitalize}Test"
  end

  def path_to_classname(s)
    sep = File::SEPARATOR
    f = s.sub(/^test#{sep}/, '').sub(/\.rb$/, '').split(sep)
    f = f.map { |path| path.split(/_/).map { |seg| seg.capitalize }.join }
    f = f.map { |path| path =~ /^Test/ ? path : "Test#{path}"  }
    f.join
  end


end
