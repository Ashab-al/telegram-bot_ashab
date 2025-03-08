class Tasks::EditRelationForVacancyWithCategoryTask 
  def call
    Vacancy.all.each do |vacancy|
      vacancy.category = Category.where(name: vacancy.category_title).first
      vacancy.save
    end
  end
end
