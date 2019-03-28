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
      @extracted = @extraction.extract
      if @extracted
        format.html { render :create }
        format.json { render json: @extracted }
      else
        format.html { render :show }
        format.json do
          render json: @extraction.errors, status: :unprocessable_entity
        end
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_params
      if params[:extraction]
        # For form
        base_params = params.require(:extraction)
      else
        # For API
        base_params = params.except(:format, :utf8, :authenticity_token, :commit)
      end
      base_params.permit(:data,
                         :uri,
                         :timeout,
                         :limit_cpu,
                         :limit_as,
                         :max_body_size)
    end
end
