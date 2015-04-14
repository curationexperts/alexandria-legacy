module OptionsHelper
  def digital_origin_options
    local_string_options('digital_origin')
  end

  def description_standard_options
    local_string_options('description_standard')
  end

  def sub_location_options
    local_string_options('sub_location')
  end

  private
    def local_string_options(field)
      Qa::Authorities::Local.subauthority_for(field).all.map { |t| t['label'.freeze] }
    end
end
