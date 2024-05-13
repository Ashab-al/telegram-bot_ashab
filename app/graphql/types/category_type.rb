# frozen_string_literal: true

module Types
  class CategoryType < Types::BaseObject
    field :id, ID, null: false do 
      description "This category id"
    end
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false do 
      description "The date/time that this category created at"
    end
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false do 
      description "The date/time that this category updated at"
    end
    field :name, String do 
      description "This category name"
    end
  end
end
