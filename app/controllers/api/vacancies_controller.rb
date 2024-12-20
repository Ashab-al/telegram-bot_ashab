class Api::VacanciesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: Vacancy.all, status: :ok
  end

  def create
    blacklist = Api::Vacancy::BlackListCheckInteractor.run(blacklist_params)
    return render json: {success: false, message: errors_converter(blacklist.errors) }, 
                          status: :unprocessable_entity if blacklist.errors.present?
    
    vacancy = Api::Vacancy::CreateVacancyInteractor.run(vacancy_params)
    
    return render json: {success: false, message: errors_converter(vacancy.errors) }, 
                          status: :unprocessable_entity if vacancy.errors.present?

    TelegramMessageService.new.sending_vacancy_to_users(@vacancy)
    
    
    render json: vacancy.result, status: :ok
  end

  private

  def blacklist_params
    {
      platform_id: params[:platform_id], 
      contact_information: params[:contact_information],
      source: params[:source]
    }
  end

  def vacancy_params
    {
      category_title: params[:category_title],
      title: params[:title],
      description: params[:description],
      contact_information: params[:contact_information],
      platform_id: params[:platform_id],
      source: params[:source]
    }
  end
end
