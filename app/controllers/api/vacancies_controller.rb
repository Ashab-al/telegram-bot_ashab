class Api::VacanciesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: { success: true, vacancies: Vacancy.all }, status: :ok
  end

  def create
    @vacancy = Vacancy.new(vacancy_params)
    if blacklist_check(@vacancy) && @vacancy.save
      TelegramMessageService.new.sending_vacancy_to_users(@vacancy)
      render json: @vacancy, status: :created
    else
      render json: {"err": I18n.t("error.messages.error_validate_vacancy")}, status: :unprocessable_entity
    end
  end

  private

  def blacklist_check(vacancy)
    blacklist = vacancy.source == "tg_chat" ? Blacklist.find_by(:contact_information => vacancy.platform_id) : Blacklist.find_by(:contact_information => vacancy.contact_information)
    return false if blacklist && blacklist.complaint_counter >= 2

    true
  end

  def vacancy_params
    params.permit(:category_title, :title, :description, :contact_information, :platform_id, :source)
  end
end
