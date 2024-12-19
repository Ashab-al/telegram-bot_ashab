class Api::CategoriesController < ApplicationController

  def index
    render json: { success: true, category: Category.all }, status: :ok
  end

  def show
    outcome = Api::Category::GetCategoryInteractor.run({id: params[:id]})

    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

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
    outcome = Api::Category::DestroyCategoryInteractor.run(params[:id])
    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, category: outcome.result }, status: :ok
  end

  private
  
  def create_params
    params.require(:category).permit(:name)
  end

  def update_params
    params.require(:category).permit(:name, :id)
  end

end
