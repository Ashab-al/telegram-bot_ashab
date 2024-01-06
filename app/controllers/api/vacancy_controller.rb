class Api::VacancyController < ApplicationController

  def index
    @vacancys = Vacancy.all
    render json: @vacancys
  end

  def create
    @vacancy = Vacancy.new(vacancy_params)
    puts @vacancy

    if @vacancy.save
      send_vacancy(@vacancy)
      render json: @vacancy, status: :created
    else
      render json: @vacancy.errors, status: :unprocessable_entity

    end

  end

  private

  def vacancy_params
    params.permit(:category_title, :title, :description, :contact_information)
  end

  def send_vacancy(vacancy)
    TelegramMessageService.new.sending_vacancy_to_users(vacancy)
  end
end
