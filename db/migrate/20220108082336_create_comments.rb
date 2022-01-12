class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :event, null: false, foreign_key: true, type: :uuid
      t.string :comment

      t.timestamps
    end
  end
end
