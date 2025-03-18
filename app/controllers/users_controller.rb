class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :find_user, only: [:update, :destroy]

  def create
    @user = User.new(user_params)

    if @user.save
      # Initialize any event schedulers for the user
      EventSchedulerService.schedule_all_events(@user)
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      # Reschedule events for the user after update
      EventSchedulerService.reschedule_all_events(@user)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy!
      # Cancel any scheduled events
      EventSchedulerService.cancel_all_events(@user.id)
      head :no_content
    else
      render json: { errors: 'User could not be deleted' }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :timezone)
  end

  def find_user
    @user = User.find(params[:id])
  end
end
