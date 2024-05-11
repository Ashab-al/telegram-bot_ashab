# frozen_string_literal: true

module Types
  class VacancyType < Types::BaseObject
    field :id, ID, null: false do 
      description "This vacancy id"
    end
    field :category_title, String do 
      description "This category title"
    end
    field :title, String do 
      description "This vacancy title"
    end
    field :description, String do 
      description "This vacancy description"
    end
    field :contact_information, String do 
      description "This vacancy contact information"
    end
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false do 
      description "The date/time that this vacancy created at"
    end
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false do 
      description "The date/time that this vacancy updated at"
    end
    field :source, String do 
      description "This vacancy source"
    end
    field :platform_id, String do 
      description "This vacancy platform_id"
    end
  end
end
