class ShortUrlsController < ApplicationController
  before_action :set_short_url, only: :destroy

  # GET /short_urls
  # GET /short_urls.json
  def index
    @short_urls = ShortUrl.all
  end

  # GET /short_urls/1
  # GET /short_urls/1.json
  def show
    @short_url = ShortUrl.find_by_hash_string(params[:id])
    respond_to do |format|
      format.html { render js: "window.open('#{@short_url.long_url}')" }
      format.json { render json: @short_url.long_url}
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
        format.html { redirect_to short_urls_url, notice: 'Short url was already present' }
        format.json { render :show, status: :created, location: @short_url }
      end
      return
    end

    @short_url = ShortUrl.new(long_url: short_url_params[:long_url])
    if @short_url.save
      respond_to do |format|
        format.html { redirect_to short_urls_url, notice: 'Short url was successfully created.' }
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
    @short_url.destroy
    respond_to do |format|
      format.html { redirect_to short_urls_url, notice: 'Short url was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_short_url
      @short_url = ShortUrl.find_by_hash_string(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def short_url_params
      params.require(:short_url).permit(:long_url)
    end
end
