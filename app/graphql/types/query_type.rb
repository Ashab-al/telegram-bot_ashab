# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :vacancies, [Types::VacancyType], null: false do 
      description "Query that selects all vacancies"
    end

    field :categories, [Types::CategoryType], null: false do 
      description "Query that selects all categories"
    end

    def vacancies
      Vacancy.all
    end

    def categories
      Category.all
    end
  end
end
