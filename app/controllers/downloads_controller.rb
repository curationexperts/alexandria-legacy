class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def asset
    logger.info "Loading asset from id #{params[:id]}"
    super
  end

  def load_file
    asset.attached_files['original']
  end
end
