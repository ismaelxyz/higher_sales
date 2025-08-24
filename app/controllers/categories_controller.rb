# CategoriesController handles CRUD operations for Category resources.
#
# Notes:
# - Skips admin authentication for index and show actions.
# - Responds with JSON for all actions.
class CategoriesController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index, :show ]
  def index
    @categories = Category.all
    render json: @categories
  end

  def show
    @category = Category.find(params[:id])
    render json: @category
  end

  def create
    @category = Category.new(category_params.merge(created_by_admin: current_admin))
    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_content
    end
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      render json: @category
    else
  render json: @category.errors, status: :unprocessable_content
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    head :no_content
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
