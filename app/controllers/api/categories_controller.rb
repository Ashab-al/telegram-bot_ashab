class Api::CategoriesController < ApplicationController

  def create
    outcome = Api::Category::CreateCategoryInteractor.run(create_params)
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  def update
    outcome = Api::Category::UpdateCategoryInteractor.run(update_params)
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  def destroy
    outcome = Api::Category::DestroyCategoryInteractor.run(destroy_params)
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  private
  
  def create_params
    params.require(:category).permit(:name)
  end

  def update_params
    params.require(:category).permit(:new_name, :category_id)
  end

  def destroy_params
    params.require(:category).permit(:name, :category_id)
  end
end
