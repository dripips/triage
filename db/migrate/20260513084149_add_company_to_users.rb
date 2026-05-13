class AddCompanyToUsers < ActiveRecord::Migration[8.1]
  def change
    # Nullable изначально — на fresh install ещё нет компаний;
    # seed/installer создаст компанию и привяжет superadmin'а.
    add_reference :users, :company, foreign_key: true, index: true
  end
end
