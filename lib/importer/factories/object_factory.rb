class ObjectFactory

  attr_reader :attributes, :files_directory

  def initialize(attributes, files_dir)
    @files_directory = files_dir
    @attributes = attributes
  end

  def run
    raise "You must implement the run method"
  end

end
