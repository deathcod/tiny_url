require 'csv'
require 'digest'
class ShortUrlsController < ApplicationController

  REDIS_KEY = "tiny_url".freeze

  # GET /short_urls
  # GET /short_urls.json
  def index
    @short_urls = ShortUrl.order(id: :desc).all
  end

  # GET /short_urls/1
  # GET /short_urls/XXXXXXX
  # GET /short_urls/1.json
  def show
    if (@short_url = ShortUrl.find_by_hash_string(params[:id])).present?
      @redirect = true
      respond_to do |format|
        format.html
      end
    else
      @short_url = ShortUrl.find(params[:id])
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

    if short_url_params[:long_url].empty?
      respond_to do |format|
        format.html { redirect_to short_urls_url, notice: 'No URL was provided' }
        format.json { render json: {reason: "No URL was provided" }}
      end
      return
    end
    @short_url = get_short_url_object_for(short_url_params[:long_url])
    if @short_url.present?
      respond_to do |format|
        format.html { redirect_to short_url_path(@short_url), notice: 'Short url was already present' }
        format.json { render :show, status: :created, location: @short_url }
      end
      return
    end

    @short_url = create_short_url_object_for(short_url_params[:long_url])
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
    delete_short_url_object_for(params[:id])
    respond_to do |format|
      format.html { redirect_to short_urls_url, notice: 'Short url was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def csv_urls
    
    if !params[:csv].original_filename.present?
      return render html: "alls not well1"
      respond_to do |format|
        format.html { redirect_to short_urls_url, notice: 'Filename not present'}
        format.json {render json: {reason: "Not a CSV file"}}
      end
    elsif !params[:csv].original_filename.match(/.csv$/i)
      respond_to do |format|
        format.html { redirect_to short_urls_url, notice: 'Not a CSV file'}
        format.json {render json: {reason: "Not a CSV file"}}
      end
    else
      @short_urls = []
      CSV.open(params[:csv].path, "r", headers: true).each do |row|
        this_short_url = (get_short_url_object_for(row[0]) || create_short_url_object_for(row[0]))
        @short_urls << [this_short_url.id ,this_short_url.generate_short_url, row[0], this_short_url.hash_string]
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def short_url_params
    params.require(:short_url).permit(:long_url)
  end

  def get_short_url_object_for(long_url)
    hash_key = Digest::MD5.hexdigest(ShortUrl.filtered_long_url(long_url))
    short_url_id = REDIS_POOL.with {|conn| conn.hget(REDIS_KEY, hash_key)}
    if short_url_id.present?
      Rails.logger.info("ShortUrlsController::get_short_url_object_for::Redis Hit long_url: #{long_url}")
    else
      Rails.logger.info("ShortUrlsController::get_short_url_object_for::Redis Miss long_url: #{long_url}")
    end
    ShortUrl.find_by_id(short_url_id)
  end

  def create_short_url_object_for(long_url)
    short_url = ShortUrl.create(long_url: long_url)
    if short_url.valid?
      hash_key = Digest::MD5.hexdigest(ShortUrl.filtered_long_url(long_url))
      resp = REDIS_POOL.with {|conn| conn.hset(REDIS_KEY, hash_key, short_url.id)}
      Rails.logger.info("ShortUrlsController::create_short_url_object_for::Set Redis key, hash_string: #{hash_key}, resp: #{resp}")
    end
    return short_url
  end

  def delete_short_url_object_for(hash_string)
    short_url = ShortUrl.find_by_hash_string(hash_string)
    if short_url.present?
      hash_key = Digest::MD5.hexdigest(ShortUrl.filtered_long_url(short_url.long_url))
      resp = REDIS_POOL.with {|conn| conn.hdel(REDIS_KEY, hash_key)}
      Rails.logger.info("ShortUrlsController::delete_short_url_object_for::Del Redis key, hash_string: #{hash_key}, resp: #{resp}")
      short_url.destroy
    end
    return short_url
  end
end
