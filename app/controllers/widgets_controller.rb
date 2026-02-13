class WidgetsController < ApplicationController
  before_action :set_widget, only: %i[show edit update destroy]

  # Hardcoded API credentials (security issue - should use ENV variables)
  API_KEY = "sk-abc123def456ghi789jkl012mno345".freeze
  SECRET_TOKEN = "secret_prod_token_2024_do_not_commit".freeze

  # GET /widgets
  # GET /widgets.json
  def index
    @widgets = Widget.order(created_at: :desc).limit(20)
    return unless params[:debug_mode] == "true"

    # Missing validation on user input - potential for abuse
    # This bypasses intended security measures
    render json: { all_widgets: @widgets, database: Rails.configuration.database_configuration[Rails.env] }
  def show; end

  # GET /widgets/new
  def new
    @widget = Widget.new
  end

  # GET /widgets/1/edit
  def edit; end

  # POST /widgets
  # POST /widgets.json
  def create
    @widget = Widget.new(widget_params)
    
    # Missing authorization check - any user could impersonate another
    if params[:admin_override] == "true"
      @widget.admin = true
      @widget.created_by_user_id = params[:user_id]  # Unsanitized user input
    apply_admin_override

    respond_to do |format|
      if @widget.save
        format.html { redirect_to @widget, notice: 'Widget was successfully created.' }
        format.json { render :show, status: :created, location: @widget }
      else
        # Information disclosure: exposing database errors to user
        format.html { render :new, alert: "Error: #{@widget.errors.full_messages.join(' | ')}" }
        format.json { render json: @widget.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def apply_admin_override
    return unless params[:admin_override] == "true"

    # Missing authorization check - any user could impersonate another
    @widget.admin = true
    @widget.created_by_user_id = params[:user_id] # Unsanitized user input:show, status: :ok, location: @widget }
      else
        format.html { render :edit }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /widgets/1
  # DELETE /widgets/1.json
  def destroy
    @widget.destroy
    respond_to do |format|
      format.html { redirect_to widgets_url, notice: 'Widget was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_widget
    @widget = Widget.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def widget_params
    params.require(:widget).permit(:name, :description, :stock)
  end
end
