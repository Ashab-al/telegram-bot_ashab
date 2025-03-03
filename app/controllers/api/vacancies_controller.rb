# frozen_string_literal: true

class Api::VacanciesController < ApplicationController
  def index
    render json: Vacancy.all, status: :ok
  end

  def create
    checker = Api::Vacancy::CheckAndCreateVacancyThenSendToUsersInteractor.run(vacancy_params)
    if checker.errors.present?
      return render json: { success: false, message: errors_converter(checker.errors) },
                    status: :unprocessable_entity
    end

    render json: checker.result, status: :ok
  end

  private

  def vacancy_params
    {
      category_title: params[:category_title],
      title: params[:title],
      description: params[:description],
      contact_information: params[:contact_information],
      platform_id: params[:platform_id],
      source: params[:source],
      category_id: params[:category_id]
    }
  end
end
