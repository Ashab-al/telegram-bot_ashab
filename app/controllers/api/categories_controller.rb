class Api::CategoriesController < ApplicationController
  def index
    render json: Category.all, status: :ok
  end

  def show
    outcome = Api::Category::GetCategoryInteractor.run(id: params[:id].to_i)

    if outcome.errors.present?
      return render json: { success: false, message: errors_converter(outcome.errors) },
                    status: :unprocessable_entity
    end

    render json: { success: true, category: outcome.result }, status: :ok
  end

  def create
    outcome = Api::Category::CreateCategoryInteractor.run(name: params[:name])
    if outcome.errors.present?
      return render json: { success: false, message: errors_converter(outcome.errors) },
                    status: :unprocessable_entity
    end

    render json: { success: true, category: outcome.result }, status: :ok
  end

  def update
    outcome = Api::Category::UpdateCategoryInteractor.run({ name: params[:name], id: params[:id] })
    if outcome.errors.present?
      return render json: { success: false, message: errors_converter(outcome.errors) },
                    status: :unprocessable_entity
    end

    render json: { success: true, category: outcome.result }, status: :ok
  end

  def destroy
    outcome = Api::Category::DestroyCategoryInteractor.run(id: params[:id].to_i)
    if outcome.errors.present?
      return render json: { success: false, message: errors_converter(outcome.errors) },
                    status: :unprocessable_entity
    end

    render json: { success: true, category: outcome.result }, status: :ok
  end
end
