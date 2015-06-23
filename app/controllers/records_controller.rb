class RecordsController < ApplicationController
  prepend_before_action :convert_noid_to_id
  before_filter :load_object, only: [:destroy]

  include RecordsControllerBehavior

  def destroy
    # Assume for now that the only type of records we can
    # delete using the UI are local authorities.
    authorize! :destroy, :local_authorities

    references = @record.referenced_by
    if references.empty?
      flash[:notice] = "Record \"#{@record.rdf_label.first}\" has been destroyed"
      @record.destroy
    else
      flash[:alert] = "Record \"#{@record.rdf_label.first}\" cannot be deleted because it is referenced by #{references.count} other #{'record'.pluralize(references.count)}."
    end

    redirect_to local_authorities_path
  end


  private

  def convert_noid_to_id
    return unless params[:id]
    if id = Identifier.treeify(params[:id])
      params[:id] = id
    end
  end

  def load_object
    @record = ActiveFedora::Base.find(params[:id])
  end

end
