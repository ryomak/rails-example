class CreateTodoItems < ActiveRecord::Migration[7.1]
  def change
    create_table :todo_items do |t|
      t.string :content
      t.datetime :completedAt
      t.references :user, index:true, foreign_key: true
      t.timestamps
    end
  end
end
