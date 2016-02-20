class AttachFilesToAudioRecording
  def self.run(audio, files_directory, cylinder_names)
    new(audio, files_directory, cylinder_names).run
  end

  attr_reader :audio, :files_directory, :cylinder_names

  def initialize(audio, files_directory, cylinder_names)
    @audio = audio
    @files_directory = files_directory
    @cylinder_names = cylinder_names
  end

  def run
    cylinder_names.each do |cylinder_name|
      number = cylinder_name.sub(/^Cylinder /, '')
      attach_files(number)
    end
  end

  private

    def original_path(number)
      Dir.glob(File.join(files_directory, '**', "cusb-cyl#{number}a.wav")).first
    end

    def restored_path(number)
      Dir.glob(File.join(files_directory, '**', "cusb-cyl#{number}b.wav")).first
    end

    def attach_files(number)
      file_set = FileSet.create
      attach_original(file_set, number)
      attach_restored(file_set, number)
      audio.ordered_members << file_set
    end

    def attach_original(file_set, number)
      if orig_path = original_path(number)
        puts "  Attaching original #{orig_path}"
        Hydra::Works::AddFileToFileSet.call(file_set,
                                            File.new(orig_path),
                                            :original_file)
      else
        $stderr.puts "Unable to find original for #{number} in #{files_directory}"
      end
    end

    def attach_restored(file_set, number)
      if rest_path = restored_path(number)
        puts "  Attaching restored #{rest_path}"
        Hydra::Works::AddFileToFileSet.call(file_set,
                                            File.new(rest_path),
                                            :restored)
        CreateDerivativesJob.perform_later(file_set.id, rest_path)
      else
        $stderr.puts "Unable to find restored for #{number} in #{files_directory}"
      end
    end
end

