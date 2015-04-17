class RecordsController < ApplicationController
  prepend_before_action :convert_noid_to_id
  include RecordsControllerBehavior

  private

  def convert_noid_to_id
    if id = Identifier.treeify(params[:id])
      params[:id] = id
    end
  end

end
