module OptionsHelper
  def digital_origin_options
    local_string_options('digital_origin')
  end

  def description_standard_options
    local_string_options('description_standard')
  end

  private
    def local_string_options(field)
      Qa::Authorities::Local.new(field).all.map { |t| t['label'.freeze] }
    end
end
