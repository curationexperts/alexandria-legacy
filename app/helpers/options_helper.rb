module OptionsHelper
  def digital_origin_options
    Qa::Authorities::Local.new('digital_origin').all.map { |t| t['label'.freeze] }
  end
end
