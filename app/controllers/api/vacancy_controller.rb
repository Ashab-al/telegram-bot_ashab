class Api::VacancyController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @vacancys = Vacancy.all
    render json: @vacancys
  end

  def create
    @vacancy = Vacancy.new(vacancy_params)
    if blacklist_check(@vacancy) && @vacancy.save
      send_vacancy(@vacancy)
      render json: @vacancy, status: :created
    else
      render json: {"err": "Вакансия не прошла проверку"}, status: :unprocessable_entity
    end
  end

  private

  def blacklist_check(vacancy)
    blacklist = Blacklist.find_by(:contact_information => vacancy.contact_information)
    if blacklist && blacklist.complaint_counter >= 3
      return false
    else 
      return true
    end
  end

  def vacancy_params
    params.permit(:category_title, :title, :description, :contact_information)
  end

  def send_vacancy(vacancy)
    TelegramMessageService.new.sending_vacancy_to_users(vacancy)
  end
end
