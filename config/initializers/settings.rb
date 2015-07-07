class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env

  def proquest_directory
    File.join(download_root, 'proquest')
  end
end
