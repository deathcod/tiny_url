class ShortUrlsController < ApplicationController

  # GET /short_urls
  # GET /short_urls.json
  def index
    @short_urls = ShortUrl.order(id: :desc).all
  end

  # GET /short_urls/1
  # GET /short_urls/1.json
  def show
    if (@short_url = ShortUrl.find_by_hash_string(params[:id]))
      @redirect = true
      respond_to do |format|
        format.html
      end
    else
      @short_url = ShortUrl.find_by(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @short_url}
      end
    end
  end

  def new
    @short_url = ShortUrl.new
  end

  # POST /short_urls
  # POST /short_urls.json
  def create

    @short_url = ShortUrl.find_by_long_url(short_url_params[:long_url])
    if @short_url.present?
      respond_to do |format|
        format.html { redirect_to short_url_path(@short_url), notice: 'Short url was already present' }
        format.json { render :show, status: :created, location: @short_url }
      end
      return
    end

    @short_url = ShortUrl.new(long_url: short_url_params[:long_url])
    if @short_url.save
      respond_to do |format|
        format.html { redirect_to short_url_path(@short_url), notice: 'Short url was successfully created.' }
        format.json { render :show, status: :created, location: @short_url }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @short_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /short_urls/1
  # DELETE /short_urls/1.json
  def destroy
    @short_url = ShortUrl.find_by_hash_string(params[:id])
    @short_url.destroy
    respond_to do |format|
      format.html { redirect_to short_urls_url, notice: 'Short url was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def upload_csv_urls
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def short_url_params
      params.require(:short_url).permit(:long_url)
    end
end
