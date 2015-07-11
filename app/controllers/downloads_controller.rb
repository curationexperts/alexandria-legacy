class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  # NOTE the ID may be uri escaped:
  #   e.g.: ca%2Fc0%2Ff3%2Ff4%2Fcac0f3f4-ea8f-414d-a7a5-3253ef003b1a
  def asset
    @asset ||= ActiveFedora::Base.find(URI.unescape(params[asset_param_key]))
  end

  def load_file
    asset.attached_files['original']
  end
end
