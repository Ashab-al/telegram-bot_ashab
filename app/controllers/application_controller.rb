class ApplicationController < ActionController::API
  private

  def errors_converter(errors)
    errors.reduce([]) do |errors_list, _error|
      errors_list << {
        'attribute' => errors.first.attribute,
        'name' => errors.first.type,
        'options' => errors.first.options
      }
    end
  end
end
