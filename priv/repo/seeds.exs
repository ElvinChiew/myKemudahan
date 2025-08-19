# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyKemudahan.Repo.insert!(%MyKemudahan.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MyKemudahan.Assets
alias MyKemudahan.Repo

# Create sample categories
chair_category = Assets.create_category!(%{name: "Chair"})
table_category = Assets.create_category!(%{name: "Table"})
canopy_category = Assets.create_category!(%{name: "Canopy"})
hall_category = Assets.create_category!(%{name: "Hall"})

# Create sample assets
Assets.create_asset!(%{
  name: "Office Chair",
  description: "Comfortable office chair with adjustable height",
  cost_per_unit: Decimal.new("150.00"),
  image: "",
  status: "Available",
  category_id: chair_category.id
})

Assets.create_asset!(%{
  name: "Conference Table",
  description: "Large conference table for meetings",
  cost_per_unit: Decimal.new("500.00"),
  image: "",
  status: "Available",
  category_id: table_category.id
})

Assets.create_asset!(%{
  name: "Event Canopy",
  description: "Large canopy for outdoor events",
  cost_per_unit: Decimal.new("200.00"),
  image: "",
  status: "Available",
  category_id: canopy_category.id
})

Assets.create_asset!(%{
  name: "Meeting Hall",
  description: "Large hall for conferences and events",
  cost_per_unit: Decimal.new("1000.00"),
  image: "",
  status: "Available",
  category_id: hall_category.id
})

Assets.create_asset!(%{
  name: "Dining Chair",
  description: "Standard dining chair",
  cost_per_unit: Decimal.new("80.00"),
  image: "",
  status: "Available",
  category_id: chair_category.id
})

Assets.create_asset!(%{
  name: "Folding Table",
  description: "Portable folding table",
  cost_per_unit: Decimal.new("120.00"),
  image: "",
  status: "Available",
  category_id: table_category.id
})
