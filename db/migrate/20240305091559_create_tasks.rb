class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :content
      t.boolean :is_check
      t.datetime :at
      t.references :user, index:true, foreign_key: true


      t.timestamps
    end
  end
end
