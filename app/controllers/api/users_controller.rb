class Api::UsersController < ApplicationController
  def index
    render json: { success: true, users: User.all }, status: :ok
  end

  def show
    outcome = Api::User::GetUserInteractor.run(id: params[:id])

    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, user: outcome.result }, status: :ok
  end

  def set_status
    outcome = Api::User::SetStatusInteractor.run({bot_status: params[:bot_status], id: params[:id]})

    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, user: outcome.result }, status: :ok
  end

  def set_bonus
    outcome = Api::User::SetBonusInteractor.run({bonus: params[:bonus], id: params[:id]})

    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { success: true, user: outcome.result }, status: :ok
  end

  def mail_all
    outcome = Api::User::MailAllInteractor.run(text: params[:text])

    return render json: {success: false, message: errors_converter(outcome.errors) }, 
                  status: :unprocessable_entity if outcome.errors.present?
    
    render json: { status: "success" }, status: :ok
  end
end
