class Api::CategoriesController < ApplicationController

  def index
    render json: { success: true, categories: Category.all }, status: :ok
  end

  def show
    outcome = Api::Category::GetCategoryInteractor.run(id: params[:id].to_i)

    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  def create
    outcome = Api::Category::CreateCategoryInteractor.run(params.permit(:name))
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  def update
    outcome = Api::Category::UpdateCategoryInteractor.run(params.permit(:name, :id))
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  def destroy
    outcome = Api::Category::DestroyCategoryInteractor.run(id: params[:id].to_i)
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end
end
