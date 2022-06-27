class ProductsController < ApplicationController
   skip_before_action :protect_pages, only: [:index, :show]
   def index
      require 'json'
      require 'rest-client'
 
      url = 'https://v6.exchangerate-api.com/v6/192ab6347b4b641daab4d232/pair/USD/COP'
      
      response = RestClient.get url
      
      results = JSON.parse(response.to_str)
      @price_cop = results['conversion_rate']

      url2 = 'https://v6.exchangerate-api.com/v6/192ab6347b4b641daab4d232/pair/USD/EUR'
      
      response2 = RestClient.get url2
      
      results2 = JSON.parse(response2.to_str)
      price_eur = results2['conversion_rate']

      url3 = 'https://v6.exchangerate-api.com/v6/192ab6347b4b641daab4d232/pair/USD/JPY'
      
      response3 = RestClient.get url3
      
      results3 = JSON.parse(response3.to_str)
      price_jpy = results3['conversion_rate']



      @categories = Category.order(name: :asc).load_async
         
      @pagy, @products = pagy_countless(FindProducts.new.call( product_params_index).load_async, items: 12)
   
   end
 
   def show
      product
   end

   def new
      @product = Product.new
   end

   def create
      @product = Product.new(product_params)
      if @product.save
         redirect_to products_path, notice: 'tu producto se ha creado correctamente'
      else
         render :new, status: :unprocessable_entity
      
      end
   end

   def edit
      product
   end

   def update
     
      if product.update(product_params)
         redirect_to products_path, notice: 'Tu producto se ha actualizado correctamente'
      else
         render :edit, status: :unprocessable_entity
      
      end
   end

  def destroy
   product.destroy

   redirect_to products_path, notice: 'Tu producto se ha eliminado correctamente', status: :see_other
  end

   private

   def product_params
      params.require(:product).permit(:title, :description, :price, :photo, :category_id)
   end

   def product_params_index
      params.permit(:category_id, :min_price, :max_price, :query_text, :order_by, :page)

   end

   def product
      @product = Product.find(params[:id])
   end
end
