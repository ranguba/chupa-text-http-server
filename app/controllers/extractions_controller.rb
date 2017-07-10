class ExtractionsController < ApplicationController
  # GET /extractions/show
  def show
    @extraction = Extraction.new
  end

  # POST /extractions
  # POST /extractions.json
  def create
    @extraction = Extraction.new(extraction_params)

    respond_to do |format|
      if @extraction.valid?
        format.html { render :create }
        format.json { render json: @extraction.extract }
      else
        format.html { render :show }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_params
      params
        .except(:format, :utf8, :authenticity_token, :commit)
        .permit(:data, :uri)
    end
end
